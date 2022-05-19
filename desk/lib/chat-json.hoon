/-  c=chat
|%
++  enjs
  =,  enjs:format
  |%
  ++  rsvp
    |=  r=rsvp:dm:c
    %-  pairs
    :~  ship/(ship ship.r)
        ok/b/ok.r
    ==
  ++  whom
    |=  w=whom:c
    ?-  -.w
      %flag  (crip "{(scow %p p.p.w)}/{(trip q.p.w)}")
      %ship  (scot %p p.w)
    ==
  ::
  ++  briefs
    |=  bs=briefs:c
    %-  pairs
    %+  turn  ~(tap by bs)
    |=  [w=whom:c b=brief:briefs:c]
    [(whom w) (brief b)]
  ::
  ++  brief-update
    |=  u=update:briefs:c
    %-  pairs
    :~  whom/s/(whom p.u)
        brief/(brief q.u)
    ==
  ::
  ++  brief
    |=  b=brief:briefs:c
    %-  pairs
    :~  last/(time last.b)
        count/(numb count.b)
    ==
  ::
  ++  perm
    |=  p=perm:c
    %-  pairs
    :~  writers/a/(turn ~(tap in writers.p) (lead %s))
    ==
  ++  ship
    |=  her=@p
    n+(rap 3 '"' (scot %p her) '"' ~)
  ++  id 
    |=  =id:c
    n+(rap 3 '"' (scot %p p.id) '/' (scot %ud q.id) '"' ~)
  ::
  ++  update
    |=  =update:c
    %-  pairs
    :~  time+s+(scot %ud p.update)
        diff+(diff q.update)
    ==
  ::
  ++  diff
    |=  =diff:c
    %+  frond  -.diff
    ?+  -.diff  ~
      %draft    (story p.diff)
      %writs     (writs-diff p.diff)
    ==
  ::
  ++  writs-diff
    |=  =diff:writs:c
    %-  pairs
    :~  id/(id p.diff)
        delta/(writs-delta q.diff)
    ==
  ::
  ++  writs-delta
    |=  =delta:writs:c
    %+  frond  -.delta
    ?+  -.delta  ~
      %add       (memo p.delta)
      %del       ~
      %add-feel  (add-feel +.delta)
    ==
  ++  add-feel
    |=  [her=@p =feel:c]
    %-  pairs
    :~  feel+s+feel
        ship+(ship her)
    ==
  ::
  ++  dm-action
    |=  =action:dm:c
    %-  pairs
    :~  ship+(ship p.action)
        diff+(writs-diff q.action)
    ==
  ::
  ++  memo 
    |=  =memo:c
    %-  pairs
    :~  replying+?~(replying.memo ~ (id u.replying.memo))
        author+(ship author.memo)
        sent+(time sent.memo)
        content+(content content.memo)
    ==
  ::
  ++  block
    |=  b=block:c
    ^-  json
    %+  frond  -.b
    ?-  -.b
        %image
      %-  pairs
      :~  src+s+src.b
          height+(numb height.b)
          width+(numb width.b)
          alt+s+alt.b
      ==
    ==
  ::
  ++  notice
    |=  n=notice:c
    %-  pairs
    :~  pfix/s/pfix.n
        sfix/s/sfix.n
    ==
  ::
  ++  content
    |=  c=content:c
    %+  frond  -.c
    ?-  -.c
      %story   (story p.c)
      %notice  (notice p.c)
    ==
  ::
  ++  story
    |=  s=story:c
    %-  pairs
    :~  block/a/(turn p.s block)
        inline/a/(turn q.s inline)
    ==
  ::
  ++  inline
    |=  i=inline:c
    ^-  json
    ?@  i  s+i
    %+  frond  -.i
    ?-  -.i
        %break
      ~
    ::
        ?(%italics %bold %strike %inline-code)
      (inline p.i)
    ::
        ?(%code %tag)
      s+p.i
    ::
        %blockquote
      :-  %a
      (turn p.i inline)
    ::
        %block
      %-  pairs
      :~  index+(numb p.i)
          text+s+q.i
      ==
    ::
        %link
      %-  pairs
      :~  href+s+p.i
          content+s+q.i
      ==
    ==
  ::
  ++  seal
    |=  =seal:c
    %-  pairs
    :~  id+(id id.seal)
    ::
        :-  %feels
        %-  pairs
        %+  turn  ~(tap by feels.seal)
        |=  [her=@p =feel:c]
        [(scot %p her) s+feel]
    ::
        :-  %replied
        :-  %a
        (turn ~(tap in replied.seal) |=(i=id:c (id i)))
    ==
  ++  writ
    |=  =writ:c
    %-  pairs
    :~  seal+(seal -.writ)
        memo+(memo +.writ)
    ==
  ::
  ++  writ-list
    |=  w=(list writ:c)
    ^-  json
    a+(turn w writ)
  ::
  ++  writs
    |=  =writs:c
    ^-  json
    %-  pairs
    %+  turn  (tap:on:writs:c writs) 
    |=  [key=@da w=writ:c]
    [(scot %ud key) (writ w)]

  --
