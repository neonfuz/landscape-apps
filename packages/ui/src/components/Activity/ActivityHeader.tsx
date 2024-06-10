import React from 'react';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { SizableText, View, XStack } from '../../core';
import Pressable from '../Pressable';

export type ActivityTab = 'all' | 'threads' | 'mentions';

function ActivityHeaderRaw({
  activeTab,
  onTabPress,
}: {
  activeTab: ActivityTab;
  onTabPress: (tab: ActivityTab) => void;
}) {
  const insets = useSafeAreaInsets();
  return (
    <View paddingTop={insets.top}>
      <XStack justifyContent="center" paddingVertical="$m">
        <SizableText size="$l" fontWeight="500">
          Activity
        </SizableText>
      </XStack>
      <XStack>
        <XStack
          flexGrow={1}
          borderBottomWidth={activeTab === 'all' ? 1 : 0}
          borderColor="$primaryText"
          justifyContent="center"
        >
          <Pressable
            disabled={activeTab === 'all'}
            onPress={() => onTabPress('all')}
          >
            <SizableText
              width={100}
              textAlign="center"
              paddingVertical="$m"
              color={activeTab === 'all' ? '$primaryText' : '$secondaryText'}
            >
              All
            </SizableText>
          </Pressable>
        </XStack>
        <XStack
          flexGrow={1}
          borderBottomWidth={activeTab === 'mentions' ? 1 : 0}
          borderColor="$primaryText"
          justifyContent="center"
        >
          <Pressable
            disabled={activeTab === 'mentions'}
            onPress={() => onTabPress('mentions')}
          >
            <SizableText
              width={100}
              textAlign="center"
              paddingVertical="$m"
              color={
                activeTab === 'mentions' ? '$primaryText' : '$secondaryText'
              }
            >
              Mentions
            </SizableText>
          </Pressable>
        </XStack>
        <XStack
          flexGrow={1}
          borderBottomWidth={activeTab === 'threads' ? 1 : 0}
          borderColor="$primaryText"
          justifyContent="center"
        >
          <Pressable
            disabled={activeTab === 'threads'}
            onPress={() => onTabPress('threads')}
          >
            <SizableText
              width={100}
              textAlign="center"
              paddingVertical="$m"
              color={
                activeTab === 'threads' ? '$primaryText' : '$secondaryText'
              }
            >
              Replies
            </SizableText>
          </Pressable>
        </XStack>
      </XStack>
    </View>
  );
}
export const ActivityHeader = React.memo(ActivityHeaderRaw);
