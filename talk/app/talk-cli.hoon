::  talk-cli: cli chat client using groups' chat
::
::    pulls all known messages into a single stream.
::    type ;help for usage instructions.
::
/-  chat, cite, groups
/+  shoe, default-agent, verb, dbug
::
|%
+$  card  card:shoe
::
+$  state-1
  $:  %1
      sessions=(map sole-id session)                ::  sole sessions
      bound=(map target glyph)                      ::  bound glyphs
      binds=(jug glyph target)                      ::  glyph lookup
      settings=(set term)                           ::  frontend flags
      timez=(pair ? @ud)                            ::  timezone adjustment
  ==
::
+$  sole-id  sole-id:shoe
+$  session
  $:  viewing=(set whom:chat)                       ::  connected targets
      history=(list [whom:chat id:chat])            ::  scrollback pointers
      count=@ud                                     ::  (lent history)
      audience=target                               ::  active target
      width=_80                                     ::  display width
  ==
::
+$  target  whom:chat                               ::  polymorphic id for channels
+$  selection  $@(rel=@ud [zeros=@u abs=@ud])       ::  pointer selection
::
+$  glyph  char
++  glyphs  "!@$%&()-=_+[]\{}'\\:\",.<>?"
::
+$  command
  $%  [%target target]                              ::  set messaging target
      [%say (list inline:chat)]                     ::  send message
      [%reference selection (list inline:chat)]     ::  reference a message
      [%thread selection (list inline:chat)]        ::  reply to a message thread
      :: [%eval cord hoon]                          ::  send #-message
    ::                                              ::
      [%view $?(~ target)]                          ::  notice chat
      [%flee target]                                ::  ignore chat
    ::                                              ::
      [%bind glyph target]                          ::  bind glyph
      [%unbind glyph (unit target)]                 ::  unbind glyph
      [%what (unit $@(char target))]                ::  glyph lookup
    ::                                              ::
      [%settings ~]                                 ::  show active settings
      [%set term]                                   ::  set settings flag
      [%unset term]                                 ::  unset settings flag
      [%width @ud]                                  ::  adjust display width
      [%timezone ? @ud]                             ::  adjust time printing
    ::                                              ::
      [%select selection]                           ::  rel/abs msg selection
      [%chats ~]                                    ::  list available chats
      [%dms ~]                                      ::  list available dms
      [%help ~]                                     ::  print usage info
  ==                                                ::
