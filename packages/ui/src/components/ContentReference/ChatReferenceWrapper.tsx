import { useNavigation } from '../../contexts';
import { useRequests } from '../../contexts/requests';
import { PostViewMode } from '../ContentRenderer';
import ChatReference from './ChatReference';
import ReferenceSkeleton from './ReferenceSkeleton';

export default function ChatReferenceWrapper({
  channelId,
  postId,
  replyId,
  asAttachment = false,
  viewMode = 'chat',
}: {
  channelId: string;
  postId: string;
  replyId?: string;
  asAttachment?: boolean;
  viewMode?: PostViewMode;
}) {
  const { usePost, useChannel } = useRequests();
  const {
    data: post,
    isError,
    error,
    isLoading,
  } = usePost({ id: replyId ? replyId : postId });
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
      viewMode={viewMode}
    />
  );
}
