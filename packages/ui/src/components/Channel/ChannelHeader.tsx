import {
  Channel as ChannelIcon,
  ChevronLeft,
  Search,
} from '../../assets/icons';
import { SizableText, XStack } from '../../core';
import { IconButton } from '../IconButton';

export function ChannelHeader({
  title,
  goBack,
  goToChannels,
  goToSearch,
  showPickerButton,
}: {
  title: string;
  goBack: () => void;
  goToChannels: () => void;
  goToSearch: () => void;
  showPickerButton?: boolean;
}) {
  return (
    <XStack
      justifyContent="space-between"
      alignItems="center"
      paddingVertical="$m"
      paddingHorizontal="$xl"
      gap="$m"
      borderBottomWidth={1}
      borderBottomColor="$border"
      height="$4xl"
    >
      <XStack alignItems="center" gap="$m">
        <IconButton onPress={goBack}>
          <ChevronLeft />
        </IconButton>
        <SizableText color="$primaryText" size="$m">
          {title}
        </SizableText>
      </XStack>
      <XStack gap="$m">
        <IconButton onPress={goToSearch}>
          <Search />
        </IconButton>
        {showPickerButton && (
          <IconButton onPress={goToChannels}>
            <ChannelIcon />
          </IconButton>
        )}
      </XStack>
    </XStack>
  );
}