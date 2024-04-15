import {
  AnyColumn,
  Column,
  SQLWrapper,
  Subquery,
  SubqueryConfig,
  Table,
  and,
  asc,
  count,
  desc,
  eq,
  getTableColumns,
  gt,
  inArray,
  isNotNull,
  isNull,
  lt,
  or,
  sql,
} from 'drizzle-orm';

import { client } from './client';
import { createReadQuery, createWriteQuery } from './query';
import {
  channels as $channels,
  chatMemberGroupRoles as $chatMemberGroupRoles,
  chatMembers as $chatMembers,
  contactGroups as $contactGroups,
  contacts as $contacts,
  groupNavSectionChannels as $groupNavSectionChannels,
  groupNavSections as $groupNavSections,
  groupRoles as $groupRoles,
  groups as $groups,
  pins as $pins,
  posts as $posts,
  unreads as $unreads,
} from './schema';
import {
  ChannelInsert,
  ChannelSummary,
  ChannelWithLastPostAndMembers,
  ChatMember,
  Contact,
  ContactInsert,
  GroupInsert,
  GroupSummary,
  Pin,
  PostInsert,
  TableName,
  Unread,
  UnreadInsert,
} from './types';

export interface GetGroupsOptions {
  includeUnjoined?: boolean;
  includeUnreads?: boolean;
  includeLastPost?: boolean;
}

export const getGroups = createReadQuery(
  'getGroups',
  async ({
    includeUnjoined,
    includeLastPost,
    includeUnreads,
  }: GetGroupsOptions = {}): Promise<GroupSummary[]> => {
    const unreadCounts = client
      .select({
        groupId: $channels.groupId,
        count: count().as('count'),
      })
      .from($channels)
      .rightJoin($unreads, eq($channels.id, $unreads.channelId))
      .groupBy($channels.groupId)
      .having(gt($unreads.count, 0))
      .as('unreadCounts');
    const query = client
      .select({
        ...getTableColumns($groups),
        ...(includeUnreads ? { unreadCount: unreadCounts.count } : undefined),
        ...(includeLastPost
          ? { lastPost: getTableColumns($posts) }
          : undefined),
      })
      .from($groups)
      .where(includeUnjoined ? undefined : eq($groups.isJoined, true));
    if (includeLastPost) {
      query.leftJoin($posts, eq($groups.lastPostId, $posts.id));
    }
    if (includeUnreads) {
      query.leftJoin(unreadCounts, eq($groups.id, unreadCounts.groupId));
    }
    return query;
  },
  ({ includeLastPost, includeUnreads }: GetGroupsOptions): TableName[] => [
    'groups',
    ...(includeLastPost ? (['posts'] as TableName[]) : []),
    ...(includeUnreads ? (['unreads'] as TableName[]) : []),
  ]
);

export const getChats = createReadQuery(
  'getChats',
  async (): Promise<ChannelSummary[]> => {
    const partitionedGroupsQuery = client
      .select({
        ...getTableColumns($channels),
        rn: sql`ROW_NUMBER() OVER(PARTITION BY ${$channels.groupId} ORDER BY ${$channels.lastPostAt} DESC)`.as(
          'rn'
        ),
      })
      .from($channels)
      .where(and(isNotNull($channels.groupId)))
      .as('q');

    const groupChannels = client
      .select()
      .from(partitionedGroupsQuery)
      .where(eq(partitionedGroupsQuery.rn, 1));

    const allChannels = client
      .select({
        ...getTableColumns($channels),
        rn: sql`0`.as('rn'),
      })
      .from($channels)
      .where(isNull($channels.groupId))
      .union(groupChannels)
      .as('ac');

    const result = await client
      .select({
        ...allQueryColumns(allChannels),
        group: getTableColumns($groups),
        unread: getTableColumns($unreads),
        pin: getTableColumns($pins),
        lastPost: getTableColumns($posts),
        member: {
          ...getTableColumns($chatMembers),
        },
        contact: getTableColumns($contacts),
      })
      .from(allChannels)
      .leftJoin($groups, eq($groups.id, allChannels.groupId))
      .leftJoin($unreads, eq($unreads.channelId, allChannels.id))
      .leftJoin(
        $pins,
        or(
          eq(allChannels.groupId, $pins.itemId),
          eq(allChannels.id, $pins.itemId)
        )
      )
      .leftJoin($posts, eq($posts.id, allChannels.lastPostId))
      .leftJoin($chatMembers, eq($chatMembers.chatId, allChannels.id))
      .leftJoin($contacts, eq($contacts.id, $chatMembers.contactId))
      .orderBy(ascNullsLast($pins.index), desc($unreads.updatedAt));
    const [chatMembers, filteredChannels] = result.reduce<
      [
        Record<string, (ChatMember & { contact: Contact | null })[]>,
        typeof result,
      ]
    >(
      ([members, filteredChannels], channel) => {
        if (!channel.member || !members[channel.id]) {
          filteredChannels.push(channel);
        }
        if (channel.member) {
          members[channel.id] ||= [];
          members[channel.id].push({
            ...channel.member,
            contact: channel.contact ?? null,
          });
        }
        return [members, filteredChannels];
      },
      [{}, [] as typeof result]
    );

    return filteredChannels.map((c) => {
      return {
        ...c,
        members: chatMembers[c.id] ?? null,
      };
    });
  },
  ['groups', 'channels']
);

