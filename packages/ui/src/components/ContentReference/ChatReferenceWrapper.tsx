import { PostContent } from '@tloncorp/shared/dist/api';
import { useMemo } from 'react';

import { useNavigation } from '../../contexts';
import { useRequests } from '../../contexts/requests';
import ChatReference from './ChatReference';
import ReferenceSkeleton from './ReferenceSkeleton';

export default function ChatReferenceWrapper({
  channelId,
  postId,
  asAttachment = false,
  inGalleryPost = false,
}: {
  channelId: string;
  postId: string;
  asAttachment?: boolean;
  inGalleryPost?: boolean;
}) {
  const { usePost, useChannel } = useRequests();
  const { data: post, isError, error, isLoading } = usePost({ id: postId });
  const { data: channel } = useChannel({ id: channelId });

  const { onPressRef } = useNavigation();

  if (isError) {
    return (
      <ReferenceSkeleton
        message={error?.message || 'Error loading content'}
        messageType="error"
      />
    );
  }

  if (!post || !channel) {
    if (isLoading) {
      return <ReferenceSkeleton />;
    }
    return (
      <ReferenceSkeleton
        messageType="not-found"
        message="This content could not be found"
      />
    );
  }

  return (
    <ChatReference
      post={post}
      channel={channel}
      onPress={onPressRef}
      asAttachment={asAttachment}
      inGalleryPost={inGalleryPost}
    />
  );
}
