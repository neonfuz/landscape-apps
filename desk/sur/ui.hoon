/-  g=groups, c=chat, d=diary, h=heap
|%
+$  init
  $:  =groups:g
      =gangs:g
      =chat
      =heap
      =diary    
  ==
::
+$  init-0
  $:  groups=groups-ui:g
      =gangs:g
      =chat
      =heap
      =diary    
  ==
::
+$  chat
  $:  =briefs:c
      chats=(map flag:c chat:c)
      pins=(list whom:c)
  ==
::
+$  heap
  $:  =briefs:h
      =stash:h
  ==
::
+$  diary
  $:  =briefs:d
      shelf=rr-shelf:d
  ==
::
+$  imported  (map flag:g ?)
::
+$  migration
  $:  chat-imports=imported
      heap-imports=imported
      diary-imports=imported
      wait=(list ship)
  ==
::
+$  vita-enabled  ?
--