const allQueryColumns = <T extends Subquery>(
  subquery: T
): T['_']['selectedFields'] => {
  return (subquery as any)[SubqueryConfig]
    .selection as T['_']['selectedFields'];
};

export const insertGroups = createWriteQuery(
  'insertGroups',
  async (groupData: GroupInsert[]) => {
    for (let group of groupData) {
      await insertGroup(group);
    }
  },
  [
    'groups',
    'groupRoles',
    'contacts',
    'chatMembers',
    'chatMemberGroupRoles',
    'channels',
    'pins',
  ]
);

// Note that this is not exported or wrapped in a write query -- it's used only by
// insertGroups, and wrapping this in a write query would cause it to trigger
// events for each group record inserted.
// TODO: figure out a way to trigger only one set of events per batch.
const insertGroup = async (group: GroupInsert) => {
  await client.transaction(async (tx) => {
    await tx
      .insert($groups)
      .values(group)
      .onConflictDoUpdate({
        target: $groups.id,
        set: conflictUpdateSet(
          $groups.iconImage,
          $groups.coverImage,
          $groups.title,
          $groups.description,
          $groups.isSecret,
          $groups.isJoined
        ),
      });
    if (group.channels?.length) {
      await client
        .insert($channels)
        .values(group.channels)
        .onConflictDoUpdate({
          target: [$channels.id],
          set: conflictUpdateSet(
            $channels.iconImage,
            $channels.coverImage,
            $channels.title,
            $channels.description,
            $channels.addedToGroupAt,
            $channels.currentUserIsMember,
            $channels.type
          ),
        });
    }
    if (group.navSections) {
      const navSectionChannels = group.navSections.flatMap((s) => s.channels);
      await tx
        .insert($groupNavSections)
        .values(
          group.navSections.map((s) => ({
            id: s.id,
            groupId: group.id,
            title: s.title,
            description: s.description,
            index: s.index,
            channels: s.channels?.map((c) => ({
              groupNavSectionId: s.id,
              channelId: c.channelId,
              index: s.index,
            })),
          }))
        )
        .onConflictDoUpdate({
          target: $groupNavSections.id,
          set: conflictUpdateSet(
            $groupNavSections.iconImage,
            $groupNavSections.coverImage,
            $groupNavSections.title,
            $groupNavSections.description
          ),
        });

      if (navSectionChannels.length) {
        await tx
          .insert($groupNavSectionChannels)
          .values(
            navSectionChannels.map((s) => ({
              index: s?.index,
              groupNavSectionId: s?.groupNavSectionId,
              channelId: s?.channelId,
            }))
          )
          .onConflictDoNothing();
      }
    }
    if (group.roles) {
      await client
        .insert($groupRoles)
        .values(group.roles)
        .onConflictDoUpdate({
          target: [$groupRoles.groupId, $groupRoles.id],
          set: conflictUpdateSet(
            $groupRoles.groupId,
            $groupRoles.iconImage,
            $groupRoles.coverImage,
            $groupRoles.title,
            $groupRoles.description
          ),
        });
    }
    if (group.members) {
      await client
        .insert($contacts)
        .values(group.members.map((m) => ({ id: m.contactId })))
        .onConflictDoNothing();
      await client
        .insert($chatMembers)
        .values(group.members)
        .onConflictDoNothing();
      const validRoleNames = group.roles?.map((r) => r.id);
      const memberRoles = group.members.flatMap((m) => {
        return (m.roles ?? []).flatMap((r) => {
          // TODO: This is here because I've seen at least one instance (in
          // Galen's TD group) where a member is assigned a role that doesn't
          // exist in the group's cabals. Should figure out if this is expected
          // behavior if we should try retain the role.
          if (!validRoleNames?.includes(r.roleId)) {
            return [];
          }
          return {
            groupId: group.id,
            contactId: m.contactId,
            roleId: r.roleId,
          };
        });
      });
      if (memberRoles.length) {
        await client
          .insert($chatMemberGroupRoles)
          .values(memberRoles)
          .onConflictDoNothing();
      }
    }
    if (group.posts) {
    }
  });
};