::
--
=|  state-1
=*  state  -
::
%-  agent:dbug
%+  verb  |
%-  (agent:shoe command)
^-  (shoe:shoe command)
=<
  |_  =bowl:gall
  +*  this       .
      talk-core  +>
      tc         ~(. talk-core bowl)
      def        ~(. (default-agent this %|) bowl)
      des        ~(. (default:shoe this command) bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    [~ this]
  ::
  ++  on-save  !>(state)
  ::
  ++  on-load
    |=  old-state=vase
    |^  ^-  (quip card _this)
        =/  old  !<(versioned-state old-state)
        =^  cards  state
          ?-  -.old
            %1  [~ old]
            %0  (state-0-to-1 old)
          ==
        [cards this]
    ::
    +$  versioned-state
      $%  state-1
          state-0
      ==
    ::
    +$  state-0
      $:  %0
          sessions=(map sole-id session-0)              ::  sole sessions
          bound=(map flag:chat glyph)                   ::  bound chat glyphs
          binds=(jug glyph flag:chat)                   ::  chat glyph lookup
          settings=(set term)                           ::  frontend flags
          width=@ud                                     ::  display width
          timez=(pair ? @ud)                            ::  timezone adjustment
    ==
    ::
    +$  session-0
      $:  viewing=(set flag:chat)                       ::  connected chats
          history=(list [flag:chat id:chat])            ::  scrollback pointers
          count=@ud                                     ::  (lent history)
          audience=flag:chat                            ::  active target
      ==
    ::  +state-0-to-1: state adapter
    ::
    ++  state-0-to-1
      |=  =state-0
      |^  ^-  (quip card _state)
      :-  %-  update-subscriptions
          ~(val by sessions.state-0)
      :*  %1
          (session-0-to-1 sessions.state-0)
          (bound bound.state-0)
          (binds binds.state-0)
          settings.state-0
          timez.state-0
      ==
      ::
      ++  history
        |=  history=(list [flag:chat id:chat])
        ^-  (list [whom:chat id:chat])
        %+  turn  history
        |=  [=flag:chat =id:chat]
        [[%flag flag] id]
      ::
      ++  bound
        |=  bound=(map flag:chat glyph)
        ^-  (map whom:chat glyph)
        %-  malt
        %+  murn  ~(tap by bound)
        |=  [=flag:chat =glyph]
        ?:  |(=('^' glyph) =('#' glyph))  ~
        `[[%flag flag] glyph]
      ::
      ++  binds
        |=  binds=(jug glyph flag:chat)
        ^-  (jug glyph whom:chat)
        =/  glyphs=(list glyph)
          ~(tap in ~(key by binds))
        =/  cleaned-binds=(jug glyph flag:chat)
          |-
          ?~  glyphs  binds
          ?.  |(=('^' i.glyphs) =('#' i.glyphs))
            $(glyphs t.glyphs)
          $(binds (~(del by binds) i.glyphs), glyphs t.glyphs)
        %-  ~(run by cleaned-binds)
        |=  flags=(set flag:chat)
        (~(run in flags) (lead %flag))
      ::
      ++  session-0-to-1
        |=  sessions=(map sole-id session-0)
        ^-  (map sole-id session)
        %-  ~(run by sessions)
        |=  =session-0
        ^-  session
        :*  `(set whom:chat)`(~(run in viewing.session-0) (lead %flag))
            (history history.session-0)
            count.session-0
            `whom:chat`[%flag audience.session-0]
            80
        ==
      ::
      ++  update-subscriptions
        |=  sez=(list session-0)
        ^-  (list card)
        =/  flags=(set flag:chat)
          =|  f=(set flag:chat)
          |-
          ?~  sez  f
          $(f (~(uni in f) viewing.i.sez), sez t.sez)
        %+  weld
          ^-  (list card)
          :_  ~
          [%pass /chat/ui %agent [our-self %chat] %leave ~]
        ^-  (list card)
        %-  zing
        %+  turn  ~(tap in flags)
        |=  =flag:chat
        (connect:tc `whom:chat`[%flag flag])
      --
    --
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      ?+  mark        (on-poke:def mark vase)
        %noun         (poke-noun:tc !<(* vase))
      ==
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    =^  cards  state
      ?+    wire  ~|(bad-agent-wire/wire !!)
          [%dm ship=@ ~]  
        ?-   -.sign
            %poke-ack
          ?~  p.sign  [~ state]
          =/  =tank  leaf/"poke failed from {<dap.bowl>} on wire {<wire>}"
          ((slog tank u.p.sign) [~ state])
        ::
            %watch-ack
          ?~  p.sign  [~ state]
          =/  =tank  leaf/"subscribe failed from {<dap.bowl>} on wire {<wire>}"
          ((slog tank u.p.sign) [~ state])
        ::
            %kick
          =/  =ship  (slav %p i.t.wire)
          [(connect:tc %ship ship) state]
        ::
            %fact
          ?.  =(%writ-diff p.cage.sign)
            ~|([dap.bowl %bad-sub-mark wire p.cage.sign] !!)
          %+  on-update:tc  
            :-  %ship 
            (slav %p i.t.wire)
          !<(diff:writs:chat q.cage.sign)
        ==
      ::
          [%club id=@ ~]
        ?-   -.sign
            %poke-ack
          ?~  p.sign  [~ state]
          =/  =tank  leaf/"poke failed from {<dap.bowl>} on wire {<wire>}"
          ((slog tank u.p.sign) [~ state])
        ::
            %watch-ack
          ?~  p.sign  [~ state]
          =/  =tank  leaf/"subscribe failed from {<dap.bowl>} on wire {<wire>}"
          ((slog tank u.p.sign) [~ state])
        ::
            %kick
          =/  =club-id  (slav %uv i.t.wire)
          [(connect:tc %club club-id) state]
        ::
            %fact
          ?.  =(%writ-diff p.cage.sign)
            ~|([dap.bowl %bad-sub-mark wire p.cage.sign] !!)
          %+  on-update:tc  
            :-  %club
            (slav %uv i.t.wire)
          !<(diff:writs:chat q.cage.sign)
        ==
      ::
          [%chat ship=@ name=@ ~]
        ?-   -.sign
            %poke-ack
          ?~  p.sign  [~ state]
          =/  =tank  leaf/"poke failed from {<dap.bowl>} on wire {<wire>}"
          ((slog tank u.p.sign) [~ state])
        ::
            %watch-ack
          ?~  p.sign  [~ state]
          =/  =tank  leaf/"subscribe failed from {<dap.bowl>} on wire {<wire>}"
          ((slog tank u.p.sign) [~ state])
        ::
            %kick
          =/  =ship  (slav %p i.t.wire)
          =/  name=term  (slav %tas i.t.t.wire)
          [(connect:tc %flag ship name) state]
        ::
            %fact
          ?.  =(%writ-diff p.cage.sign)
            ~|([dap.bowl %bad-sub-mark wire p.cage.sign] !!)
          %+  on-update:tc
            :+  %flag  
              (slav %p i.t.wire)
            (slav %tas i.t.t.wire)
          !<(diff:writs:chat q.cage.sign)
        ==
      ==
    [cards this]
  ::
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  ::
  ++  command-parser
    |=  =sole-id
    se-parser:(se-apex:se:tc sole-id state)
  ::
  ++  tab-list
    |=  =sole-id
    se-tab-list:se:tc
  ::
  ++  on-command
    |=  [=sole-id =command]
    =^  cards  state
      se-abet:(se-work:(se-apex:se:tc sole-id state) command)
    [cards this]
  ::
  ++  on-connect
    |=  =sole-id
    ^-  (quip card _this)
    [[prompt:se-out:(se-apex:se:tc sole-id state)]~ this]
  ::
  ++  can-connect     can-connect:des
  ++  on-disconnect   on-disconnect:des
  --
::
|_  =bowl:gall
::  +subscription-check: confirm target is subscribed to
::
++  subscription-check
  |=  =target
  ^-  ?
  =/  =wire  (target-to-path target)
  (~(has by wex.bowl) [wire our-self %chat])
::  +connect: subscribe to chats, dms, and clubs
::
++  connect
  |=  =target
  ^-  (list card)
  ?:  (subscription-check target)  ~
  =/  =wire  (target-to-path target)
  =/  =path
    %+  weld  (target-to-path target)
    ?:(?=(%ship -.target) /ui /ui/writs)
  [%pass wire %agent [our-self %chat] %watch path]~
::  +poke-noun: debug helpers
::
++  poke-noun
  |=  a=*
  |^  ^-  (quip card _state)
  ?.  ?=(poke-options a)
    ~|([%unknown-command ~] !!)
  ?-    -.a
  ::  check if target is in %chat agent
  ::
      %target-exists
    ?:  (target-exists p.a)  [~ state]
    ~&  "target not found in %chat agent"
    [~ state]
  ::  are our session's histories equal to our counts?
  ::
      %history-equal-to-count
    =/  sez=(list [=sole-id =session])
      ~(tap by sessions)
    |-
    ?~  sez  [~ state]
    ~?  !=(count.session.i.sez (lent history.session.i.sez))
      "session {(scow %ta ses.sole-id.i.sez)}'s history not equal to count"
    $(sez t.sez)
  ::  do all targets across sessions in view have a subscription?
  ::
      %subscription-status
    =/  sez=(list [=sole-id =session])
      ~(tap by sessions)
    |-
    ?~  sez  [~ state]
    =/  missing=(list target)
      %+  murn  ~(tap in viewing.session.i.sez)
      |=  =target
      ?:((subscription-check target) ~ `target)
    ~?  ?~(missing | &)
      =/  render-missing=tape
        %+  join  ','
        %+  turn  missing
        |=  =target
        (crip (weld " " ~(full tr:se target)))
      %+  weld
        "these targets in {(scow %ta ses.sole-id.i.sez)} are not subscribed:"
      render-missing
    $(sez t.sez)
  ==
  ::  +poke-options: +poke-noun will accept the following actions
  ::
  +$  poke-options
    $%  [%target-exists p=target]
        [%subscription-status ~]
        [%history-equal-to-count ~]
    ==
  --
::
::TODO  better moon support. (name:title our.bowl)
++  our-self  our.bowl
++  crew  crew:club:chat
++  club-id  id:club:chat
::
++  get-session
  |=  =sole-id
  ^-  session
  (~(gut by sessions) sole-id %*(. *session audience [%flag [our-self %$]]))
::  +tor: term ordering for chats 
::
++  tor
  |=  [[* a=term] [* b=term]]
  (aor a b)
::  +get-chats: get known chats 
::
++  get-chats  ~+
  ^-  (set flag:chat)
  (scry-for (set flag:chat) %chat /chat)
::  +get-accepted-dms: get known dms that are mutual and ones we've initiated
::
++  get-accepted-dms  ~+
  ^-  (set ship)
  (scry-for (set ship) %chat /dm)
::  +get-pending-dms: get known dm invites
::
++  get-pending-dms  ~+
  ^-  (set ship)
  (scry-for (set ship) %chat /dm/invited)
::  +get-clubs: get known clubs
::
++  get-clubs  ~+
  ^-  (map club-id crew)
  =/  clubs  
    (scry-for (map club-id crew) %chat /clubs)
  ::  remove archived
  ::
  =/  ids=(list club-id)  
    ~(tap in ~(key by clubs))
  |-
  ?~  ids  clubs
  =/  team  team:(~(got by clubs) i.ids)
  =/  hive  hive:(~(got by clubs) i.ids)
  ?.  &(=(~ team) =(~ hive))
    $(ids t.ids)
  $(clubs (~(del by clubs) i.ids), ids t.ids)
::  +target-exists: check whether a channel exists
::
++  target-exists
  |=  =target
  ^-  ?
  ?-   -.target
      %flag  (~(has in get-chats) p.target)
      %club  (~(has by get-clubs) p.target)
      %ship
    %.  p.target
    %~  has  in 
    (~(uni in get-accepted-dms) get-pending-dms)
  ==
