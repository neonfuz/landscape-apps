/-  a=activity, c=channels, h=hark
/+  cu=channel-utils
::
|%
++  event-to-yarn
  |=  [our=@p now=@da =time-id:a =event:a]
  ^-  (unit yarn:h)
  ?:  ?=(%chan-init -<.event)
    ~  ::  no hark precedent
  ?:  ?=(?(%flag-post %flag-reply) -<.event)
    ~  ::  not generated by any agent
  %-  some
  |^  =/  =rope:h
        ?-  -<.event
            %post
          =,  event
          :^  `group  `channel  %groups
          (channel-path channel q.id.key ~)
        ::
            %reply
          =,  event
          :^  `group  `channel  %groups
          (channel-path channel q.id.parent `q.id.key)
        ::
            %dm-invite
          [~ ~ %groups (whom-path whom.event)]
        ::
            %dm-post
          [~ ~ %groups (whom-path whom.event)]
        ::
            %dm-reply
          [~ ~ %groups (whom-path whom.event)]
        ::
            %group-ask
          =*  g  group.event
          [`g ~ %groups /(scot %p p.g)/[q.g]/asks]
        ::
            %group-invite
          =*  g  group.event
          [`g ~ %groups /(scot %p p.g)/[q.g]/invites]
        ::
            %group-join
          =*  g  group.event
          [`g ~ %groups /(scot %p p.g)/[q.g]/joins]
        ::
            %group-kick
          =*  g  group.event
          [`g ~ %groups /(scot %p p.g)/[q.g]/leaves]
        ::
            %group-role
          =*  g  group.event
          [`g ~ %groups /(scot %p p.g)/[q.g]/add-roles]
        ==
      :*  `@`time-id
          rope
          time-id
        ::
          ^-  (list content:h)
          ?-  -<.event
              %post
            =,  -.event
            :~  [%ship p.id.key]
                ?:(mention ' mentioned you: ' ' sent a message: ')
                (flatten:cu content)
            ==
          ::
              %reply
            =,  -.event
            ?:  mention
              :~  [%ship p.id.key]
                  ' mentioned you: '
                  (flatten:cu content)
              ==
            =*  diary-contents
              :~  [%ship p.id.key]  ' commented on '
                  [%emph 'a notebook post']   ': '  ::REVIEW  don't have access to title.kind-data
                  [%ship p.id.key]  ': '
                  (flatten:cu content)
              ==
            =*  heap-contents
              :~  [%ship p.id.key]  ' commented on '
                  [%emph 'a collection item']   ': '  ::REVIEW  don't have access to title.kind-data
                  [%ship p.id.key]  ': '
                  (flatten:cu content)
              ==
            ?:  =(p.id.parent our)
              ?-  kind.channel.event
                  %diary  diary-contents
                  %heap   heap-contents
                  %chat
                :~  [%ship p.id.key]
                    ' replied to you: '
                    (flatten:cu content)
                ==
              ==
            ?-  kind.channel.event
                %diary  diary-contents
                %heap   heap-contents
                %chat
              :~  [%ship p.id.key]
                  ' sent a message: '
                  (flatten:cu content)
              ==
            ==
          ::
              %dm-invite
            ::REVIEW  'author.memo has invited you to a direct message'
            ::TODO    maybe want [%dm-invite =whom from=@p]
            :~  'Someone'
                ' has invited you to a direct message'
            ==
          ::
              %dm-post
            ::REVIEW  should maybe not be rendered if you haven't accepted
            :~  [%ship p.id.key.event]
                ': '
                (flatten:cu content.event)
            ==
          ::
              %dm-reply
            ::REVIEW  should maybe not be rendered if you haven't accepted
            :~  [%ship p.id.key.event]
                ': '
                (flatten:cu content.event)
            ==
          ::
              ?(%group-ask %group-invite %group-join %group-kick %group-role)
            =+  .^  =group:g:a  %gx
                  (scot %p our)
                  %groups
                  (scot %da now)
                  /groups/(scot %p p.group.event)/[q.group.event]/group
                ==
            ?-  -<.event
                %group-ask
              :~  [%ship ship.event]
                  ' has requested to join '
                  [%emph title.meta.group]
              ==
            ::
                %group-invite
              :~  [%ship ship.event]
                  ' sent you an invite to '
                  [%emph title.meta.group]
              ==
            ::
                %group-join
              :~  [%ship ship.event]
                  ' has joined '
                  [%emph title.meta.group]
              ==
            ::
                %group-kick
              :~  [%ship ship.event]
                  ' has left '
                  [%emph title.meta.group]
              ==
            ::
                %group-role
              =;  role-list
                :~  [%ship ship.event]
                    ' is now a(n) '
                    [%emph role-list]
                ==
              %-  crip
              %+  join  ', '
              %+  turn
                ~(tap in roles.event)
              |=  =sect:g:a
              ?.  (~(has by cabals.group) sect)  sect
              =/  cabal  (~(got by cabals.group) sect)
              title.meta.cabal
            ==
          ==
        ::
          ?-  -<.event
            %post   (welp (group-path group.event) %channels ted.rope)
            %reply  (welp (group-path group.event) %channels ted.rope)
          ::
              %dm-invite
            (dm-path whom.event)
          ::
            %dm-post  (dm-path whom.event)
          ::
              %dm-reply
            ::REVIEW
            (weld (dm-path whom.event) /message/(scot %p p.id.parent.event)/(scot %ud q.id.parent.event))
          ::
            %group-ask     (weld (group-path group.event) /edit/members)
            %group-invite  /find
            %group-join    (weld (group-path group.event) /edit/members)
            %group-kick    (weld (group-path group.event) /edit/members)
            %group-role    (weld (group-path group.event) /edit/members)
          ==
        ::
          ~
      ==
  ::
  ++  channel-path
    |=  [=nest:c =id-post:c id-reply=(unit id-reply:c)]
    ^-  path
    %+  weld
      `path`/[kind.nest]/(scot %p ship.nest)/[name.nest]
    =;  base=path
      ?~  id-reply  base
      (snoc base (rsh 4 (scot %ui u.id-reply)))
    ?-  kind.nest  ::REVIEW  technically want the -.kind-data of the post...
      %diary  /note/(rsh 4 (scot %ui id-post))
      %heap   /curio/(rsh 4 (scot %ui id-post))
      %chat   /message/(rsh 4 (scot %ui id-post))
    ==
  ::
  ++  group-path
    |=  group=flag:g:c
    /groups/(scot %p p.group)/[q.group]
  ::
  ++  whom-path
    |=  =whom:a
    ?-  -.whom
      %ship  /dm/(scot %p p.whom)
      %club  /club/(scot %uv p.whom)
    ==
  ::
  ++  dm-path
    |=  =whom:a
    =;  id=@ta  /dm/[id]
    ?-  -.whom
      %ship  (scot %p p.whom)
      %club  (scot %uv p.whom)
    ==
  --
--