export const getGroupRoles = createReadQuery(
  'getGroupRoles',
  async () => {
    return client.query.groupRoles.findMany();
  },
  ['groupRoles']
);

export const getUnreadsCount = createReadQuery(
  'getUnreadsCount',
  async ({ type }: { type?: Unread['type'] }) => {
    const result = await client
      .select({ count: count() })
      .from($unreads)
      .where(() =>
        and(gt($unreads.count, 0), type ? eq($unreads.type, type) : undefined)
      );
    return result[0].count;
  },
  ['unreads']
);

export const getUnreads = createReadQuery(
  'getUnreads',
  async ({
    orderBy = 'updatedAt',
    includeFullyRead = true,
    type,
  }: {
    orderBy?: 'updatedAt';
    includeFullyRead?: boolean;
    type?: Unread['type'];
  } = {}) => {
    return client.query.unreads.findMany({
      where: and(
        type ? eq($unreads.type, type) : undefined,
        includeFullyRead ? undefined : gt($unreads.count, 0)
      ),
      orderBy: orderBy === 'updatedAt' ? desc($unreads.updatedAt) : undefined,
    });
  },
  ['unreads']
);

export const getAllUnreadsCounts = createReadQuery(
  'getAllUnreadCounts',
  async () => {
    const [channelUnreadCount, dmUnreadCount] = await Promise.all([
      getUnreadsCount({ type: 'channel' }),
      getUnreadsCount({ type: 'dm' }),
    ]);
    return {
      channels: channelUnreadCount ?? 0,
      dms: dmUnreadCount ?? 0,
      total: (channelUnreadCount ?? 0) + (dmUnreadCount ?? 0),
    };
  },
  ['unreads']
);

export const getChannel = createReadQuery(
  'getChannel',
  async ({ id, includeMembers }: { id: string; includeMembers?: boolean }) => {
    return client.query.channels.findFirst({
      where: eq($channels.id, id),
      with: {
        ...(includeMembers ? { members: { with: { contact: true } } } : {}),
      },
    });
  },
  ['channels']
);

export const getChannelWithLastPostAndMembers = createReadQuery(
  'getChannelWithLastPostAndMembers',
  async ({
    id,
  }: {
    id: string;
  }): Promise<ChannelWithLastPostAndMembers | undefined> => {
    return await client.query.channels.findFirst({
      where: eq($channels.id, id),
      with: {
        lastPost: true,
        members: {
          with: {
            contact: true,
          },
        },
      },
    });
  },
  ['channels']
);

export const getStaleChannels = createReadQuery(
  'getStaleChannels',
  async () => {
    return client
      .select({
        ...getTableColumns($channels),
        unread: getTableColumns($unreads),
      })
      .from($channels)
      .innerJoin($unreads, eq($unreads.channelId, $channels.id))
      .where(
        or(
          isNull($channels.lastPostAt),
          lt($channels.remoteUpdatedAt, $unreads.updatedAt)
        )
      )
      .leftJoin(
        $pins,
        or(eq($pins.itemId, $channels.id), eq($pins.itemId, $channels.groupId))
      )
      .orderBy(ascNullsLast($pins.index), desc($unreads.updatedAt));
  },
  ['channels']
);

export const insertChannels = createWriteQuery(
  'insertChannels',
  async (channels: ChannelInsert[]) => {
    return client.transaction(async (tx) => {
      await client
        .insert($channels)
        .values(channels)
        .onConflictDoUpdate({
          target: $channels.id,
          set: conflictUpdateSetAll($posts),
        });
      for (let channel of channels) {
        if (channel.members) {
          await client
            .delete($chatMembers)
            .where(eq($chatMembers.chatId, channel.id));
          await client.insert($chatMembers).values(channel.members);
        }
      }
    });
  },
  ['channels']
);

export const updateChannel = createWriteQuery(
  'updateChannel',
  (update: Partial<ChannelInsert> & { id: string }) => {
    if (update.type) {
      console.log('update channel type', update.id, update.type);
    }
    return client
      .update($channels)
      .set(update)
      .where(eq($channels.id, update.id));
  },
  ['channels']
);