++  dejs
  =,  dejs:format
  |%
  ++  rsvp
    %-  ot
    :~  ship/(se %p)
        ok/bo
    ==
  ++  whom
    ^-  $-(json whom:c)
    %-  su
    ;~  pose
      (stag %flag flag-rule)
      (stag %ship ;~(pfix sig fed:ag))
    ==
  ++  remark-action
    %-  ot
    :~  whom/whom
        diff/remark-diff
    ==
  ::
  ++  remark-diff
    %-  of
    :~  read/ul
        watch/ul
        unwatch/ul
    ==
  ++  create
    ^-  $-(json create:c)
    %-  ot
    :~  group+flag
        name+(se %tas)
        title+so
        description+so
        readers+(as (se %tas))
    ==

  ++  ship  (su ;~(pfix sig fed:ag))
  ++  flag  (su flag-rule)
  ++  flag-rule  ;~((glue fas) ;~(pfix sig fed:ag) sym)
  ++  action
    ^-  $-(json action:c)
    %-  ot
    :~  flag+flag
        update+update
    ==
  ++  dm-action
    ^-  $-(json action:dm:c)
    %-  ot
    :~  ship/ship
        diff/writs-diff
    ==
  ::
  ++  update
    |=  j=json
    ^-  update:c
    ?>  ?=(%o -.j)
    [*time (diff (~(got by p.j) %diff))]
  ::
  ++  diff
    ^-  $-(json diff:c)
    %-  of
    :~  writs/writs-diff
        add-sects/add-sects
        draft/story
    ==
  ::
  ++  id  
    ^-  $-(json id:c)
    %-  su 
    %+  cook  |=([p=@p q=@] `id:c`[p `@da`q])
    ;~((glue fas) ;~(pfix sig fed:ag) dem:ag)
  ::
  ++  writs-diff
    ^-  $-(json diff:writs:c)
    %-  ot
    :~  id/id
        delta/writs-delta
    ==
  ++  writs-delta
    ^-  $-(json delta:writs:c)
    %-  of
    :~  add/memo
        del/ul
        add-feel/add-feel
    ==
  ::
  ++  add-sects  (as (se %tas))
  ::
  ++  add-feel
    %-  ot
    :~  ship/ship
        feel/so
    ==
  ::
  ++  memo
    ^-  $-(json memo:c)
    %-  ot
    :~  replying/(mu id)
        author/ship
        sent/di
        content/content
    ==
  ::
  ++  content
    %-  of
    :~  story/story
        notice/notice
    ==
  ::
  ++  notice
    %-  ot
    :~  pfix/so
        sfix/so
    ==
  ::
  ++  story
    ^-  $-(json story:c)
    %-  ot
    :~  block/(ar block)
        inline/(ar inline)
    ==
  ::
  ++  block
    |=  j=json
    ^-  block:c
    %.  j
    %-  of
    :~
    ::
      :-  %image
      %-  ot
      :~  src/so
          height/ni
          width/ni
          alt/so
      ==
    ==
  ::
  ++  inline
    |=  j=json
    ^-  inline:c
    ?:  ?=([%s *] j)  p.j
    =>  .(j `json`j)
    %.  j
    %-  of
    :~  italics/inline
        bold/inline
        strike/inline
        inline-code/inline
        code/so
        blockquote/(ar inline)
        tag/so
        break/ul
    ::
      :-  %block
      %-  ot
      :~  index/ni
          text/so
      ==
    ::
      :-  %link
      %-  ot
      :~  href/so
          content/so
      ==
    ==
  --
--