::  +message-exists: check whether a message exists
::
++  message-exists
  |=  [=whom:chat =id:chat]
  ^-  ?
  %+  scry-for-existence  %chat
  (snip (writ-scry-path whom id))
::  +get-messages: scry for latest 20 messages
::
++  get-messages
  |=  =target
  ^-  ((mop time writ:chat) lte) 
  %^  scry-for  ((mop time writ:chat) lte)
    %chat
  (weld (target-to-path target) /writs/newest/20)
::  +on-update: get new messages
::
++  on-update 
  |=  [=whom:chat =diff:writs:chat]
  ^-  (quip card _state)
  ?.  ?=(%add -.q.diff)  [~ state]
  =*  id=id:chat  p.diff
  =*  memo=memo:chat  p.q.diff
  (update-session whom memo id)
::  +update-session: process message updates
::
++  update-session
  |=  $:  =whom:chat
          =memo:chat 
          =id:chat 
      ==
  ^-  (quip card _state)
  =/  sez=(list [=sole-id =session])
    ~(tap by sessions)
  =|  cards=(list card)
  |-
  ?~  sez  [cards state]
   =^  caz  state
     ?.  (~(has in viewing.session.i.sez) whom)
       [~ state]
     se-abet:(se-read-post:(se-apex:se sole-id.i.sez state) whom id memo)
  $(sez t.sez, cards (weld cards caz))
  :: $(sez t.sez, cards (weld cards caz))
::  +bind-default-glyph: bind to default, or random available
::
++  bind-default-glyph
  |=  =target
  ^-  (quip card _state)
  =;  =glyph  (bind-glyph glyph target)
  |^  =/  g=glyph  (choose glyphs)
      ?.  (~(has by binds) g)  g
      =/  available=(list glyph)
        %~  tap  in
        (~(dif in `(set glyph)`(sy glyphs)) ~(key by binds))
      ?~  available  g
      (choose available)
  ++  choose
    |=  =(list glyph)
    =;  i=@ud  (snag i list)
    (mod (mug target) (lent list))
  --
