import { Button } from '../components/Button';
import { SizeTokens } from '../core';

export function IconButton({
  children,
  onPress,
  size = '$s',
  ...props
}: {
  children: React.ReactNode;
  onPress?: () => void;
  size?: SizeTokens;
}) {
  return (
    <Button
      size={size}
      width="$3xl"
      height="$3xl"
      onPress={onPress}
      // borderWidth="unset" because otherwise it would be set to 1px
      // and we don't want that for an icon button
      borderWidth="unset"
    >
      <Button.Icon>{children}</Button.Icon>
    </Button>
  );
}
