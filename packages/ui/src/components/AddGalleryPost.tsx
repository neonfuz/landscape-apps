import { ImagePickerAsset } from 'expo-image-picker';
import { useCallback, useState } from 'react';

import { useAttachmentContext } from '../contexts/attachment';
import { SimpleActionSheet } from './ActionSheet';
import AttachmentSheet from './AttachmentSheet';

export default function AddGalleryPost({
  showAddGalleryPost,
  setShowAddGalleryPost,
  setShowGalleryInput,
  onSetImage,
}: {
  showAddGalleryPost: boolean;
  setShowAddGalleryPost: (show: boolean) => void;
  setShowGalleryInput: (show: boolean) => void;
  onSetImage: (assets: ImagePickerAsset[]) => void;
}) {
  const { attachAssets } = useAttachmentContext();
  const [showAttachmentSheet, setShowAttachmentSheet] = useState(false);

  const actions = [
    {
      title: 'Photo or Video',
      action: () => {
        setShowAddGalleryPost(false);
        setShowAttachmentSheet(true);
      },
    },
    {
      title: 'Rich Text',
      action: () => {
        setShowAddGalleryPost(false);
        setShowGalleryInput(true);
      },
    },
  ];

  const handleImageSet = useCallback(
    (assets: ImagePickerAsset[]) => {
      attachAssets(assets);
      onSetImage(assets);
    },
    [attachAssets, onSetImage]
  );

  return (
    <>
      <SimpleActionSheet
        open={showAddGalleryPost}
        onOpenChange={setShowAddGalleryPost}
        actions={actions}
      />
      <AttachmentSheet
        showAttachmentSheet={showAttachmentSheet}
        setShowAttachmentSheet={setShowAttachmentSheet}
        setImage={handleImageSet}
      />
    </>
  );
}
