import { useNavigationState } from '@react-navigation/native';
import * as store from '@tloncorp/shared/dist/store';
import { AvatarNavIcon, NavBar, NavIcon } from '@tloncorp/ui';

import { useCurrentUserId } from '../hooks/useCurrentUser';

const NavBarView = (props: { navigation: any }) => {
  const state = useNavigationState((state) => state);
  const isRouteActive = (routeName: string) => {
    return state.routes[state.index].name === routeName;
  };
  const { data: unreadCount } = store.useUnreadsCount();
  const currentUserId = useCurrentUserId();
  const { data: contact } = store.useContact({ id: currentUserId });

  return (
    <NavBar>
      <NavIcon
        type="Home"
        activeType="HomeFilled"
        isActive={isRouteActive('ChatList')}
        hasUnreads={(unreadCount ?? 0) > 0}
        onPress={() => props.navigation.navigate('ChatList')}
      />
      <NavIcon
        type="Notifications"
        activeType="NotificationsFilled"
        hasUnreads={false}
        isActive={isRouteActive('Activity')}
        onPress={() => props.navigation.navigate('Activity')}
      />
      <AvatarNavIcon
        id={currentUserId}
        contact={contact}
        focused={isRouteActive('Settings')}
        onPress={() => props.navigation.navigate('Settings')}
      />
    </NavBar>
  );
};

export default NavBarView;