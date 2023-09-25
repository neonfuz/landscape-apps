/-  c=chat, d=channel
/+  mp=mop-extensions
|_  pac=pact:c
++  mope  ((mp time writ:c) lte)
++  gas
  |=  ls=(list [=time =writ:c])
  ^+  pac
  %_    pac
      wit  (gas:on:writs:c wit.pac ls)
  ::
      dex
    %-  ~(gas by dex.pac)
    %+  turn  ls
    |=  [=time =writ:c]
    ^-  [id:c _time]
    [id.writ time]
  ==
::
++  brief
  |=  [our=ship last-read=time]
  ^-  brief:briefs:c
  =/  =time
    ?~  tim=(ram:on:writs:c wit.pac)  *time
    key.u.tim
  =/  unreads
    (lot:on:writs:c wit.pac `last-read ~)
  =/  read-id=(unit id:c)
    (bind (pry:on:writs:c unreads) |=([key=@da val=writ:c] id.val))
  =/  count
    (lent (skim ~(tap by unreads) |=([tim=^time =writ:c] !=(author.writ our))))
  [time count read-id]
::
++  get
  |=  =id:c
  ^-  (unit [=time =writ:c])
  ?~  tim=(~(get by dex.pac) id)
    ~
  ?~  wit=(get:on:writs:c wit.pac u.tim)
    ~
  `[u.tim u.wit]
::
++  jab
  |=  [=id:c fun=$-(writ:c writ:c)]
  ^+  pac
  ?~  v=(get id)  pac
  =.  wit.pac  (put:on:writs:c wit.pac time.u.v (fun writ.u.v))
  pac
::
++  got
  |=  =id:c
  ^-  [=time =writ:c]
  (need (get id))
::
++  reduce
  |=  [now=time =id:c del=delta:writs:c]
  ^+  pac
  ?-  -.del
      %add
    =/  =seal:c  [id now ~ ~ [0 ~ ~]]
    ?:  (~(has by dex.pac) id)
      pac
    |-
    ?:  (has:on:writs:c wit.pac now)
      $(now `@da`(add now ^~((div ~s1 (bex 16)))))
    =.  wit.pac
      (put:on:writs:c wit.pac now seal [memo.del %chat kind.del])
    pac(dex (~(put by dex.pac) id now))
  ::
      %del
    =/  tim=(unit time)  (~(get by dex.pac) id)
    ?~  tim  pac
    =/  =time  (need tim)
    =^  wit=(unit writ:c)  wit.pac
      (del:on:writs:c wit.pac time)
    pac(dex (~(del by dex.pac) id))
  ::
      %quip
    %+  jab  id
    |=  =writ:c
    ^-  writ:c
    =/  quips  (reduce-quip quips.writ now id.writ [id delta]:del)
    %=  writ
      quips       quips
      quip-count.meta  (wyt:on:quips:c quips)
      last-quip.meta   (biff (ram:on:quips:c quips) |=([=time *] `time))
    ::
        last-quippers.meta
      ^-  (set ship)
      =|  quippers=(set ship)
      =/  entries=(list [time quip:c])  (bap:on:quips:c quips)
      |-
      ?:  |(=(~ entries) =(3 ~(wyt in quippers)))
        quippers
      =/  [* =quip:c]  -.entries
      ?:  (~(has in quippers) author.quip)
        $(entries +.entries)
      (~(put in quippers) author.quip)
    ==
  ::
      %add-feel
    %+  jab  id
    |=  =writ:c
    writ(feels (~(put by feels.writ) [ship feel]:del))
  ::
      %del-feel
    %+  jab  id
    |=  =writ:c
    writ(feels (~(del by feels.writ) ship.del))
  ==
::
++  reduce-quip
  |=  [=quips:c now=time parent-id=id:c =id:c delta=delta:quips:c]
  ^-  quips:c
  |^
  ?-  -.delta
      %add
    |-
    ?:  (has:on:quips:c quips now)
      $(now `@da`(add now ^~((div ~s1 (bex 16)))))
    =/  cork  [id now ~]
    ?:  (~(has by dex.pac) parent-id)
      (put:on:quips:c quips now cork memo.delta)
    quips
  ::
      %del
    =/  tim=(unit time)  (~(get by dex.pac) id)
    ?~  tim  quips
    =/  =time  (need tim)
    =^  quip=(unit quip:c)  quips
      (del:on:quips:c quips time)
    =.  dex.pac  (~(del by dex.pac) id)
    quips
  ::
      %add-feel
    %+  jab-quip  id
    |=  =quip:c
    quip(feels (~(put by feels.quip) [ship feel]:delta))
  ::
      %del-feel
    %+  jab-quip  id
    |=  =quip:c
    quip(feels (~(del by feels.quip) ship.delta))
  ==
  ++  get-quip
    |=  =id:c
    ^-  (unit [=time =quip:c])
    =/  quip-list  (tap:on:quips:c quips)
    =/  this-quip  (some (rear (skim quip-list |=([time q=quip:c] =(id id.q)))))
    this-quip
  ++  jab-quip
    |=  [=id:c fun=$-(quip:c quip:c)]
    ^+  quips
    ?~  v=(get-quip id)  quips
    (put:on:quips:c quips time.u.v (fun quip.u.v))
  --
::
++  give-writs
  |=  [mode=?(%light %heavy) writs=(list [time writ:c])]
  ^-  writs:c
  %+  gas:on:writs:c  *writs:c
  ?:  =(%heavy mode)  writs
  %+  turn  writs
  |=  [=time =writ:c]
  [time writ(quips *quips:c)]
++  peek
  |=  [care=@tas =(pole knot)]
  ^-  (unit (unit cage))
  =*  on   on:writs:c
  ?+    pole  [~ ~]
  ::
      [%newest count=@ mode=?(%light %heavy) ~]
    =/  count  (slav %ud count.pole)
    =/  writs  (top:mope wit.pac count)
    ``chat-writs+!>((give-writs mode.pole writs))
  ::
      [%older start=@ count=@ mode=?(%light %heavy) ~]
    =/  count  (slav %ud count.pole)
    =/  start  (slav %ud start.pole)
    =/  writs  (bat:mope wit.pac `start count)
    ``chat-writs+!>((give-writs mode.pole writs))
  ::
      [%newer start=@ count=@ mode=?(%light %heavy) ~]
    =/  count  (slav %ud count.pole)
    =/  start  (slav %ud start.pole)
    =/  writs  (tab:on wit.pac `start count)
    ``chat-writs+!>((give-writs mode.pole writs))
  ::
      [%around time=@ count=@ mode=?(%light %heavy) ~]
    =/  count  (slav %ud count.pole)
    =/  time  (slav %ud time.pole)
    =/  older  (bat:mope wit.pac `time count)
    =/  newer  (tab:on:writs:c wit.pac `time count)
    =/  writ   (get:on:writs:c wit.pac time)
    =/  writs
        ?~  writ  (welp older newer)
        (welp (snoc older [time u.writ]) newer)
    ``chat-writs+!>((give-writs mode.pole writs))
  ::
      [%writ %id ship=@ time=@ ~]
    =/  ship  (slav %p ship.pole)
    =/  time  (slav %ud time.pole)
    ?.  ?=(%u care)
      ``writ+!>(writ:(got ship `@da`time))
    ``loob+!>(?~((get ship `@da`time) | &))
  ==
::
++  search
  |^  |%
      ++  mention
        |=  [sip=@ud len=@ud nedl=^ship]
        ^-  scan:c
        (scour sip len (mntn nedl))
      ::
      ++  text
        |=  [sip=@ud len=@ud nedl=@t]
        ^-  scan:c
        (scour sip len (txt nedl))
      --
  ::
  +$  query
    $:  skip=@ud
        more=@ud
        =scan:c
    ==
  ::
  ++  scour
    |=  [sip=@ud len=@ud matc=$-(writ:c ?)]
    ?>  (gth len 0)
    ^-  scan:c
    %-  flop
    =<  scan.-
    %^    (dop:mope query)
        wit.pac     :: (gas:on:writs:c wit.pac ls)
      [sip len ~]   :: (gas:on:quilt:h *quilt:h (bat:mope quilt `idx blanket-size))
    |=  $:  =query
            =time
            =writ:c
        ==
    ^-  [(unit writ:c) stop=? _query]
    :-  ~
    ?:  (matc writ)
      ?:  =(0 skip.query)
        :-  =(1 more.query)
        query(more (dec more.query), scan [writ scan.query])
      [| query(skip (dec skip.query))]
    [| query]
  ::
  ++  mntn
    |=  nedl=ship
    ^-  $-(writ:c ?)
    |=  =writ:c
    ^-  ?
    ?:  ?=([%notice ~] kind.writ)  |
    %+  lien  content.writ
    |=  =verse:d
    ?.  ?=(%inline -.verse)  |
    %+  lien  p.verse
    |=  =inline:d
    ?+  -.inline  |
      %ship                                  =(nedl p.inline)
      ?(%bold %italics %strike %blockquote)  ^$(p.verse p.inline)
    ==
  ::
  ++  txt
    |=  nedl=@t
    ^-  $-(writ:c ?)
    |=  =writ:c
    ^-  ?
    ?:  =([%notice ~] kind.writ)  |
    |^  %+  lien  content.writ
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
  --
--
