import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Text } from '@tloncorp/ui';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GroupSettingsStackParamList } from '../../types';
import { useGroupContext } from './useGroupContext';

type GroupMetaScreenProps = NativeStackScreenProps<
  GroupSettingsStackParamList,
  'GroupMeta'
>;

export function GroupMetaScreen(props: GroupMetaScreenProps) {
  const { groupId } = props.route.params;

  const { group, currentUserIsAdmin, setGroupMetadata } = useGroupContext({
    groupId,
  });

  return (
    <SafeAreaView>
      <Text>GroupMeta</Text>
    </SafeAreaView>
  );
}