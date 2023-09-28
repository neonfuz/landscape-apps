::  channels: diary, heap & chat channels for groups
::
::    this is the client side that pulls data from the channels-server.
::
::  XX  chat thread entries can no longer be edited.  maybe fix before
::      release?
::
/-  d=channel, g=groups, ha=hark
/-  meta
/+  default-agent, verb, dbug, sparse, neg=negotiate
/+  utils=channel-utils, volume
::  performance, keep warm
/+  channel-json
%-  %-  agent:neg
    :+  |
      [~.channels^%0 ~ ~]
    [%channels-server^[~.channels^%0 ~ ~] ~ ~]
^-  agent:gall
=>
  |%
  +$  card  card:agent:gall
  +$  current-state
    $:  %0
        =v-channels:d
        voc=(map [nest:d plan:d] (unit said:d))
        pins=(list nest:d)
    ==
  --
=|  current-state
=*  state  -
=<
  %+  verb  |
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      cor   ~(. +> [bowl ~])
  ++  on-init
    ^-  (quip card _this)
    =^  cards  state
      abet:init:cor
    [cards this]
  ::
  ++  on-save  !>([state])
  ++  on-load
    |=  =vase
    ^-  (quip card _this)
    =^  cards  state
      abet:(load:cor vase)
    [cards this]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      abet:(poke:cor mark vase)
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =^  cards  state
      abet:(watch:cor path)
    [cards this]
  ::
  ++  on-peek    peek:cor
  ++  on-leave   on-leave:def
  ++  on-fail    on-fail:def
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    =^  cards  state
      abet:(agent:cor wire sign)
    [cards this]
  ::
  ++  on-arvo
    |=  [=wire sign=sign-arvo]
    ^-  (quip card _this)
    ~&  strange-diary-arvo+wire
    `this
  --
|_  [=bowl:gall cards=(list card)]
++  abet  [(flop cards) state]
++  cor   .
++  emit  |=(=card cor(cards [card cards]))
++  emil  |=(caz=(list card) cor(cards (welp (flop caz) cards)))
++  give  |=(=gift:agent:gall (emit %give gift))
++  server  (cat 3 dap.bowl '-server')
::
::  does not overwite if wire and dock exist.  maybe it should
::  leave/rewatch if the path differs?
::
++  safe-watch
  |=  [=wire =dock =path]
  ^+  cor
  ?:  (~(has by wex.bowl) wire dock)  cor
  (emit %pass wire %agent dock %watch path)
::
++  load
  |=  =vase
  |^  ^+  cor
  =+  !<([old=versioned-state] vase)
  ?>  ?=(%0 -.old)
  =.  state  old
  inflate-io
  ::
  +$  versioned-state  $%(current-state)
  --
::
++  init
  ^+  cor
  =.  cor
    %-  emil
    :~  [%pass /migrate %agent [our.bowl %diary] %poke %diary-migrate !>(~)]
        [%pass /migrate %agent [our.bowl %heap] %poke %heap-migrate !>(~)]
        [%pass /migrate %agent [our.bowl %chat] %poke %chat-migrate !>(~)]
    ==
  inflate-io
::
++  inflate-io
  ::  initiate version negotiation with our own channels-server
  ::
  =.  cor  (emit (initiate:neg our.bowl server))
  ::  leave all subscriptions we don't recognize
  ::
  =.  cor
    %+  roll
      ~(tap by wex.bowl)
    |=  [[[=(pole knot) sub-ship=ship =dude:gall] acked=? =path] core=_cor]
    =.  cor  core
    =/  keep=?
      ?+    pole  |
          [%groups *]  &(=(%groups dude) =(our.bowl ship) =(/groups path))
          [=han:d ship=@ name=@ %updates ~]
        ?.  =(server dude)  |
        ?.  =((scot %p sub-ship) ship.pole)  |
        ?~  diary=(~(get by v-channels) han.pole sub-ship name.pole)  |
        ?.  ?=([han:d @ %updates ?(~ [@ ~])] path)  |
        ?.  =(han.pole i.path)  |
        =(name.pole i.t.path)
      ::
          [=han:d ship=@ name=@ %checkpoint ~]
        ?.  =(server dude)  |
        ?.  =((scot %p sub-ship) ship.pole)  |
        ?~  diary=(~(get by v-channels) han.pole sub-ship name.pole)  |
        ?.  ?=([han:d @ %checkpoint %before @] path)  |
        ?.  =(han.pole i.path)  |
        =(name.pole i.t.path)
      ::
          [%said =han:d ship=@ name=@ %post time=@ quip=?(~ [@ ~])]
        ?.  =(server dude)  |
        ?.  =((scot %p sub-ship) ship.pole)  |
        ?~  pplan=(slaw %ud time.pole)  |
        =/  qplan=(unit (unit time))
          ?~  quip.pole  `~
          ?~  q=(slaw %ud -.quip.pole)  ~
          ``u.q
        ?~  qplan  |
        ?.  (~(has by voc) [han.pole sub-ship name.pole] u.pplan u.qplan)  |
        =(wire path)
      ==
    ?:  keep  cor
    (emit %pass pole %agent [sub-ship dude] %leave ~)
  ::
  ::  watch all the subscriptions we expect to have
  ::
  =.  cor  watch-groups
  ::
  =.  cor
    %+  roll
      ~(tap by v-channels)
    |=  [[=nest:d *] core=_cor]
    di-abet:di-safe-sub:(di-abed:di-core:core nest)
  ::
  cor