export const setJoinedGroupChannels = createWriteQuery(
  'setJoinedGroupChannels',
  async ({ channelIds }: { channelIds: string[] }) => {
    return await client
      .update($channels)
      .set({
        currentUserIsMember: inArray($channels.id, channelIds),
      })
      .where(isNotNull($channels.groupId));
  },
  ['channels']
);

export const getChannelPosts = createReadQuery(
  'getChannelPosts',
  async ({ channelId }: { channelId: string }) => {
    return client.query.posts.findMany({
      where: eq($posts.channelId, channelId),
      with: {
        author: true,
        reactions: true,
      },
    });
  },
  ['posts', 'channels']
);

export const getChannelPostsAround = createReadQuery(
  'getChannelPosts',
  async ({ channelId, postId }: { channelId: string; postId: string }) => {
    if (!postId) return [];

    // Get desired post
    const referencePost = await client.query.posts.findFirst({
      where: eq($posts.id, postId),
      with: {
        author: true,
        reactions: true,
      },
    });

    if (!referencePost) {
      throw new Error('Reference post not found');
    }

    const sentAt = referencePost.sentAt;

    // Get before posts
    const beforePosts = await client.query.posts.findMany({
      where: and(eq($posts.channelId, channelId), lt($posts.sentAt, sentAt!)),
      orderBy: [desc($posts.sentAt)],
      limit: 25,
      with: {
        author: true,
        reactions: true,
      },
    });

    // Get after posts
    const afterPosts = await client.query.posts.findMany({
      where: and(eq($posts.channelId, channelId), gt($posts.sentAt, sentAt!)),
      orderBy: [asc($posts.sentAt)],
      limit: 25,
      with: {
        author: true,
        reactions: true,
      },
    });

    // Return all posts in order
    return [...beforePosts.reverse(), referencePost, ...afterPosts];
  },
  ['posts', 'channels']
);

export const getChannelSearchResults = createReadQuery(
  'getChannelSearchResults',
  async (channelId: string, postIds: string[]) => {
    if (postIds.length === 0) return [];
    return client.query.posts.findMany({
      where: and(eq($posts.channelId, channelId), inArray($posts.id, postIds)),
      orderBy: [desc($posts.sentAt)],
      with: {
        author: true,
        reactions: true,
      },
    });
  },
  []
);

export const insertChannelPosts = createWriteQuery(
  'insertChannelPosts',
  async (channelId: string, posts: PostInsert[]) => {
    if (!posts.length) {
      return;
    }
    return client.transaction(async (tx) => {
      const lastPost = posts[posts.length - 1];
      // Update last post meta for the channel these posts belong to,
      // Also grab that channels groupId for updating the group's lastPostAt and
      // associating the posts with the group.
      const updatedChannels = await tx
        .update($channels)
        .set({ lastPostId: lastPost.id, lastPostAt: lastPost.receivedAt })
        .where(
          and(
            eq($channels.id, channelId),
            or(
              isNull($channels.lastPostAt),
              lt($channels.lastPostAt, lastPost.receivedAt ?? 0)
            )
          )
        )
        .returning({ groupId: $channels.groupId });
      // Update group if we found one.
      const groupId = updatedChannels[0]?.groupId;
      if (groupId) {
        await tx
          .update($groups)
          .set({ lastPostId: lastPost.id, lastPostAt: lastPost.receivedAt })
          .where(
            and(
              eq($groups.id, groupId),
              or(
                isNull($groups.lastPostAt),
                lt($groups.lastPostAt, lastPost.receivedAt ?? 0)
              )
            )
          );
      }
      // Actually insert posts, overwriting any existing posts with the same id.
      await tx
        .insert($posts)
        .values(posts.map((p) => ({ ...p, groupId, channelId })))
        .onConflictDoUpdate({
          target: $posts.id,
          set: conflictUpdateSetAll($posts),
        });
    });
  },
  ['posts', 'channels', 'groups']
);

export const deletePosts = createWriteQuery(
  'deletePosts',
  async ({ ids }: { ids: string[] }) => {
    return client.delete($posts).where(inArray($posts.id, ids));
  },
  ['posts']
);

export const getPosts = createReadQuery(
  'getPosts',
  () => {
    return client.select().from($posts);
  },
  ['posts']
);

export const getGroup = createReadQuery(
  'getGroup',
  async ({ id }: { id: string }) => {
    return client.query.groups.findFirst({
      where: (groups, { eq }) => eq(groups.id, id),
      with: {
        channels: {
          where: (channels, { eq }) => eq(channels.currentUserIsMember, true),
          with: {
            lastPost: true,
            unread: true,
          },
        },
        roles: true,
        members: true,
        navSections: {
          with: {
            channels: true,
          },
        },
      },
    });
  },
  ['groups']
);