::  +bind-glyph: add binding for glyph
::
++  bind-glyph
  |=  [=glyph =target]
  ^-  (quip card _state)
  ::TODO  should send these to settings store eventually
  ::  if the target was already bound to another glyph, un-bind that
  ::
  =?  binds  (~(has by bound) target)
    (~(del ju binds) (~(got by bound) target) target)
  =.  bound  (~(put by bound) target glyph)
  =.  binds  (~(put ju binds) glyph target)
  [(show-glyph:se-out:se glyph `target) state]
::  +unbind-glyph: remove all binding for glyph
::
++  unbind-glyph
  |=  [=glyph targ=(unit target)]
  ^-  (quip card _state)
  ?^  targ
    =.  binds  (~(del ju binds) glyph u.targ)
    =.  bound  (~(del by bound) u.targ)
    [(show-glyph:se-out:se glyph ~) state]
  =/  ole=(set target)
    (~(get ju binds) glyph)
  =.  binds  (~(del by binds) glyph)
  =.  bound
    |-
    ?~  ole  bound
    =.  bound  $(ole l.ole)
    =.  bound  $(ole r.ole)
    (~(del by bound) n.ole)
  [(show-glyph:se-out:se glyph ~) state]
::  +decode-glyph: find the target that matches a glyph, if any
::
++  decode-glyph
  |=  [=session =glyph]
  ^-  (unit target)
  =+  lax=(~(get ju binds) glyph)
  ::  no target
  ?:  =(~ lax)  ~
  %-  some
  ::  single target
  ?:  ?=([* ~ ~] lax)  n.lax
  ::  in case of multiple matches, pick one we're viewing
  =.  lax  (~(uni in lax) viewing.session)
  ?:  ?=([* ~ ~] lax)  n.lax
  ::  in case of multiple audiences, pick the most recently active one
  |-  ^-  target
  ?~  history.session  -:~(tap in lax)
  =*  tar  -.i.history.session
  ?:  (~(has in lax) tar)
    tar
  $(history.session t.history.session)
::  +set-setting: enable settings flag
::
++  set-setting
  |=  =term
  ^-  (quip card _state)    
  [~ state(settings (~(put in settings) term))]
::  +unset-setting: disable settings flag
::
++  unset-setting
  |=  =term
  ^-  (quip card _state)
  [~ state(settings (~(del in settings) term))]
::  +set-timezone: configure timestamp printing adjustment
::
++  set-timezone
  |=  tz=[? @ud]
  [~ state(timez tz)]
::
::  +se: session engine
::
++  se
  =|  caz=(list card)
  |_  [=sole-id ses=session global=_state]
  +*  se  .
  ::
  ++  se-apex
    |=  [=sole-id:shoe s=_state]
    ^+  se
    se(sole-id sole-id, ses (get-session sole-id), global s)
  ::
  ++  se-abet
    ^-  (quip card _state)
    :-  (flop caz)
    global(sessions (~(put by sessions) sole-id ses))
  ::
  ++  se-emit  |=(cad=card se(caz [cad caz]))
  ++  se-emil  |=(cas=(list card) se(caz (weld (flop cas) caz)))
  ::  +se-read-post: add message to state and show it to user
  ::
  ++  se-read-post
    |=  [=target =id:chat =memo:chat]
    ^+  se
    =.  se  (se-emil (show-post:se-out target memo))
    %_  se
      history.ses  [[target id] history.ses]
      count.ses    +(count.ses)
    ==
  ::  +se-parser: command parser
  ::
  ::    parses the command line buffer.
  ::    produces commands which can be executed by +work.
  ::
  ++  se-parser
    |^
      %+  stag  |
      %+  knee  *command  |.  ~+
      =-  ;~(pose ;~(pfix mic -) message)  
      ;~  pose
        (stag %target targ)
      ::
        ;~((glue ace) (tag %view) targ)
        ;~((glue ace) (tag %flee) targ)
        ;~(plug (tag %view) (easy ~))
      ::
        ;~((glue ace) (tag %bind) glyph targ)
        ;~((glue ace) (tag %unbind) ;~(plug glyph (punt ;~(pfix ace targ))))
        ;~(plug (perk %what ~) (punt ;~(pfix ace ;~(pose glyph targ))))
      ::
        ;~(plug (tag %settings) (easy ~))
        ;~((glue ace) (tag %set) flag)
        ;~((glue ace) (tag %unset) flag)
        ;~(plug (cold %width (jest 'set width ')) dem:ag)
      ::
        ;~  plug
          (cold %timezone (jest 'set timezone '))
          ;~  pose
            (cold %| (just '-'))
            (cold %& (just '+'))
          ==
          %+  sear
            |=  a=@ud
            ^-  (unit @ud)
            ?:(&((gte a 0) (lte a 14)) `a ~)
          dem:ag
        ==
      ::
        ;~(plug (tag %chats) (easy ~))
        ;~(plug (tag %dms) (easy ~))
        ;~(plug (tag %help) (easy ~))
      ::
        (stag %thread ;~((glue ace) ;~(sfix nump ket) content))
        (stag %reference ;~((glue ace) ;~(sfix nump hax) content))
        (stag %select nump)
      ::
      ==
    ::
    ::TODO
    :: ++  cmd
    ::   |*  [cmd=term req=(list rule) opt=(list rule)]
    ::   |^  ;~  plug
    ::         (tag cmd)
    ::       ::
    ::         ::TODO  this feels slightly too dumb
    ::         ?~  req
    ::           ?~  opt  (easy ~)
    ::           (opt-rules opt)
    ::         ?~  opt  (req-rules req)
    ::         ;~(plug (req-rules req) (opt-rules opt))  ::TODO  rest-loop
    ::       ==
    ::   ++  req-rules
    ::     |*  req=(lest rule)
    ::     =-  ;~(pfix ace -)
    ::     ?~  t.req  i.req
    ::     ;~(plug i.req $(req t.req))
    ::   ++  opt-rules
    ::     |*  opt=(lest rule)
    ::     =-  (punt ;~(pfix ace -))
    ::     ?~  t.opt  ;~(pfix ace i.opt)
    ::     ;~(pfix ace ;~(plug i.opt $(opt t.opt)))
    ::   --
    ::
    ++  tag      |*(a=@tas (cold a (jest a)))  ::TODO  into stdlib
    ++  ship     ;~(pfix sig fed:ag)
    ++  name     ;~(pfix fas urs:ab)
    ::  +trun-club-id: accepts a truncated id and pulls the full version
    ::
    ++  trun-club-id
      =-  (sear - ;~(pfix dot viz:ag))
      |=  original-input=@ud
      ^-  (unit @uv)
      =;  found=(list club-id)
        ?.  =(1 (lent found))  ~
        (some -:found)
      %+  murn  ~(tap in ~(key by get-clubs))
      |=  =club-id
      =/  input=tape
        (oust [0 2] (scow %uv original-input))
      =/  have=tape
        (swag [22 (lent input)] (scow %uv club-id))
      ?.  =(have input)  ~
      `club-id
    ::  +tarl: local flag:chat, as /path
    ::
    ++  tarl  (stag our-self name)
    ::  +targ: any target, as tarl, tarp, ship, club id, ~ship/path or glyph
    ::
    ++  targ
      ;~  pose
        ;~  pose
          (stag %flag tarl)
          (stag %flag ;~(plug ship name))
          (stag %club trun-club-id)
          (stag %ship ship)
        ==
        (sear (cury decode-glyph ses) glyph)
      ==
    ::  +tars: set of comma-separated targs
    ::
    ++  tars
      %+  cook  ~(gas in *(set target))
      (most ;~(plug com (star ace)) targ)
    ::  +ships: set of comma-separated ships
    ::
    ++  ships
      %+  cook  ~(gas in *(set ^ship))
      (most ;~(plug com (star ace)) ship)
    ::  +glyph: shorthand character
    ::
    ++  glyph  (mask glyphs)
    ::  +flag: valid flag
    ::
    ++  flag
      %-  perk  :~
        %notify
        %showtime
      ==
    ::  +nump: message number reference
    ::
    ++  nump
      ;~  pose
        ;~(pfix hep dem:ag)
        ;~  plug
          (cook lent (plus (just '0')))
          ;~(pose dem:ag (easy 0))
        ==
        (stag 0 dem:ag)
        (cook lent (star mic))
      ==
    ::  +message: all messages
    ::
    ++  message
      ;~  pose
        :: ;~(plug (cold %eval hax) expr)
        (stag %say content)
      ==
    ::  +content: simple messages
    ::
    ++  content
      ;~  pose
        (cook (late ~) (cook |=(url=@t [%link url url]) turl))
        ;~(less mic text)
      ==
    ::  +turl: url parser
    ::
    ++  turl
      =-  (sear - (plus next))
      |=  t=tape
      ^-  (unit cord)
      ?~((rust t aurf:de-purl:html) ~ `(crip t))
    ::  +text: text message body
    ::
    ++  text
      %+  cook
        |=  a=(list $@(@t [%ship @p]))
        ^-  (list inline:chat)
        %-  flop
        %+  roll  a
        |=  [i=$@(@t [%ship @p]) l=(list inline:chat)]
        ^+  l
        ?~  l    [i]~
        ?^  i    [i l]
        ?^  i.l  [i l]
        [(cat 3 i.l i) t.l]
      (plus ;~(pose (stag %ship ;~(pfix sig fed:ag)) next))
    ::  +expr: parse expression into [cord hoon]
    ::
    ++  expr
      |=  tub=nail
      %.  tub
      %+  stag  (crip q.tub)
      wide:(vang & [&1:% &2:% (scot %da now.bowl) |3:%])
    --
  ::  +se-tab-list: command descriptions
  ::
  ++  se-tab-list
    ^-  (list [@t tank])
    :~
      [';view' leaf+";view (glyph / ~ship / .group.chat.id / ~host/chat)"]
      [';flee' leaf+";flee [glyph / ~ship / .group.chat.id / ~host/chat]"]
    ::
      [';bind' leaf+";bind [glyph] [~ship / .group.chat.id / ~host/chat]"]
      [';unbind' leaf+";unbind [glyph] (~ship / .group.chat.id / ~host/chat)"]
      [';what' leaf+";what (glyph / ~ship / .group.chat.id / ~host/chat)"]
    ::
      [';settings' leaf+";settings"]
      [';set' leaf+";set key (value)"]
      [';unset' leaf+";unset key"]
    ::
      [';chats' leaf+";chats"]
      [';dms' leaf+";dms"]
      [';help' leaf+";help"]
    ==
  ::  +se-work: run user command
  ::
  ++  se-work
    |=  job=command
    ^+  se
    |^  ?-   -.job
            %target     (set-target +.job)
            %say        (say +.job)
            %reference  (reference +.job)
            %thread     (thread +.job)
            :: %eval      (eval +.job)
        ::
            %view       (view +.job)
            %flee       (flee +.job)
        ::
            %bind       (split (bind-glyph +.job))
            %unbind     (split (unbind-glyph +.job))
            %what       (lookup-glyph +.job)
        ::
            %settings   show-settings
            %set        (split (set-setting +.job))
            %unset      (split (unset-setting +.job))
            %width      (set-width +.job)
            %timezone   (split (set-timezone +.job))
        ::
            %select     (select +.job)
            %chats      chats
            %dms        dms
            %help       help
        ::
        ==
    ::  +split: update session engine's cards and state separately
    ::
    ::     called after arms that produce a (quip card _state)
    ::
    ++  split
      |=  [c=(list card) s=_state]
      ^+  se
      =.  se  se(global s)
      (se-emil c)
    ::  +act: build action card
    ::
    ++  act
      |=  [=wire app=term =cage]
      ^-  card
      [%pass wire %agent [our-self app] %poke cage]
    ::  +set-target: set audience, update prompt
    ::
    ++  set-target
      |=  =target
      ^+  se
      =.  se  se(audience.ses target)
      (se-emit prompt:se-out)
    ::  +view: start printing messages from a chat
    ::
    ++  view
      |=  target=$?(~ target)
      |^  ^+  se
      ::  without argument, print all we're viewing
      ::
      ?~  target
        (se-emit (show-targets:se-out ~(tap in viewing.ses)))
      ::  only view existing chats
      ::
      ?.  (target-exists target)
        (se-emit (note:se-out "no such chat"))
      =.  se  (se-emil (rsvp & target))
      ::  send watch card for target not in view
      ::
      =?  se  !(~(has in viewing.ses) target)
        (se-emil (connect target))
      ::  bind an unbound target
      ::
      =?  se  !(~(has by bound) target)
        (split (bind-default-glyph target))
      ::  load history if target is not in view
      ::
      =?  se  !(~(has in viewing.ses) target)
        =.  se  se(viewing.ses (~(put in viewing.ses) target))
        (build-history target)
      (set-target target)
      ::  +build-history: add messages to history and output to session
      ::
      ++  build-history
        |=  =whom:chat
        ^+  se
        =/  messages
          (flop (bap:on:writs:chat (get-messages whom)))
        |-
        ?~  messages  se
        =/  =writ:chat   +.i.messages
        =/  =memo:chat   +.writ
        =.  se  (se-emil (show-post:se-out whom memo))
        =:  history.ses  [[whom id.writ] history.ses]
            count.ses    +(count.ses)
          ==
        $(messages t.messages)
      --
    ::  +flee: stop printing messages from a chat
    ::
    ++  flee
      |=  =target
      ^+  se
      =?  se  (~(has in viewing.ses) target)
        se(viewing.ses (~(del in viewing.ses) target))
      %-  se-emit
      [%pass (target-to-path target) %agent [our-self %chat] %leave ~]
    ::  +rsvp: send rsvp response
    ::
    ++  rsvp
      |=  [ok=? =target]
      ^-  (list card)
      ?-   -.target
          %flag  ~
          %ship
        =/  =ship  +.target
        ?.  (~(has in get-pending-dms) ship)  ~
        :_  ~
        %^  act  (target-to-path target)
          %chat
        [%dm-rsvp !>(`rsvp:dm:chat`[ship ok])]
      ::
          %club
        =/  =club-id  +.target
        =/  crew=(unit crew)  
          (~(get by get-clubs) club-id)
        ?~  crew  ~
        ?.  (~(has in hive.u.crew) our-self)  ~
        :_  ~
        %^  act  (target-to-path target)
          %chat
        :-  %club-action
        !>  ^-  action:club:chat
        [club-id *uid:club:chat %team our-self ok]   
      ==
    ::  +send: make a poke card based on audience
    ::
    ++  send
      |=  $:  replying=(unit id:chat)
              block=(list block:chat)
              msg=(list inline:chat)
          ==
      ^-  card
      =/  =memo:chat 
        [replying our.bowl now.bowl %story block msg]
      %^  act  (target-to-path audience.ses)
        %chat
      ?-   -.audience.ses
          %ship 
        :-  %dm-action
        !>  ^-  action:dm:chat
        [p.audience.ses [our now]:bowl %add memo]
      ::
          %club   
        :-  %club-action
        !>  ^-  action:club:chat
        [p.audience.ses *uid:club:chat %writ [our now]:bowl %add memo]   
      ::
          %flag
        :-  %chat-action-0
        !>  ^-  action:chat
        [p.audience.ses now.bowl %writs [our now]:bowl %add memo]
      ==
    ::  +say: user sends a message
    ::
    ++  say
      |=  msg=(list inline:chat)
      ^+  se
      (se-emit (send ~ ~ msg))
    ::  +reference: use a pointer to reference a message
    ::
    ++  reference
      |=  [=selection msg=(list inline:chat)]
      ^+  se
      =/  pack=(each [=whom:chat =writ:chat] tape)
        (pointer-to-message selection)
      ?-   -.pack
          %|  (se-emit (note:se-out p.pack))
          %&
        ?.  ?=(%flag -.whom.p.pack)
          %-  se-emit 
          %-  note:se-out 
          "message referencing is only available in chats from a group"
        =*  seal  -.writ.p.pack
        =*  memo  +.writ.p.pack
        =*  host  p.p.whom.p.pack
        =*  name  q.p.whom.p.pack
        =*  time  q.id.seal
        =/  wer=path  /msg/(scot %p author.memo)/(scot %ud time)
        =/  =block:chat
          [%cite `cite:cite`[%chan `nest:groups`[%chat [host name]] wer]]
        (se-emit (send ~ [block]~ ?~(msg ~ msg)))
      ==
    ::  +thread: thread reply with pointer reference
    ::
    ++  thread
      |=  [=selection msg=(list inline:chat)]
      ^+  se
      =/  pack=(each [=whom:chat =writ:chat] tape)
        (pointer-to-message selection)
      ?-   -.pack
          %|  (se-emit (note:se-out p.pack))
          %&
        =/  replying=(unit id:chat)
          ?~  replying.writ.p.pack
            `id.writ.p.pack
          replying.writ.p.pack
        ::  switch audience to ensure we're replying in-context
        ::
        =.  se  se(audience.ses whom.p.pack)
        (se-emit (send replying ~ msg))
      ==
    ::  +eval: run hoon, send code and result as message
    ::
    ::    this double-virtualizes and clams to disable .^ for security reasons
    ::
    ++  eval
      |=  [txt=cord exe=hoon]
      ^+  se
      ~&  %eval-tmp-disabled
      se
      ::TODO  why -find.eval??
      :: (say %code txt (eval:store bowl exe))
    ::  +lookup-glyph: print glyph info for all, glyph or target
    ::
    ++  lookup-glyph
      |=  qur=(unit $@(glyph target))
      ^+  se
      =-  (se-emit -)
      ?^  qur
        ?^  u.qur
          =+  gyf=(~(get by bound) u.qur)
          (print:se-out ?~(gyf "none" [u.gyf]~))
        :: TODO pass through +nome?
        =+  pan=~(tap in (~(get ju binds) `@t`u.qur))
        ?:  =(~ pan)  (print:se-out "~")
        =<  (effect:se-out %mor (turn pan .))
        |=(t=target [%txt ~(meta tr t)])
      %-  print-more:se-out
      %-  ~(rep by binds)
      |=  $:  [=glyph targets=(set target)]
              lis=(list tape)
          ==
      %+  weld  lis
      ^-  (list tape)
      %-  ~(rep in targets)
      |=  [=whom:chat l=(list tape)]
      %+  weld  l
      ^-  (list tape)
      [glyph ' ' ~(meta tr whom)]~
    ::  +show-settings: print enabled flags, timezone and width settings
    ::
    ++  show-settings
      ^+  se
      %-  se-emil
      :~  %-  print:se-out
          %-  zing
          ^-  (list tape)
          :-  "flags: "
          %+  join  ", "
          (turn `(list @t)`~(tap in settings) trip)
        ::
          %-  print:se-out
          %+  weld  "timezone: "
          ^-  tape
          :-  ?:(p.timez '+' '-')
          (scow %ud q.timez)
        ::
          (print:se-out "width: {(scow %ud width.ses)}")
      ==
    ::  +set-width: configure cli printing width
    ::
    ++  set-width
      |=  w=@ud
      ^+  se
      se(width.ses (max 40 w))
    ::  +select: expand message from number reference
    ::
    ++  select
      ::NOTE  rel is the nth most recent message,
      ::      abs is the last message whose numbers ends in n
      ::      (with leading zeros used for precision)
      ::
      |=  =selection
      ^+  se
      =/  pack=(each [=whom:chat =writ:chat] tape)
        (pointer-to-message selection)
      ?-   -.pack
          %|  (se-emit (note:se-out p.pack))
          %&
        =/  tum=tape
          ?@  selection
            (scow %s (new:si | +(selection)))
          (scow %ud (index (dec count.ses) selection))
        =.  se  se(audience.ses whom.p.pack)
        %-  se-emil
        :~  (print:se-out ['?' ' ' tum])
            (effect:se-out ~(render-activate mr whom.p.pack +.writ.p.pack))
            prompt:se-out
        ==
      ==
    ::  +pointer-to-message: get message from number reference
    ::  or reason why it's not there
    ::
    ++  pointer-to-message
      |=  =selection
      ^-  (each [whom:chat writ:chat] tape)
      |^  ?@  selection
            =+  tum=(scow %s (new:si | +(selection)))
            ?:  (gte rel.selection count.ses)
              [%| "{tum}: no such message"]
            (produce tum rel.selection)
          ?.  (gte abs.selection count.ses)
            ?:  =(count.ses 0)
              [%| "0: no messages"]
            =+  msg=(index (dec count.ses) selection)
            (produce (scow %ud msg) (sub count.ses +(msg)))
          :-  %|
          %+  weld  "…{(reap zeros.selection '0')}{(scow %ud abs.selection)}: "
          "no such message"
      ::  +produce: produce message if it exists
      ::
      ++  produce
        |=  [number=tape index=@ud]
        ^-  (each [whom:chat writ:chat] tape)
        =/  [=whom:chat =id:chat]  
          (snag index history.ses)
        ?.  (message-exists whom id)
          [%| "…{number}: missing message"]
        =+  %^  scry-for-marked  ,[* =writ:chat]
              %chat
            (writ-scry-path whom id)
        [%& [whom writ]]
      --
    ::  +index: get message index from absolute reference
    ::
    ++  index
      |=  [max=@ud nul=@u fin=@ud]
      ^-  @ud
      =+  dog=|-(?:(=(0 fin) 1 (mul 10 $(fin (div fin 10)))))
      =.  dog  (mul dog (pow 10 nul))
      =-  ?:((lte - max) - (sub - dog))
      (add fin (sub max (mod max dog)))
    ::  +chats: display list of joined chats
    ::
    ++  chats
      ^+  se
      =/  targets=(set target)
        (~(run in get-chats) (lead %flag))
      (se-emit (show-targets:se-out ~(tap in targets)))
    ::  +dms: display list of known dms
    ::
    ++  dms
      ^+  se
      =/  clubs=(set target)
        (~(run in ~(key by get-clubs)) (lead %club))
      =/  dms=(set target)
        %-  %~  run  in 
            (~(uni in get-accepted-dms) get-pending-dms)
        (lead %ship)
      (se-emit (show-targets:se-out ~(tap in (~(uni in clubs) dms))))
    ::  +help: print (link to) usage instructions
    ::
    ++  help
      ^+  se
      =-  (se-emil (turn - print-more:se-out))
      :~  %-  limo
          :*  "Chats can be selected depending on what kind of chat they are:"
              "chats: ~host/chat"
              "dms: ~ship or .group.chat.id"
              "" 
              "Below, when we say [chat], we mean one of the above selectors."
              ""
              ";[dms / chats] to print available chat channels."
              ";view [chat] to print messages for a chat you've already joined."
              ";flee [chat] to stop printing messages for a chat."
              ";[scrollback.pointer] to select a message."
              ";[scrollback.pointer]^ [message] to send a thread response."
              ";[scrollback.pointer]# [message] to reference a message with a response (only ~host/chat channels supported)."
              ""
              "For more details:"
              "https://urbit.org/getting-started/getting-around"
              ~
          ==
      ==
    --
  ::
  ::  +se-out: output to session
  ::
  ++  se-out
    |%
    ::  +effex: emit shoe effect card
    ::
    ++  effex
      |=  effect=shoe-effect:shoe
      ^-  card
      [%shoe ~[sole-id] effect]
    ::  +effect: emit console effect card
    ::
    ++  effect
      |=  effect=sole-effect:shoe
      ^-  card
      (effex %sole effect)
    ::  +print: puts some text into the cli as-is
    ::
    ++  print
      |=  txt=tape
      ^-  card
      (effect %txt txt)
    ::  +print-more: puts lines of text into the cli
    ::
    ++  print-more
      |=  txs=(list tape)
      ^-  card
      %+  effect  %mor
      (turn txs |=(t=tape [%txt t]))
    ::  +note: prints left-padded ---| txt
    ::
    ++  note
      |=  txt=tape
      ^-  card
      =+  lis=(simple-wrap txt (sub width.ses 16))
      %-  print-more
      =+  ?:((gth (lent lis) 0) (snag 0 lis) "")
      :-  (runt [14 '-'] '|' ' ' -)
      %+  turn  (slag 1 lis)
      |=(a=tape (runt [14 ' '] '|' ' ' a))
    ::  +prompt: update prompt to display current audience
    ::
    ++  prompt
      ^-  card
      %+  effect  %pro
      :+  &  %talk-line
      =+  ~(show tr audience.ses)
      ?:(=(1 (lent -)) "{-} " "[{-}] ")
    ::  +show-post: print incoming message
    ::
    ::    every five messages, prints the message number also.
    ::    if the message mentions the user's ship,
    ::    and the %notify flag is set, emit a bell.
    ::
    ++  show-post
      |=  [=target =memo:chat]
      ^-  (list card)
      %+  weld
        ^-  (list card)
        ?.  =(0 (mod count.ses 5))  ~
        :_  ~
        =+  num=(scow %ud count.ses)
        %-  print
        (runt [(sub 13 (lent num)) '-'] "[{num}]")
      ^-  (list card)
      :-  (effex ~(render-inline mr target memo))
      =;  mentioned=?
        ?.  mentioned  ~
        [(effect %bel ~)]~
      ?.  ?=(%story -.content.memo)  |
      %+  lien  q.p.content.memo
      (cury test %ship our.bowl)
    ::  +show-glyph: print glyph un/bind notification
    ::
    ++  show-glyph
      |=  [=glyph target=(unit target)]
      ^-  (list card)
      :_  [prompt ~]
      %-  note
      %+  weld  "set: {[glyph ~]} "
      ?~  target  "unbound"
      ~(phat tr u.target)
    ::  +show-targets: print list of targets
    ::
    ++  show-targets
      |=  targets=(list target)
      |^  ^-  card
      %-  print-more
      %+  turn  (sort targets order)
      |=  =target
      =/  glyph=(unit tape)
        ?.  (~(has by bound) target)  ~
        (some ~(glyph tr target))
      (weld (fall glyph " ") [' ' ~(meta tr target)])
      ::  +order: ships go before chats who go before clubs
      ::
      ++  order
        |=  [a=target b=target]
        ^-  ?
        ?:  &(?=(%ship -.a) ?=(%ship -.b))  
          (aor (scot %p p.a) (scot %p p.b))
        ?:  ?=(%ship -.a)  &
        ?:  ?=(%ship -.b)  |
        ?:  &(?=(%flag -.a) ?=(%flag -.b))  (tor +.a +.b)
        (gte -.a -.b)  ::  %flag before %club
      --
    --
  ::
  ::  +tr: render targets, one of $whom: ship, flag, or club
  ::
  ++  tr
    |_  =target
    ::  +full: render target fully
    ::
    ++  full
      ^-  tape
      ?-   -.target
          %ship  "{(scow %p p.target)}"
          %club  "{(scow %uv p.target)}"
          %flag  "{(scow %p p.p.target)}/{(trip q.p.target)}"
      ==
    ::  +phat: render chat target with local shorthand
    ::
    ::    renders as ~ship/path.
    ::    for local mailboxes, renders just /path.
    ::
    ++  phat
      ^-  tape
      ?.  ?=(%flag -.target)
        ~(full tr target)
      %+  weld
        ?:  =(our-self p.p.target)  ~
        (scow %p p.p.target)
      "/{(trip q.p.target)}"
    ::  +show: render as tape, as glyph if we can
    ::
    ++  show
      ^-  tape
      =+  cha=(~(get by bound.global) target)
      ?~  cha  ~(phat tr target)
      [u.cha ~]
    ::  +glyph: tape for glyph of target, defaulting to *
    ::
    ++  glyph
      ^-  tape
      [(~(gut by bound.global) target '*') ~]
    ::  +meta: render target with meta data
    ::
    ++  meta
      |^  ^-  tape
      ?+   -.target  ~(phat tr target)
          %club
        =/  =club-id  p.target
        =/  crew=(unit crew)
          (~(get by get-clubs) club-id)
        ?~  crew
          (weld (truncate-club-id club-id) "  (club does not exist)")
        =+  team=team.u.crew
        =+  hive=hive.u.crew
        ?:  &(=(~ team) =(~ hive))
          %+  weld  (truncate-club-id club-id)
          "  (club does not have any members)"
        %+  weld
          (truncate-club-id club-id)
        ?.  =(*cord title.met.u.crew)
          "  ({(trip title.met.u.crew)})"
        %+  weld  "  "
        (render-club-members club-id ?~(team hive team))
      ==
      ::  +truncate-club-id: render the last 12 characters of the club id
      ::
      ++  truncate-club-id
        |=  =club-id
        ^-  tape
        %+  swag  [21 12]
        (scow %uv club-id)
      ::  +render-club-members: produce club members as tape
      ::
      ::    print up to four members and produce
      ::    a count for the rest.
      ::
      ++  render-club-members
        |=  [=club-id members=(set ship)]
        ^-  tape
        =/  members=(list tape)
          %+  turn  (sort ~(tap in members) gth)
          |=  =ship
          " {(cite:title ship)}"
        =|  out=tape
        =+  tally=0
        |- 
        ?~  members
          %+  weld 
            (snap out 0 '(')
          ?:  (lte tally 4)  ")"
          " +{(scow %ud (sub tally 4))})"
        ?:  (gte tally 4)  
          $(tally +(tally), members t.members)
        %=  $
          tally    +(tally)
          out      (weld out i.members)
          members  t.members
        ==
      --
    --
  ::
  ::  +mr: render messages
  ::
  ++  mr
    |_  $:  source=target
            memo:chat
        ==
    +*  showtime  (~(has in settings) %showtime)
        notify    (~(has in settings) %notify)
    ::
    ++  content-width
      ::  termwidth, minus author, timestamp, and padding
      %+  sub  width.ses
      %+  add  15
      ?:(showtime 11 0)
    ::
    ++  render-notice
      ?>  ?=(%notice -.content)
      =/  glyph=(unit glyph)
        (~(get by bound.global) source)
      =/  prepend=tape
        (runt [14 '-'] ?~(glyph '|' u.glyph) ' ' " ") 
      :+  %sole  %klr
      %+  weld  prepend
      ^-  styx
      [[`%un ~ ~] ~[pfix.p.content (scot %p author) sfix.p.content]]~
    ::
    ++  render-inline
      |^  ^-  shoe-effect:shoe
      ?.  ?=(%story -.content)
        render-notice
      :+  %row
        %-  thread-indent
        :-  15
        ?.  showtime
          ~[(sub width.ses 16)]
        ~[(sub width.ses 26) 9]
      :+  :-  %t
          %-  crip
          ;:  weld
            (nome author)
            ~(glyph tr source)
            ?~(replying *tape "^")
          ==
        t+(crip line)
      ?.  showtime  ~
      :_  ~
      :-  %t
      =.  sent
        %-  ?:(p.timez add sub)
        [sent (mul q.timez ~h1)]
      =+  dat=(yore sent)
      =*  t   (d-co:co 2)
      =,  t.dat
      %-  crip
      :(weld "~" (t h) "." (t m) "." (t s))
      ::  +thread-indent: indent column if $replying:memo is not ~
      ::  meaning we have a thread message
      ::
      ++  thread-indent
        |=  widths=(list @ud)
        ^-  (list @ud)
        ?~  replying  widths
        %+  turn  widths
        |=  a=@
        ?:  =(a 15)  16
        ?.((gth a 16) a (sub a 1))
      --
    ::
    ++  line
      ^-  tape
      ?>  ?=(%story -.content)
      %-  zing
      %+  join  "\0a"
      %+  weld
        `(list tape)`(zing (turn p.p.content block-as-tape))
        ::(blocks-as-tapes p.p.content)
      (inlines-as-tapes & q.p.content)
    ::
    ++  inlines-as-tapes
      |=  [lim=? lis=(list inline:chat)]
      |^  ^-  (list tape)
          %-  murn
          :_  |=(ls=(list tape) ?:(=(~ ls) ~ (some `tape`(zing ls))))
          (roll lis process-inline)
      ::
      ++  process-inline
        =/  quote=@ud  0
        |=  [=inline:chat out=(list (list tape))]
        ?@  inline  (append-inline out (trip inline))
        ?-  -.inline
          %tag    (append-inline out "#{(trip p.inline)}")
          %block  (append-solo out "[{(trip p.inline)}]")
          %ship   (append-inline out (scow %p p.inline))
          %break  ?:  =(0 quote)  (snoc out ~)
                  (snoc out [(snoc (reap quote '>') ' ') ~])
        ::
            %code
          =.  out  (append-solo out "```")
          =.  out  (append-inline out (trip p.inline))
          (append-solo out "```")
        ::
            ?(%italics %bold %strike %blockquote %inline-code)
          ~?  ?=(%blockquote -.inline)  inline
          =/  lim=tape
            ?-  -.inline
              %italics      "_"
              %bold         "**"
              %strike       "~~"
              %blockquote   "\""
              %inline-code  "`"
            ==
          =?  out  !?=(%blockquote -.inline)
            (append-inline out lim)
          =.  out
            ?:  ?=(%inline-code -.inline)
              (append-inline out (trip p.inline))
            =?  quote  ?=(%blockquote -.inline)  +(quote)
            =?  out    ?=(%blockquote -.inline)  $(inline [%break ~])
            |-
            ?~  p.inline  out
            =.  out  ^$(inline i.p.inline)
            ::TODO  this still renders a trailing newline before nested quotes
            ?.  =([%break ~]~ t.p.inline)
              $(p.inline t.p.inline)
            $(p.inline t.p.inline, quote (dec quote))
          ?:  ?=(%blockquote -.inline)  out
          (append-inline out lim)
        ::
            %link
          =?  out  !=(p.inline q.inline)
            (append-inline out (snoc (trip q.inline) ' '))
          ?.  lim
            (append-solo out (trip p.inline))
          %+  append-inline  out
          =+  wyd=content-width
          =+  ful=(trip p.inline)
          ::  if the full url fits, just render it.
          ?:  (gte wyd (lent ful))  ful
          ::  if it doesn't, prefix with _ and truncate domain with ellipses
          =.  wyd  (sub wyd 2)
          :-  '_'
          =-  (weld - "_")
          =+  prl=(rust ful aurf:de-purl:html)
          ?~  prl  (scag wyd ful)
          =+  hok=r.p.p.u.prl
          =;  domain=tape
            %+  swag
              [(sub (max wyd (lent domain)) wyd) wyd]
            domain
          ?.  ?=(%& -.hok)
            +:(scow %if p.hok)
          %+  reel  p.hok
          |=  [a=knot b=tape]
          ?~  b  (trip a)
          (welp b '.' (trip a))
        ==
      ::
      ++  append-solo
        |=  [content=(list (list tape)) newline=tape]
        ^+  content
        %+  weld  content
        `_content`~[[newline]~ ~]
      ::
      ++  append-inline
        |=  [content=(list (list tape)) inline=tape]
        ^+  content
        ?:  =(~ content)
          ~[~[inline]]
        =/  last
          (dec (lent content))
        =/  old=(list tape)
          (snag last content)
        =/  new=(list tape)
          ?.  =(~ old)  (snoc old inline)
          ::  clean up leading space, common after solo elements
          ?:  ?=([%' ' *] inline)  [t.inline]~
          [inline]~
        (snap content last new)
      --
    ::
    ++  block-as-tape
      |=  =block:chat
      |^  ^-  (list tape)
      ?-   -.block
          %image  ["[ #img: {(trip alt.block)} ]"]~
      ::
          %cite
        ?-  -.cite.block
            %group  =,  cite.block
          ["[ #group: {(scow %p p.flag)}/{(trip q.flag)} ]"]~
        ::
            %desk   =,  cite.block
          ["[ #desk: {(scow %p p.flag)}/{(trip q.flag)}{(spud wer)} ]"]~
        ::
            %bait
          ["[ #bait: ]"]~  ::TODO  implement once %lure is released
        ::
            %chan   =,  cite.block
          =/  =path   (flop wer)
          =/  =id:chat
            :-  (slav %p +<.path)
            (slav %ud -.path)
          =/  =whom:chat  [%flag q.nest]
          ?.  (message-exists whom id)
            ["[ #chat: missing message ]"]~
          =+  %^  scry-for-marked  ,[* =writ:chat]
                %chat
              (writ-scry-path whom id)
          %-  render-message-block
          %+  simple-wrap  
            %+  weld
              "{(cite:title -.id)} said: "
            ~(line mr whom +.writ)
          (sub content-width 7)
        ==
      ==
      :: 
      ::  +render-message-block: make a message block
      ::
      ++  render-message-block
        |=  msg=(list tape)
        |^  ^-  (list tape)
        ?~  msg  ~
        =/  [one=tape two=tape]
          =+  (scag 2 `(list tape)`msg)
          [i.msg ?~(t.msg ~ i.t.msg)]
        =/  wyd=@ud
          (max (lent one) (lent two))
        :-  (make-a-line i.msg wyd |)
        ?~  t.msg  ~
        :-  (make-a-line i.t.msg wyd ?=(^ t.t.msg))
        ~
        ::
        ++  make-a-line
          |=  [line=tape wide=@ud more=?]
          ^-  tape
          =/  line
            ?.  (lth (lent line) wide)
              line
            %+  weld  line
            (runt [(sub wide (lent line)) ' '] "")
          =/  close=tape
            ?:(more "…]" " ]")
          (weld "[ " (weld line close))
        --
      --
    ::  +activate: produce sole-effect for printing message details
    ::
    ++  render-activate
      ^-  sole-effect:shoe
      ~[%mor [%tan meta] body]
    ::  +meta: render message metadata (serial, timestamp, author, target)
    ::
    ++  meta
      ^-  tang
      =+  hed=leaf+"sent at {(scow %da sent)}"
      =/  src=tape  ~(meta tr source)
      [%rose [" " ~ ~] [hed >author< [%rose [", " "to " ~] [leaf+src]~] ~]]~
    ::  +body: long-form render of message contents
    ::
    ++  body
      ?.  ?=(%story -.content)
        +:render-notice
      |-  ^-  sole-effect:shoe
      :-  %mor
      ;:  weld
        ::  if a part of a thread, print top-level message
        ::
        ?~  replying  ~
        =-  (snoc - [%txt "---"])
        ?.  (message-exists source u.replying)
          [txt+"^   …missing message"]~
        =+  %^  scry-for-marked  ,[* =writ:chat]
              %chat
            (writ-scry-path source u.replying)
        [[%txt (weld "^   " ~(line mr source +.writ))]]~
        ::  if block is referenced, print it, too
        ::
        ?:  =(~ p.p.content)  ~
        =-  (snoc - [%txt "---"])
        %+  turn
          ^-  (list tape)
          (zing (turn p.p.content block-as-tape))
        (lead %txt)
        ::TODO  we could actually be doing styling here with %klr
        ::      instead of producing plain %txt output. maybe one day...
        (turn (inlines-as-tapes | q.p.content) (lead %txt))
      ==
    ::  +nome: prints a ship name in 14 characters, left-padding with spaces
    ::
    ++  nome
      |=  =ship
      ^-  tape
      =+  raw=(cite:title ship)
      (runt [(sub 14 (lent raw)) ' '] raw)
    --
  --
