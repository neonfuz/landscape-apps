=<  subscriber
|%
+$  sub
  $:  =dock
      =path
      fires-at=@da
  ==
::
+$  subs  (map wire sub)
::
++  verb  |
++  subscriber
  |_  [=subs bowl:gall]
  ++  interval  ~s30
  ++  handle-wakeup
    |=  =wire
    ^-  [(unit card:agent:gall) _subs]
    ?>  ?=([%~.~ %retry *] wire)
    ~?  verb  ['waking up' wire]
    =/  sub  (~(get by subs) t.t.wire)
    ?~  sub  [~ subs]
    :-  `[%pass t.t.wire %agent dock.u.sub %watch path.u.sub]
    (~(del by subs) t.t.wire)
  ++  subscribe
    |=  [=wire =dock =path delay=?]
    ^-  [(unit card:agent:gall) _subs]
    ?:  (~(has by subs) wire)
      ((slog 'Duplicate subscription' >[wire dock]< ~) [~ subs])
    ?.  delay  [`[%pass wire %agent dock %watch path] subs]
    ~?  verb  ['subscribing with delay' wire]
    =/  fires-at  (add now interval)
    :_  (~(put by subs) wire [dock path fires-at])
    `[%pass (weld /~/retry wire) %arvo %b %wait fires-at]
  ++  unsubscribe
    |=  =wire
    ^-  [(list card:agent:gall) _subs]
    =/  sub  (~(get by subs) wire)
    ?~  sub
      ((slog 'No such subscription' >[wire]< ~) [~ subs])
    ~?  verb  ['cancelling' wire]
    :_  (~(del by subs) wire)
    :~  [%pass (weld /~/cancel-retry wire) %arvo %b %rest fires-at.u.sub]
        [%pass wire %agent dock.u.sub %leave ~]
    ==
  --
--