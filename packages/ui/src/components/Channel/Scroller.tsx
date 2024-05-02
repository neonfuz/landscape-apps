import * as db from '@tloncorp/shared/dist/db';
import { isSameDay } from '@tloncorp/shared/dist/logic';
import { MotiView } from 'moti';
import {
  PropsWithChildren,
  ReactNode,
  RefObject,
  createRef,
  forwardRef,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react';
import {
  Dimensions,
  FlatList,
  ListRenderItem,
  View as RNView,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { useStyle } from 'tamagui';

import { ArrowDown } from '../../assets/icons';
import { Modal, View, XStack } from '../../core';
import { Button } from '../Button';
import { ChatMessageActions } from '../ChatMessage/ChatMessageActions/Component';
import { ChannelDivider } from './ChannelDivider';

export default function Scroller({
  inverted,
  postComponent,
  posts,
  currentUserId,
  channelType,
  unreadCount,
  firstUnread,
  setInputShouldBlur,
  selectedPost,
  onStartReached,
  onEndReached,
  onPressImage,
  onPressReplies,
  showReplies = true,
}: {
  inverted: boolean;
  postComponent: (props: {
    currentUserId: string;
    post: db.Post;
    showAuthor?: boolean;
    showReplies?: boolean;
    onPressReplies?: (post: db.Post) => void;
    onPressImage?: (post: db.Post, imageUri?: string) => void;
    onLongPress?: (post: db.Post) => void;
  }) => ReactNode | null;
  posts: db.Post[];
  currentUserId: string;
  channelType: db.ChannelType;
  unreadCount?: number;
  firstUnread?: string;
  setInputShouldBlur?: (shouldBlur: boolean) => void;
  selectedPost?: string;
  onStartReached?: () => void;
  onEndReached?: () => void;
  onPressImage?: (post: db.Post, imageUri?: string) => void;
  onPressReplies?: (post: db.Post) => void;
  showReplies?: boolean;
}) {
  const PostComponent = postComponent;
  const [hasPressedGoToBottom, setHasPressedGoToBottom] = useState(false);
  const flatListRef = useRef<FlatList<db.Post>>(null);

  const pressedGoToBottom = () => {
    setHasPressedGoToBottom(true);
    if (flatListRef.current) {
      flatListRef.current.scrollToOffset({ offset: 0, animated: true });
    }
  };

  useEffect(() => {
    if (firstUnread && flatListRef.current) {
      console.log(
        'scrolling to',
        firstUnread,
        posts.findIndex((post) => post.id === firstUnread)
      );
      const unreadIndex = posts.findIndex((post) => post.id === firstUnread);
      if (unreadIndex !== -1) {
        flatListRef.current.scrollToIndex({
          index: unreadIndex,
          animated: true,
        });
      }
    }
  }, [firstUnread, posts]);

  useEffect(() => {
    if (selectedPost && flatListRef.current) {
      const scrollToIndex = posts.findIndex((post) => post.id === selectedPost);
      if (scrollToIndex > -1) {
        flatListRef.current.scrollToIndex({
          index: scrollToIndex,
          animated: true,
        });
      }
    }
  }, [selectedPost, posts]);

  const [activeMessage, setActiveMessage] = useState<db.Post | null>(null);
  const activeMessageRefs = useRef<Record<string, RefObject<RNView>>>({});

  const handleSetActive = useCallback((active: db.Post) => {
    if (active.type !== 'notice') {
      activeMessageRefs.current[active.id] = createRef();
      setActiveMessage(active);
    }
  }, []);

  const handlePostLongPressed = useCallback(
    (post: db.Post) => {
      handleSetActive(post);
    },
    [handleSetActive]
  );

  const renderItem: ListRenderItem<db.Post> = useCallback(
    ({ item, index }) => {
      const previousItem = posts[index + 1];
      const isFirstPostOfDay = !isSameDay(
        item.receivedAt ?? 0,
        previousItem?.receivedAt ?? 0
      );
      const showAuthor =
        previousItem?.authorId !== item.authorId ||
        previousItem?.type === 'notice' ||
        (item.replyCount ?? 0) > 0 ||
        isFirstPostOfDay;
      const isFirstUnread = !!unreadCount && item.id === firstUnread;
      return (
        <>
          {isFirstUnread ? (
            <ChannelDivider
              timestamp={item.receivedAt}
              unreadCount={unreadCount ?? 0}
            />
          ) : isFirstPostOfDay && item.type === 'chat' ? (
            <ChannelDivider unreadCount={0} timestamp={item.receivedAt} />
          ) : null}
          <PressableMessage
            ref={activeMessageRefs.current[item.id]}
            isActive={activeMessage?.id === item.id}
          >
            {/* ts may yell at you in the editor, but this is fine */}
            <PostComponent
              currentUserId={currentUserId}
              post={item}
              showAuthor={showAuthor}
              showReplies={showReplies}
              onPressReplies={onPressReplies}
              onPressImage={onPressImage}
              onLongPress={handlePostLongPressed}
            />
          </PressableMessage>
        </>
      );
    },
    [
      PostComponent,
      activeMessage,
      showReplies,
      firstUnread,
      onPressReplies,
      unreadCount,
      currentUserId,
      onPressImage,
      posts,
      handlePostLongPressed,
    ]
  );

  const handleScrollToIndexFailed = useCallback(
    ({ index }: { index: number }) => {
      console.log('scroll to index failed');
      const wait = new Promise((resolve) => setTimeout(resolve, 100));
      wait.then(() => {
        flatListRef.current?.scrollToIndex({
          index,
          animated: false,
        });
      });
    },
    []
  );

  const contentContainerStyle = useStyle({
    paddingHorizontal: '$m',
  }) as StyleProp<ViewStyle>;

  const handleContainerPressed = useCallback(() => {
    setInputShouldBlur?.(true);
  }, []);

  return (
    <View flex={1}>
      {unreadCount && !hasPressedGoToBottom ? (
        <UnreadsButton onPress={pressedGoToBottom} />
      ) : null}
      <FlatList<db.Post>
        ref={flatListRef}
        data={posts}
        renderItem={renderItem}
        keyExtractor={getPostId}
        keyboardDismissMode="on-drag"
        contentContainerStyle={contentContainerStyle}
        onScrollBeginDrag={handleContainerPressed}
        onScrollToIndexFailed={handleScrollToIndexFailed}
        inverted={inverted}
        onEndReached={onEndReached}
        onEndReachedThreshold={2}
        onStartReached={onStartReached}
      />
      <Modal
        visible={activeMessage !== null}
        onDismiss={() => setActiveMessage(null)}
      >
        {activeMessage !== null && (
          <ChatMessageActions
            currentUserId={currentUserId}
            post={activeMessage}
            postRef={activeMessageRefs.current[activeMessage!.id]}
            onDismiss={() => setActiveMessage(null)}
            channelType={channelType}
          />
        )}
      </Modal>
    </View>
  );
}

function getPostId(post: db.Post) {
  return post.id;
}

const PressableMessage = forwardRef<
  RNView,
  PropsWithChildren<{ isActive: boolean }>
  // ts in the editor may tell you this is an error, but this is fine
>(function PressableMessageComponent({ isActive, children }, ref) {
  return isActive ? (
    // need the extra React Native View for ref measurement
    <MotiView
      animate={{
        scale: 0.95,
      }}
      transition={{
        scale: {
          type: 'timing',
          duration: 50,
        },
      }}
    >
      <RNView ref={ref}>{children}</RNView>
    </MotiView>
  ) : (
    children
  );
});

const UnreadsButton = ({ onPress }: { onPress: () => void }) => {
  return (
    <XStack
      position="absolute"
      bottom="5%"
      left={Dimensions.get('window').width / 2 - 60}
      zIndex={50}
      width="40%"
    >
      <Button
        backgroundColor="$blueSoft"
        padding="$s"
        borderRadius="$l"
        height="$4xl"
        width="100%"
        alignItems="center"
        onPress={onPress}
        size="$s"
      >
        <Button.Text>Scroll to latest</Button.Text>
        <Button.Icon>
          <XStack width="$s" height="$s">
            <ArrowDown />
          </XStack>
        </Button.Icon>
      </Button>
    </XStack>
  );
};