::  +simple-wrap: wrap text
::
++  simple-wrap
  |=  [txt=tape wid=@ud]
  ^-  (list tape)
  ?~  txt  ~
  =/  [end=@ud nex=?]
    =+  ret=(find "\0a" (scag +(wid) `tape`txt))
    ?^  ret  [u.ret &]
    ?:  (lte (lent txt) wid)  [(lent txt) &]
    =+  ace=(find " " (flop (scag +(wid) `tape`txt)))
    ?~  ace  [wid |]
    [(sub wid u.ace) &]
  :-  (tufa (scag end `(list @)`txt))
  $(txt (slag ?:(nex +(end) end) `tape`txt))
::  +target-to-path: make first part of a target's path
::
++  target-to-path
  |=  =target
  ^-  path
  ?-  -.target
    %ship  /dm/(scot %p p.target)
    %club  /club/(scot %uv p.target)
    %flag  /chat/(scot %p p.p.target)/(scot %tas q.p.target)
  ==
::  +writ-scry-path: make scry path for writ retrieval
::
++  writ-scry-path
  |=  [=whom:chat =id:chat]
  ^-  path
  %+  weld  (target-to-path whom)
  /writs/writ/id/[(scot %p p.id)]/[(scot %ud q.id)]/writ
::
++  scry-for-existence
  |*  [app=term =path]
  .^(? %gu (scot %p our.bowl) app (scot %da now.bowl) path)
::
++  scry-for-marked
  |*  [=mold app=term =path]
  .^(mold %gx (scot %p our.bowl) app (scot %da now.bowl) path)
::
++  scry-for
  |*  [=mold app=term =path]
  (scry-for-marked mold app (snoc `^path`path %noun))
--

