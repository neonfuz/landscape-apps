import { useSyncExternalStore } from 'react';

type Session = { startTime: number };
type SessionListener = (session: Session) => void;

let session: Session | null = null;
const sessionListeners: SessionListener[] = [];

export function getSession() {
  return session;
}

export function updateSession(newSession: Session | null) {
  session = newSession;
}

function subscribeToSession(listener: SessionListener) {
  sessionListeners.push(listener);
  return () => {
    sessionListeners.splice(sessionListeners.indexOf(listener), 1);
  };
}

export function useCurrentSession() {
  return useSyncExternalStore(subscribeToSession, getSession);
}