export const getGroupByChannel = createReadQuery(
  'getGroupByChannel',
  async (channelId: string) => {
    const channel = await client.query.channels.findFirst({
      where: (channels, { eq }) => eq(channels.id, channelId),
    });

    if (!channel || !channel.groupId) return null;

    return client.query.groups.findFirst({
      where: (groups, { eq }) => eq(groups.id, channel.groupId!),
      with: {
        channels: true,
        roles: true,
        members: true,
      },
    });
  },
  ['channels', 'groups']
);

export const getContacts = createReadQuery(
  'getContacts',
  async () => {
    return client.query.contacts.findMany({
      with: {
        pinnedGroups: {
          with: {
            group: true,
          },
        },
      },
    });
  },
  ['contacts']
);

export const getContactsBatch = createReadQuery(
  'getContactsBatch',
  async ({ contactIds }: { contactIds: string[] }) => {
    return client.query.contacts.findMany({
      where: (contacts, { inArray }) => inArray(contacts.id, contactIds),
    });
  },
  ['contacts']
);

export const getContactsCount = createReadQuery(
  'getContactsCount',
  async () => {
    const result = await client.select({ count: count() }).from($contacts);
    return result[0].count;
  },
  ['contacts']
);

export const getContact = createReadQuery(
  'getContact',
  async ({ id }: { id: string }) => {
    return client.query.contacts.findFirst({
      where: (contacts, { eq }) => eq(contacts.id, id),
    });
  },
  ['contacts']
);

export const insertContact = createWriteQuery(
  'insertContact',
  async (contact: ContactInsert) => {
    return client
      .insert($contacts)
      .values(contact)
      .onConflictDoUpdate({
        target: $contacts.id,
        set: conflictUpdateSetAll($contacts),
      });
  },
  ['contacts']
);

export const insertContacts = createWriteQuery(
  'insertContacts',
  async (contactsData: ContactInsert[]) => {
    const contactGroups = contactsData.flatMap(
      (contact) => contact.pinnedGroups || []
    );
    const targetGroups = contactGroups.map(
      (g): GroupInsert => ({
        id: g.groupId,
        isSecret: false,
      })
    );
    await client
      .insert($contacts)
      .values(contactsData)
      .onConflictDoUpdate({
        target: $contacts.id,
        set: conflictUpdateSetAll($contacts),
      });
    if (targetGroups.length) {
      await client.insert($groups).values(targetGroups).onConflictDoNothing();
    }
    // TODO: Remove stale pinned groups
    await client
      .insert($contactGroups)
      .values(contactGroups)
      .onConflictDoNothing();
  },
  ['contacts', 'groups', 'contactGroups']
);

export const insertUnreads = createWriteQuery(
  'insertUnreads',
  async (unreads: UnreadInsert[]) => {
    return client.transaction(() => {
      return client
        .insert($unreads)
        .values(unreads)
        .onConflictDoUpdate({
          target: [$unreads.channelId],
          set: conflictUpdateSetAll($unreads),
        });
    });
  },
  ['unreads']
);

export const insertPinnedItems = createWriteQuery(
  'insertPinnedItems',
  async (pinnedItems: Pin[]) => {
    return client.transaction(async (tx) => {
      await tx.delete($pins);
      // users may not have pinned items
      if (!pinnedItems.length) return;
      await tx.insert($pins).values(pinnedItems);
    });
  },
  ['pins', 'groups']
);

export const getPinnedItems = createReadQuery(
  'getPinnedItems',
  async (params?: { orderBy?: keyof Pin; direction?: 'asc' | 'desc' }) => {
    return client.query.pins.findMany({
      orderBy: params?.orderBy
        ? (pins, { asc, desc }) => [
            (params.direction === 'asc' ? asc : desc)(pins[params.orderBy!]),
          ]
        : undefined,
    });
  },
  ['pins']
);

// Helpers

function conflictUpdateSetAll(table: Table) {
  const columns = getTableColumns(table);
  return conflictUpdateSet(...Object.values(columns));
}

function conflictUpdateSet(...columns: Column[]) {
  return Object.fromEntries(
    columns.map((c) => [toCamelCase(c.name), sql.raw(`excluded.${c.name}`)])
  );
}

function ascNullsLast(column: SQLWrapper | AnyColumn) {
  return sql`${column} ASC NULLS LAST`;
}

function toCamelCase(str: string) {
  return str.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
}