::
++  poke
  |=  [=mark =vase]
  ^+  cor
  ?+    mark  ~|(bad-poke+mark !!)
    :: TODO: add transfer/import channels
      %channel-action
    =+  !<(=a-channels:d vase)
    ?:  ?=(%create -.a-channels)
      di-abet:(di-create:di-core create-channel.a-channels)
    ?:  ?=(%pin -.a-channels)
      ?>  from-self
      cor(pins pins.a-channels)
    ?:  ?=(%join -.a-channel.a-channels)
      di-abet:(di-join:di-core [nest group.a-channel]:a-channels)
    di-abet:(di-a-diary:(di-abed:di-core nest.a-channels) a-channel.a-channels)
  ::
      %channel-migration
    ?>  =(our src):bowl
    =+  !<(new-channels=v-channels:d vase)
    =.  v-channels  (~(uni by new-channels) v-channels)  ::  existing overrides migration
    cor
  ::
      %channel-migration-pins
    ?>  =(our src):bowl
    =+  !<(new-pins=(list nest:d) vase)
    =.  pins  (weld pins new-pins)
    cor
  ==
::
++  watch
  |=  =(pole knot)
  ^+  cor
  ?+    pole  ~|(bad-watch-path+pole !!)
      [%briefs ~]                   ?>(from-self cor)
      [%ui ~]                       ?>(from-self cor)
      [=han:d ship=@ name=@ %ui ~]  ?>(from-self cor)
      [%said =han:d host=@ name=@ %post time=@ quip=?(~ [@ ~])]
    =/  host=ship   (slav %p host.pole)
    =/  =nest:d     [han.pole host name.pole]
    =/  =plan:d     =,(pole [(slav %ud time) ?~(quip ~ `(slav %ud -.quip))])
    (watch-said nest plan)
  ==
::
++  watch-said
  |=  [=nest:d =plan:d]
  ?.  (~(has by v-channels) nest)
    =/  wire  (said-wire nest plan)
    (safe-watch wire [ship.nest server] wire)
  di-abet:(di-said:(di-abed:di-core nest) plan)
::
++  said-wire
  |=  [=nest:d =plan:d]
  ^-  wire
  %+  welp
    /said/[han.nest]/(scot %p ship.nest)/[name.nest]/(scot %ud p.plan)
  ?~(q.plan / /(scot %ud u.q.plan))
::
++  take-said
  |=  [=nest:d =plan:d =sign:agent:gall]
  =/  =wire  (said-wire nest plan)
  ^+  cor
  ?+    -.sign  !!
      %watch-ack
    %.  cor
    ?~  p.sign  same
    (slog leaf+"Preview failed" u.p.sign)
  ::
      %kick
    ?:  (~(has by voc) nest plan)
      cor  :: subscription ended politely
    (give %kick ~[wire] ~)
  ::
      %fact
    =.  cor  (give %fact ~[wire] cage.sign)
    =.  cor  (give %kick ~[wire] ~)
    ?+    p.cage.sign  ~|(funny-mark+p.cage.sign !!)
        %channel-denied  cor(voc (~(put by voc) [nest plan] ~))
        %channel-said
      =+  !<(=said:d q.cage.sign)
      cor(voc (~(put by voc) [nest plan] `said))
    ==
  ==
::
++  agent
  |=  [=(pole knot) =sign:agent:gall]
  ^+  cor
  ?+    pole  ~|(bad-agent-wire+pole !!)
      ~          cor
      [%hark ~]
    ?>  ?=(%poke-ack -.sign)
    ?~  p.sign  cor
    %-  (slog leaf+"Failed to hark" u.p.sign)
    cor
  ::
      [=han:d ship=@ name=@ rest=*]
    =/  =ship  (slav %p ship.pole)
    di-abet:(di-agent:(di-abed:di-core han.pole ship name.pole) rest.pole sign)
  ::
      [%said =han:d host=@ name=@ %post time=@ quip=?(~ [@ ~])]
    =/  host=ship   (slav %p host.pole)
    =/  =nest:d     [han.pole host name.pole]
    =/  =plan:d     =,(pole [(slav %ud time) ?~(quip ~ `(slav %ud -.quip))])
    (take-said nest plan sign)
  ::
      [%groups ~]
    ?+    -.sign  !!
        %kick       watch-groups
        %watch-ack
      ?~  p.sign
        cor
      =/  =tank
        leaf+"Failed groups subscription in {<dap.bowl>}, unexpected"
      ((slog tank u.p.sign) cor)
    ::
        %fact
      ?.  =(act:mar:g p.cage.sign)  cor
      (take-groups !<(=action:g q.cage.sign))
    ==
  ::
      [%migrate ~]
    ?+  -.sign  !!
        %poke-ack
      ?~  p.sign  cor
      %-  (slog 'channels: migration poke failure' >wire< u.p.sign)
      cor
    ==
  ==
::
++  watch-groups  (safe-watch /groups [our.bowl %groups] /groups)
::
++  take-groups
  |=  =action:g
  =/  affected=(list nest:d)
    %+  murn  ~(tap by v-channels)
    |=  [=nest:d channel=v-channel:d]
    ?.  =(p.action group.perm.perm.channel)  ~
    `nest
  =/  diff  q.q.action
  ?+    diff  cor
      [%fleet * %add-sects *]    (recheck-perms affected ~)
      [%fleet * %del-sects *]    (recheck-perms affected ~)
      [%channel * %edit *]       (recheck-perms affected ~)
      [%channel * %del-sects *]  (recheck-perms affected ~)
      [%channel * %add-sects *]  (recheck-perms affected ~)
      [%cabal * %del *]
    =/  =sect:g  (slav %tas p.diff)
    %+  recheck-perms  affected
    (~(gas in *(set sect:g)) ~[p.diff])
  ==
::
++  recheck-perms
  |=  [affected=(list nest:d) sects=(set sect:g)]
  ~&  "%channel recheck permissions for {<affected>}"
  %+  roll  affected
  |=  [=nest:d co=_cor]
  =/  di  (di-abed:di-core:co nest)
  di-abet:(di-recheck:di sects)
::
++  peek
  |=  =(pole knot)
  ^-  (unit (unit cage))
  ?+    pole  [~ ~]
      [%x %channels ~]   ``channels+!>((uv-channels:utils v-channels))
      [%x %init ~]    ``noun+!>([briefs (uv-channels:utils v-channels)])
      [%x %pins ~]    ``channel-pins+!>(pins)
      [%x %briefs ~]  ``channel-briefs+!>(briefs)
      [%x =han:d ship=@ name=@ rest=*]
    =/  =ship  (slav %p ship.pole)
    (di-peek:(di-abed:di-core han.pole ship name.pole) rest.pole)
  ::
      [%u =han:d ship=@ name=@ ~]
    =/  =ship  (slav %p ship.pole)
    ``loob+!>((~(has by v-channels) han.pole ship name.pole))
  ==
::
++  briefs
  ^-  briefs:d
  %-  ~(gas by *briefs:d)
  %+  turn  ~(tap in ~(key by v-channels))
  |=  =nest:d
  [nest di-brief:(di-abed:di-core nest)]
::
++  pass-hark
  |=  =new-yarn:ha
  ^-  card
  =/  =cage  hark-action-1+!>([%new-yarn new-yarn])
  [%pass /hark %agent [our.bowl %hark] %poke cage]
::
++  from-self  =(our src):bowl
::
++  di-core
  |_  [=nest:d channel=v-channel:d gone=_|]
  ++  di-core  .
  ++  emit  |=(=card di-core(cor (^emit card)))
  ++  emil  |=(caz=(list card) di-core(cor (^emil caz)))
  ++  give  |=(=gift:agent:gall di-core(cor (^give gift)))
  ++  safe-watch  |=([=wire =dock =path] di-core(cor (^safe-watch +<)))
  ++  di-perms  ~(. perms:utils our.bowl now.bowl nest group.perm.perm.channel)
  ++  di-abet
    %_    cor
        v-channels
      ?:(gone (~(del by v-channels) nest) (~(put by v-channels) nest channel))
    ==
  ++  di-abed
    |=  n=nest:d
    di-core(nest n, channel (~(got by v-channels) n))
  ::
  ++  di-area  `path`/[han.nest]/(scot %p ship.nest)/[name.nest]
  ++  di-sub-wire  (weld di-area /updates)
  ++  di-give-brief
    (give %fact ~[/briefs] channel-brief-update+!>([nest di-brief]))
::
  ::
  ::  handle creating a channel
  ::
  ++  di-create
    |=  create=create-channel:d
    ?>  from-self
    =.  nest  [han.create our.bowl name.create]
    ?<  (~(has by v-channels) nest)
    =.  channel  *v-channel:d
    =.  group.perm.perm.channel  group.create
    =.  last-read.remark.channel  now.bowl
    =/  =cage  [%channel-command !>([%create create])]
    (emit %pass (weld di-area /create) %agent [our.bowl server] %poke cage)
  ::
  ::  handle joining a channel
  ::
  ++  di-join
    |=  [n=nest:d group=flag:g]
    ?<  (~(has by v-channels) nest)
    ?>  |(=(p.group src.bowl) from-self)
    =.  nest  n
    =.  channel  *v-channel:d
    =.  group.perm.perm.channel  group
    =.  last-read.remark.channel  now.bowl
    =.  di-core  di-give-brief
    =.  di-core  (di-response %join group)
    di-safe-sub
  ::
  ::  handle an action from the client
  ::
  ::    typically this will either handle the action directly (for local
  ::    things like marking channels read) or proxy the request to the
  ::    host (for global things like posting a post).
  ::
  ++  di-a-diary
    |=  =a-channel:d
    ?>  from-self
    ?+  -.a-channel  (di-send-command [%channel nest a-channel])
      %join       !!  ::  handled elsewhere
      %leave      di-leave
      ?(%read %read-at %watch %unwatch)  (di-a-remark a-channel)
    ==
  ::
  ++  di-a-remark
    |=  =a-remark:d
    ^+  di-core
    =.  remark.channel
      ?-    -.a-remark
          %watch    remark.channel(watching &)
          %unwatch  remark.channel(watching |)
          %read-at  !!
          %read
        =/  [=time post=(unit v-post:d)]  (need (ram:on-v-posts:d posts.channel))
        remark.channel(last-read `@da`(add time (div ~s1 100)))
      ==
    =.  di-core  di-give-brief
    (di-response a-remark)
  ::
  ::  proxy command to host
  ::
  ++  di-send-command
    |=  command=c-channels:d
    ^+  di-core
    ?>  ?=(%channel -.command)
    ::  don't allow anyone else to proxy through us
    ?.  =(src.bowl our.bowl)
      ~|("%channel-action poke failed: only allowed from self" !!)
    =/  =cage  [%channel-command !>(command)]
    ::  NB: we must have already subscribed to something from this ship,
    ::  so that we have negotiated a matching version.  If we want to do
    ::  anything in particular on a mismatched version, we can call
    ::  +can-poke:neg.
    ::
    (emit %pass di-area %agent [ship.nest.command server] %poke cage)
  ::
  ::  handle a said (previews) request where we have the data to respond
  ::
  ++  di-said
    |=  =plan:d
    ^+  di-core
    =.  di-core
      %^  give  %fact  ~
      ?.  (can-read:di-perms src.bowl)
        channel-denied+!>(~)
      (said:utils nest plan posts.channel)
    (give %kick ~ ~)
  ::
  ++  di-has-sub
    ^-  ?
    (~(has by wex.bowl) [di-sub-wire ship.nest dap.bowl])
  ::
  ++  di-safe-sub
    ?:  di-has-sub  di-core
    ?^  posts.channel  di-start-updates
    =.  load.net.channel  |
    %^  safe-watch  (weld di-area /checkpoint)  [ship.nest server]
    ?.  =(our.bowl ship.nest)
      =/  count  ?:(=(%diary han.nest) '20' '100')
      /[han.nest]/[name.nest]/checkpoint/before/[count]
    /[han.nest]/[name.nest]/checkpoint/time-range/(scot %da *@da)
  ::
  ++  di-start-updates
    ::  not most optimal time, should maintain last heard time instead
    =/  tim=(unit time)
      (bind (ram:on-v-posts:d posts.channel) head)
    %^  safe-watch  di-sub-wire  [ship.nest server]
    /[han.nest]/[name.nest]/updates/(scot %da (fall tim *@da))
  ::
  ++  di-agent
    |=  [=wire =sign:agent:gall]
    ^+  di-core
    ?+    wire  ~|(channel-strange-agent-wire+wire !!)
      ~  di-core  :: noop wire, should only send pokes
      [%create ~]       (di-take-create sign)
      [%updates ~]      (di-take-update sign)
      [%backlog ~]      (di-take-backlog sign)
      [%checkpoint ~]   (di-take-checkpoint sign)
    ==
  ::
  ++  di-take-create
    |=  =sign:agent:gall
    ^+  di-core
    ?-    -.sign
        %poke-ack
      =+  ?~  p.sign  ~
          %-  (slog leaf+"{<dap.bowl>}: Failed creation (poke)" u.p.sign)
          ~
      =/  =path  /[han.nest]/[name.nest]/create
      =/  =wire  (weld di-area /create)
      (emit %pass wire %agent [our.bowl server] %watch path)
    ::
        %kick       di-safe-sub
        %watch-ack
      ?~  p.sign  di-core
      %-  (slog leaf+"{<dap.bowl>}: Failed creation" u.p.sign)
      di-core
    ::
        %fact
      =*  cage  cage.sign
      ?.  =(%channel-update p.cage)
        ~|(diary-strange-fact+p.cage !!)
      =+  !<(=update:d q.cage)
      =.  di-core  (di-u-channels update)
      =.  di-core  di-give-brief
      =.  di-core
        (emit %pass (weld di-area /create) %agent [ship.nest server] %leave ~)
      di-safe-sub
    ==
  ::
  ++  di-take-update
    |=  =sign:agent:gall
    ^+  di-core
    ?+    -.sign  di-core
        %kick       di-safe-sub
        %watch-ack
      ?~  p.sign  di-core
      %-  (slog leaf+"{<dap.bowl>}: Failed subscription" u.p.sign)
      di-core
    ::
        %fact
      =*  cage  cage.sign
      ?+  p.cage  ~|(channel-strange-fact+p.cage !!)
        %channel-logs    (di-apply-logs !<(log:d q.cage))
        %channel-update  (di-u-channels !<(update:d q.cage))
      ==
    ==
  ::
  ++  di-take-checkpoint
    |=  =sign:agent:gall
    ^+  di-core
    ?+    -.sign  di-core
        :: only if kicked prematurely
        %kick       ?:(load.net.channel di-core di-safe-sub)
        %watch-ack
      ?~  p.sign  di-core
      %-  (slog leaf+"{<dap.bowl>}: Failed partial checkpoint" u.p.sign)
      di-core
    ::
        %fact
      =*  cage  cage.sign
      ?+    p.cage  ~|(diary-strange-fact+p.cage !!)
          %channel-checkpoint
        (di-ingest-checkpoint !<(u-checkpoint:d q.cage))
      ==
    ==
  ::
  ++  di-take-backlog
    |=  =sign:agent:gall
    ^+  di-core
    ?+    -.sign  di-core
        :: only if kicked prematurely
        %kick  di-sync-backlog
        %watch-ack
      ?~  p.sign  di-core
      %-  (slog leaf+"{<dap.bowl>}: Failed backlog" u.p.sign)
      di-core
    ::
        %fact
      =*  cage  cage.sign
      ?+    p.cage  ~|(diary-strange-fact+p.cage !!)
          %channel-checkpoint
        (di-ingest-backlog !<(u-checkpoint:d q.cage))
      ==
    ==
  ::
  ++  di-ingest-checkpoint
    |=  chk=u-checkpoint:d
    ^+  di-core
    =.  load.net.channel  &
    =.  di-core  (di-apply-checkpoint chk &)
    =.  di-core  di-start-updates
    =.  di-core  di-sync-backlog
    =/  wire  (weld di-area /checkpoint)
    (emit %pass wire %agent [ship.nest dap.bowl] %leave ~)
  ::
  ++  di-apply-checkpoint
    |=  [chk=u-checkpoint:d send=?]
    =^  changed  sort.channel  (apply-rev:d sort.channel sort.chk)
    =?  di-core  &(changed send)  (di-response %sort sort.sort.channel)
    =^  changed  view.channel  (apply-rev:d view.channel view.chk)
    =?  di-core  &(changed send)  (di-response %view view.view.channel)
    =^  changed  perm.channel  (apply-rev:d perm.channel perm.chk)
    =?  di-core  &(changed send)  (di-response %perm perm.perm.channel)
    =^  changed  order.channel  (apply-rev:d order.channel order.chk)
    =?  di-core  &(changed send)  (di-response %order order.order.channel)
    =/  old  posts.channel
    =.  posts.channel
      ((uno:mo-v-posts:d posts.channel posts.chk) di-apply-unit-post)
    =?  di-core  &(send !=(old posts.channel))
      %+  di-response  %posts
      %+  gas:on-posts:d  *posts:d
      %+  murn  (turn (tap:on-v-posts:d posts.chk) head)
      |=  id=id-post:d
      ^-  (unit [id-post:d (unit post:d)])
      =/  post  (got:on-v-posts:d posts.channel id)
      =/  old   (get:on-v-posts:d old id)
      ?:  =(old `post)  ~
      ?~  post  (some [id ~])
      (some [id `(uv-post:utils u.post)])
    di-core
  ::
  ++  di-sync-backlog
    =/  checkpoint-start  (pry:on-v-posts:d posts.channel)
    ?~  checkpoint-start  di-core
    %^  safe-watch  (weld di-area /backlog)  [ship.nest server]
    %+  welp
    /[han.nest]/[name.nest]/checkpoint/time-range
    ~|  `*`key.u.checkpoint-start
    /(scot %da *@da)/(scot %da key.u.checkpoint-start)
  ::
  ++  di-ingest-backlog
    |=  chk=u-checkpoint:d
    =.  di-core  (di-apply-checkpoint chk |)
    =/  wire  (weld di-area /backlog)
    (emit %pass wire %agent [ship.nest dap.bowl] %leave ~)
  ::
  ++  di-apply-logs
    |=  =log:d
    ^+  di-core
    %+  roll  (tap:log-on:d log)
    |=  [[=time =u-channel:d] di=_di-core]
    (di-u-channels:di time u-channel)
  ::
  ::  +di-u-* functions ingest updates and execute them
  ::
  ::    often this will modify the state and emit a "response" to our
  ::    own subscribers.  it may also emit briefs and/or trigger hark
  ::    events.
  ::
  ++  di-u-channels
    |=  [=time =u-channel:d]
    ?>  di-from-host
    ^+  di-core
    ?-    -.u-channel
        %create
      ?.  =(0 rev.perm.channel)  di-core
      =.  perm.perm.channel  perm.u-channel
      (di-response %create perm.u-channel)
    ::
        %order
      =^  changed  order.channel  (apply-rev:d order.channel +.u-channel)
      ?.  changed  di-core
      (di-response %order order.order.channel)
    ::
        %view
      =^  changed  view.channel  (apply-rev:d view.channel +.u-channel)
      ?.  changed  di-core
      (di-response %view view.view.channel)
    ::
        %sort
      =^  changed  sort.channel  (apply-rev:d sort.channel +.u-channel)
      ?.  changed  di-core
      (di-response %sort sort.sort.channel)
    ::
        %perm
      =^  changed  perm.channel  (apply-rev:d perm.channel +.u-channel)
      ?.  changed  di-core
      (di-response %perm perm.perm.channel)
    ::
        %post
      =/  old  posts.channel
      =.  di-core  (di-u-post id.u-channel u-post.u-channel)
      =?  di-core  !=(old posts.channel)  di-give-brief
      di-core
    ==
  ::
  ++  di-u-post
    |=  [=id-post:d =u-post:d]
    ^+  di-core
    =/  post  (get:on-v-posts:d posts.channel id-post)
    ?:  ?=([~ ~] post)  di-core
    ?:  ?=(%set -.u-post)
      ?~  post
        =/  post=(unit post:d)  (bind post.u-post uv-post:utils)
        =?  di-core  ?=(^ post.u-post)
          ::TODO  what about the "mention was added during edit" case?
          (on-post:di-hark id-post u.post.u-post)
        =.  posts.channel  (put:on-v-posts:d posts.channel id-post post.u-post)
        (di-response %post id-post %set post)
      ::
      ?~  post.u-post
        =.  posts.channel  (put:on-v-posts:d posts.channel id-post ~)
        (di-response %post id-post %set ~)
      ::
      =*  old  u.u.post
      =*  new  u.post.u-post
      =/  merged  (di-apply-post id-post old new)
      ?:  =(merged old)  di-core
      =.  posts.channel  (put:on-v-posts:d posts.channel id-post `merged)
      (di-response %post id-post %set `(uv-post:utils merged))
    ::
    ?~  post
      =.  diffs.future.channel
        ::  if the item affected by the update is not in the window we
        ::  care about, ignore it. otherwise, put it in the pending
        ::  diffs set.
        ::
        ?.  (~(has as:sparse window.future.channel) id-post)
          diffs.future.channel
        (~(put ju diffs.future.channel) id-post u-post)
      di-core
    ::
    ?-    -.u-post
        %quip   (di-u-quip id-post u.u.post id.u-post u-quip.u-post)
        %feels
      =/  merged  (di-apply-feels feels.u.u.post feels.u-post)
      ?:  =(merged feels.u.u.post)  di-core
      =.  posts.channel
        (put:on-v-posts:d posts.channel id-post `u.u.post(feels merged))
      (di-response %post id-post %feels (uv-feels:utils merged))
    ::
        %essay
      =^  changed  +.u.u.post  (apply-rev:d +.u.u.post +.u-post)
      ?.  changed  di-core
      =.  posts.channel  (put:on-v-posts:d posts.channel id-post `u.u.post)
      (di-response %post id-post %essay +>.u.u.post)
    ==
  ::
  ++  di-u-quip
    |=  [=id-post:d post=v-post:d =id-quip:d =u-quip:d]
    ^+  di-core
    |^
    =/  quip  (get:on-quips:d quips.post id-quip)
    ?:  ?=([~ ~] quip)  di-core
    ?:  ?=(%set -.u-quip)
      ?~  quip
        =/  rr-quip=(unit rr-quip:d)
          ?~  quip.u-quip  ~
          `(uv-quip:utils id-post u.quip.u-quip)
        =?  di-core  ?=(^ quip.u-quip)
          (on-quip:di-hark id-post post u.quip.u-quip)
        (put-quip quip.u-quip %set rr-quip)
      ::
      ?~  quip.u-quip  (put-quip ~ %set ~)
      ::
      =*  old  u.u.quip
      =*  new  u.quip.u-quip
      =/  merged  (need (di-apply-quip id-quip `old `new))
      ?:  =(merged old)  di-core
      (put-quip `merged %set `(uv-quip:utils id-post merged))
    ::
    ?~  quip  di-core
    ::
    =/  merged  (di-apply-feels feels.u.u.quip feels.u-quip)
    ?:  =(merged feels.u.u.quip)  di-core
    (put-quip `u.u.quip(feels merged) %feels (uv-feels:utils merged))
    ::
    ::  put a quip into a post by id
    ::
    ++  put-quip
      |=  [quip=(unit quip:d) =r-quip:d]
      ^+  di-core
      =/  post  (get:on-v-posts:d posts.channel id-post)
      ?~  post  di-core
      ?~  u.post  di-core
      =.  quips.u.u.post  (put:on-quips:d quips.u.u.post id-quip quip)
      =.  posts.channel  (put:on-v-posts:d posts.channel id-post `u.u.post)
      =/  meta=quip-meta:d  (get-quip-meta:utils u.u.post)
      (di-response %post id-post %quip id-quip meta r-quip)
    --
  ::
  ::  +di-apply-* functions apply new copies of data to old copies,
  ::  keeping the most recent versions of each sub-piece of data
  ::
  ++  di-apply-unit-post
    |=  [=id-post:d old=(unit v-post:d) new=(unit v-post:d)]
    ^-  (unit v-post:d)
    ?~  old  ~
    ?~  new  ~
    `(di-apply-post id-post u.old u.new)
  ::
  ++  di-apply-post
    |=  [=id-post:d old=v-post:d new=v-post:d]
    ^-  v-post:d
    %_  old
      quips  (di-apply-quips quips.old quips.new)
      feels  (di-apply-feels feels.old feels.new)
      +      +:(apply-rev:d +.old +.new)
    ==
  ::
  ++  di-apply-feels
    |=  [old=feels:d new=feels:d]
    ^-  feels:d
    %-  (~(uno by old) new)
    |=  [* a=(rev:d (unit feel:d)) b=(rev:d (unit feel:d))]
    +:(apply-rev:d a b)
  ::
  ++  di-apply-quips
    |=  [old=quips:d new=quips:d]
    ((uno:mo-quips:d old new) di-apply-quip)
  ::
  ++  di-apply-quip
    |=  [=id-quip:d old=(unit quip:d) new=(unit quip:d)]
    ^-  (unit quip:d)
    ?~  old  ~
    ?~  new  ~
    :-  ~
    %=  u.old
      feels  (di-apply-feels feels.u.old feels.u.new)
      +      +.u.new
    ==
  ::
  ::  +di-hark: notification dispatch
  ::
  ::    entry-points are +on-post and +on-quip, who may implement distinct
  ::    notification behavior
  ::
  ++  di-hark
    |%
    ++  on-post
      |=  [=id-post:d post=v-post:d]
      ^+  di-core
      ?:  =(author.post our.bowl)
        di-core
      ::  we want to be notified if we were mentioned in the post
      ::
      ?:  (was-mentioned:utils content.post our.bowl)
        ?.  (want-hark %mention)
          di-core
        =/  cs=(list content:ha)
          ~[[%ship author.post] ' mentioned you: ' (flatten:utils content.post)]
        (emit (pass-hark (di-spin /post/(rsh 4 (scot %ui id-post)) cs ~)))
      ::
      ::TODO  if we (want-hark %any), notify
      di-core
    ::
    ++  on-quip
      |=  [=id-post:d post=v-post:d =quip:d]
      ^+  di-core
      ?:  =(author.quip our.bowl)
        di-core
      ::  preparation of common cases
      ::
      =*  diary-notification
        :~  [%ship author.quip]  ' commented on '
            [%emph title.han-data.post]   ': '
            [%ship author.quip]  ': '
            (flatten:utils content.quip)
        ==
      =*  heap-notification
        =/  content  (flatten:utils content.quip)
        =/  title=@t
          ?^  title.han-data.post  (need title.han-data.post)
          ?:  (lte (met 3 content) 80)  content
          (cat 3 (end [3 77] content) '...')
        :~  [%ship author.quip]  ' commented on '
            [%emph title]   ': '
            [%ship author.quip]  ': '
            content
        ==
      ::  construct a notification message based on the reason to notify,
      ::  if we even need to notify at all
      ::
      =;  cs=(unit (list content:ha))
        ?~  cs  di-core
        =/  =path
          /post/(rsh 4 (scot %ui id-post))/(rsh 4 (scot %ui id.quip))
        (emit (pass-hark (di-spin path u.cs ~)))
      ::  notify because we wrote the post the quip responds to
      ::
      ?:  =(author.post our.bowl)
        ?.  (want-hark %ours)  ~
        ?-    -.han-data.post
            %diary  `diary-notification
            %heap   `heap-notification
            %chat
          :-  ~
          :~  [%ship author.quip]
              ' replied to you: '
              (flatten:utils content.quip)
          ==
        ==
      ::  notify because we were mentioned in the quip
      ::
      ?:  (was-mentioned:utils content.quip our.bowl)
        ?.  (want-hark %mention)  ~
        `~[[%ship author.quip] ' mentioned you: ' (flatten:utils content.quip)]
      ::  notify because we ourselves responded to this post previously
      ::
      ?:  %+  lien  (tap:on-quips:d quips.post)
          |=  [=time quip=(unit quip:d)]
          ?~  quip  |
          =(author.u.quip our.bowl)
        ?.  (want-hark %ours)  ~
        ?-    -.han-data.post
            %diary  `diary-notification
            %heap   `heap-notification
            %chat
          :-  ~
          :~  [%ship author.quip]
              ' replied to your message “'
              (flatten:utils content.post)
              '”: '
              [%ship author.quip]
              ': '
              (flatten:utils content.quip)
          ==
        ==
      ::  only notify if we want to be notified about everything
      ::
      ?.  (want-hark %any)
        ~
      ?-    -.han-data.post
          %diary  ~
          %heap   ~
          %chat
        :-  ~
        :~  [%ship author.quip]
            ' sent a message: '
            (flatten:utils content.quip)
        ==
      ==
    ::
    ++  want-hark
      |=  kind=?(%mention %ours %any)
      %+  (fit-level:volume [our now]:bowl)
        [%channel nest]
      ?-  kind
        %mention  %soft  ::  mentioned us
        %ours     %soft  ::  replied to us or our context
        %any      %loud  ::  any message
      ==
    --
  ::
  ::  convert content into a full yarn suitable for hark
  ::
  ++  di-spin
    |=  [rest=path con=(list content:ha) but=(unit button:ha)]
    ^-  new-yarn:ha
    =*  group  group.perm.perm.channel
    =/  gn=nest:g  nest
    =/  thread  (welp /[han.nest]/(scot %p ship.nest)/[name.nest] rest)
    =/  rope  [`group `gn q.byk.bowl thread]
    =/  link  (welp /groups/(scot %p p.group)/[q.group]/channels thread)
    [& & rope con link but]
  ::
  ::  give a "response" to our subscribers
  ::
  ++  di-response
    |=  =r-channel:d
    =/  =r-channels:d  [nest r-channel]
    (give %fact ~[/ui (snoc di-area %ui)] channel-response+!>(r-channels))
  ::
  ::  produce an up-to-date brief
  ::
  ++  di-brief
    ^-  brief:d
    =/  =time
      ?~  tim=(ram:on-v-posts:d posts.channel)  *time
      key.u.tim
    =/  unreads
      (lot:on-v-posts:d posts.channel `last-read.remark.channel ~)
    =/  read-id=(unit ^time)
      =/  pried  (pry:on-v-posts:d unreads)
      ?~  pried  ~
      ?~  val.u.pried  ~
      `id.u.val.u.pried
    =/  count
      %-  lent
      %+  skim  ~(tap by unreads)
      |=  [tim=^time post=(unit v-post:d)]
      ?&  ?=(^ post)
          !=(author.u.post our.bowl)
      ==
    [time count read-id]
  ::
  ::  handle scries
  ::
  ++  di-peek
    |=  =(pole knot)
    ^-  (unit (unit cage))
    ?+    pole  [~ ~]
        [%posts rest=*]  (di-peek-posts rest.pole)
        [%perm ~]        ``channel-perm+!>(perm.perm.channel)
        [%search %text skip=@ count=@ nedl=@ ~]
      :^  ~  ~  %channel-scan  !>
      %^    text:di-search
          (slav %ud skip.pole)
        (slav %ud count.pole)
      nedl.pole
    ::
        [%search %mention skip=@ count=@ nedl=@ ~]
      :^  ~  ~  %channel-scan  !>
      %^    mention:di-search
          (slav %ud skip.pole)
        (slav %ud count.pole)
      (slav %p nedl.pole)
    ==
  ::
  ++  give-posts
    |=  [mode=?(%outline %post) ls=(list [time (unit v-post:d)])]
    ^-  (unit (unit cage))
    =/  posts=v-posts:d  (gas:on-v-posts:d *v-posts:d ls)
    =-  ``channel-posts+!>(-)
    ?:  =(0 (lent ls))  [*posts:d ~ ~ 0]
    =/  =posts:d
      ?:  =(%post mode)  (uv-posts:utils posts)
      (uv-posts-without-quips:utils posts)
    =/  newer=(unit time)
      =/  more  (tab:on-v-posts:d posts.channel `-:(rear ls) 1)
      ?~(more ~ `-:(head more))
    =/  older=(unit time)
      =/  more  (bat:mo-v-posts:d posts.channel `-:(head ls) 1)
      ?~(more ~ `-:(head more))
    :*  posts
        newer
        older
        (wyt:on-v-posts:d posts.channel)
    ==
  ::
  ++  di-peek-posts
    |=  =(pole knot)
    ^-  (unit (unit cage))
    =*  on   on-v-posts:d
    ?+    pole  [~ ~]
        [%newest count=@ mode=?(%outline %post) ~]
      =/  count  (slav %ud count.pole)
      =/  ls     (top:mo-v-posts:d posts.channel count)
      (give-posts mode.pole ls)
    ::
        [%older start=@ count=@ mode=?(%outline %post) ~]
      =/  count  (slav %ud count.pole)
      =/  start  (slav %ud start.pole)
      =/  ls     (bat:mo-v-posts:d posts.channel `start count)
      (give-posts mode.pole ls)
    ::
        [%newer start=@ count=@ mode=?(%outline %post) ~]
      =/  count  (slav %ud count.pole)
      =/  start  (slav %ud start.pole)
      =/  ls     (tab:on posts.channel `start count)
      (give-posts mode.pole ls)
    ::
        [%around time=@ count=@ mode=?(%outline %post) ~]
      =/  count  (slav %ud count.pole)
      =/  time  (slav %ud time.pole)
      =/  older  (bat:mo-v-posts:d posts.channel `time count)
      =/  newer  (tab:on posts.channel `time count)
      =/  post   (get:on posts.channel time)
      =/  posts
          ?~  post  (welp older newer)
          (welp (snoc older [time u.post]) newer)
      (give-posts mode.pole posts)
    ::
        [%post time=@ ~]
      =/  time  (slav %ud time.pole)
      =/  post  (get:on posts.channel time)
      ?~  post  ~
      ?~  u.post  `~
      ``channel-post+!>((uv-post:utils u.u.post))
    ::
        [%post %id time=@ %quips rest=*]
      =/  time  (slav %ud time.pole)
      =/  post  (get:on posts.channel `@da`time)
      ?~  post  ~
      ?~  u.post  `~
      (di-peek-quips quips.u.u.post rest.pole)
    ==
  ::
  ++  di-peek-quips
    |=  [=quips:d =(pole knot)]
    ^-  (unit (unit cage))
    =*  on   on-quips:d
    ?+    pole  [~ ~]
        [%all ~]  ``channel-quips+!>(quips)
        [%newest count=@ ~]
      =/  count  (slav %ud count.pole)
      ``channel-quips+!>((gas:on *quips:d (top:mo-quips:d quips count)))
    ::
        [%older start=@ count=@ ~]
      =/  count  (slav %ud count.pole)
      =/  start  (slav %ud start.pole)
      ``channel-quips+!>((gas:on *quips:d (bat:mo-quips:d quips `start count)))
    ::
        [%newer start=@ count=@ ~]
      =/  count  (slav %ud count.pole)
      =/  start  (slav %ud start.pole)
      ``channel-quips+!>((gas:on *quips:d (tab:on quips `start count)))
    ::
        [%quip %id time=@ ~]
      =/  time  (slav %ud time.pole)
      =/  quip  (get:on-quips:d quips `@da`time)
      ?~  quip  ~
      ?~  u.quip  `~
      ``channel-quip+!>(u.u.quip)
    ==
  ::
  ++  di-search
    |^  |%
        ++  mention
          |=  [sip=@ud len=@ud nedl=ship]
          ^-  scan:d
          (scour sip len %mention nedl)
        ::
        ++  text
          |=  [sip=@ud len=@ud nedl=@t]
          ^-  scan:d
          (scour sip len %text nedl)
        --
    ::
    +$  match-type
      $%  [%mention nedl=ship]
          [%text nedl=@t]
      ==
    ::
    ++  scour
      |=  [skip=@ud len=@ud =match-type]
      =*  posts  posts.channel
      ?>  (gth len 0)
      =+  s=[skip=skip len=len *=scan:d]
      =-  (flop scan)
      |-  ^+  s
      ?~  posts  s
      ?:  =(0 len.s)  s
      =.  s  $(posts r.posts)
      ?:  =(0 len.s)  s
      ::
      =.  s
        ?~  val.n.posts  s
        ?.  (match u.val.n.posts match-type)  s
        ?:  (gth skip.s 0)
          s(skip (dec skip.s))
        =/  res  [%post (uv-post-without-quips:utils u.val.n.posts)]
        s(len (dec len.s), scan [res scan.s])
      ::
      =.  s
        ?~  val.n.posts  s
        (scour-quips s id.u.val.n.posts quips.u.val.n.posts match-type)
      ::
      $(posts l.posts)
    ::
    ++  scour-quips
      |=  [s=[skip=@ud len=@ud =scan:d] =id-post:d =quips:d =match-type]
      |-  ^+  s
      ?~  quips  s
      ?:  =(0 len.s)  s
      =.  s  $(quips r.quips)
      ?:  =(0 len.s)  s
      ::
      =.  s
        ?~  val.n.quips  s
        ?.  (match-quip u.val.n.quips match-type)  s
        ?:  (gth skip.s 0)
          s(skip (dec skip.s))
        =/  res  [%quip id-post (uv-quip:utils id-post u.val.n.quips)]
        s(len (dec len.s), scan [res scan.s])
      ::
      $(quips l.quips)
    ::
    ++  match
      |=  [post=v-post:d =match-type]
      ^-  ?
      ?-  -.match-type
        %mention  (match-post-mention nedl.match-type post)
        %text     (match-post-text nedl.match-type post)
      ==
    ::
    ++  match-quip
      |=  [=quip:d =match-type]
      ?-  -.match-type
        %mention  (match-story-mention nedl.match-type content.quip)
        %text     (match-story-text nedl.match-type content.quip)
      ==
    ::
    ++  match-post-mention
      |=  [nedl=ship post=v-post:d]
      ^-  ?
      ?:  ?=([%chat %notice ~] han-data.post)  |
      (match-story-mention nedl content.post)
    ::
    ++  match-story-mention
      |=  [nedl=ship =story:d]
      %+  lien  story
      |=  =verse:d
      ?.  ?=(%inline -.verse)  |
      %+  lien  p.verse
      |=  =inline:d
      ?+  -.inline  |
        %ship                                  =(nedl p.inline)
        ?(%bold %italics %strike %blockquote)  ^$(p.verse p.inline)
      ==
    ::
    ++  match-post-text
      |=  [nedl=@t post=v-post:d]
      ^-  ?
      ?-    -.han-data.post
          %diary
        (match-story-text nedl ~[%inline title.han-data.post] content.post)
      ::
          %heap
        %+  match-story-text  nedl
        ?~  title.han-data.post
          content.post
        [~[%inline u.title.han-data.post] content.post]
      ::
          %chat
        ?:  =([%notice ~] kind.han-data.post)  |
        (match-story-text nedl content.post)
      ==
    ::
    ++  match-story-text
      |=  [nedl=@t =story:d]
      %+  lien  story
      |=  =verse:d
      ?.  ?=(%inline -.verse)  |
      %+  lien  p.verse
      |=  =inline:d
      ?@  inline
        (find nedl inline |)
      ?.  ?=(?(%bold %italics %strike %blockquote) -.inline)  |
      ^$(p.verse p.inline)
    ::
    ++  find
      |=  [nedl=@t hay=@t case=?]
      ^-  ?
      =/  nlen  (met 3 nedl)
      =/  hlen  (met 3 hay)
      ?:  (lth hlen nlen)
        |
      =?  nedl  !case
        (cass nedl)
      =/  pos  0
      =/  lim  (sub hlen nlen)
      |-
      ?:  (gth pos lim)
        |
      ?:  .=  nedl
          ?:  case
            (cut 3 [pos nlen] hay)
          (cass (cut 3 [pos nlen] hay))
        &
      $(pos +(pos))
    ::
    ++  cass
      |=  text=@t
      ^-  @t
      %^    run
          3
        text
      |=  dat=@
      ^-  @
      ?.  &((gth dat 64) (lth dat 91))
        dat
      (add dat 32)
    --
  ::
  ::  when we receive an update from the group we're in, check if we
  ::  need to change anything
  ::
  ++  di-recheck
    |=  sects=(set sect:g)
    ::  if our read permissions restored, re-subscribe
    ?:  (can-read:di-perms our.bowl)  di-safe-sub
    di-core
  ::
  ::  assorted helpers
  ::
  ++  di-from-host  |(=(ship.nest src.bowl) =(p.group.perm.perm.channel src.bowl))
  ::
  ::  leave the subscription only
  ::
  ++  di-simple-leave
    (emit %pass di-sub-wire %agent [ship.nest server] %leave ~)
  ::
  ::  Leave the subscription, tell people about it, and delete our local
  ::  state for the channel
  ::
  ++  di-leave
    =.  di-core  di-simple-leave
    =.  di-core  (di-response %leave ~)
    =.  gone  &
    di-core
  --
--
