import { useState } from 'react';
import cn from 'classnames';
import WidgetDrawer from '@/components/WidgetDrawer';
import HomeIconMobileNav from '@/components/icons/HomeIconMobileNav';
import NewRaysIcon from '@/components/icons/NewRaysIcon';
import { isNativeApp } from '@/logic/native';
import JoinGroup from './AddGroupSheet/JoinGroup';
import CreateGroup from './AddGroupSheet/CreateGroup';

function CreateOrJoin(props: { onCreate: () => void; onJoin: () => void }) {
  return (
    <div className="flex w-full flex-col items-center pb-4">
      <h3 className="mb-6 mt-4 text-[17px] ">Add a group</h3>
      <div className="flex flex-col rounded-lg border border-gray-100">
        <button
          className="flex items-center border-b border-gray-100 px-6 py-4 active:bg-blue-100"
          onClick={props.onJoin}
        >
          <HomeIconMobileNav className="mr-4 h-6 w-6" isInactive asIcon />
          <div className="flex flex-col items-start">
            <h4 className="mb-1.5 text-[17px] tracking-wide">Join a group</h4>
            <p className="text-gray-300">
              Join with short code or host's Urbit ID
            </p>
          </div>
        </button>
        <button
          className="flex items-center px-6 py-4 text-blue active:bg-blue-100"
          onClick={props.onCreate}
        >
          <NewRaysIcon className="mr-4 h-6 w-6" />
          <div className="flex flex-col items-start">
            <h4 className="mb-1.5 text-[17px] tracking-wide">
              Create new group
            </h4>
            <p className="text-gray-300">Start a group from scratch</p>
          </div>
        </button>
      </div>
    </div>
  );
}

export default function AddGroupSheet(props: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const [view, setView] = useState<'root' | 'create' | 'join'>('root');

  const onOpenChange = (open: boolean) => {
    if (!open) {
      setView('root');
    }
    if (props.onOpenChange) {
      props.onOpenChange(open);
    }
  };

  const delayedViewNav = (newView: 'root' | 'create' | 'join') => {
    setTimeout(() => {
      setView(newView);
    }, 100);
  };

  return (
    <WidgetDrawer
      open={props.open}
      onOpenChange={onOpenChange}
      className={cn('px-6', view === 'root' && 'h-[30vh]!')}
      withGrabber={true}
    >
      <div className="mt-4">
        {view === 'root' && (
          <CreateOrJoin
            onCreate={() => delayedViewNav('create')}
            onJoin={() => delayedViewNav('join')}
          />
        )}
        {view === 'create' && <CreateGroup back={() => setView('root')} />}
        {view === 'join' && (
          <JoinGroup back={() => setView('root')} onOpenChange={onOpenChange} />
        )}
      </div>
      {!isNativeApp() && <div className="pb-6" />}
    </WidgetDrawer>
  );
}
