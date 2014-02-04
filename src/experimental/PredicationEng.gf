concrete PredicationEng of Predication = open Prelude in {

-- English predication, based on Swedish
-- two principles:
-- - keep records discontinuous as long as possible (last step from Cl to S)
-- - select from tables as soon as possible (first step from V to VP)
-- a question: would it make sense to make this into a functor?

param
  Number   = Sg | Pl ;
  Person   = P1 | P2 | P3 ;
  Agr      = Ag Number Person ;
  VAgr     = VASgP1 | VASgP3 | VAPl ;
  Case     = Nom | Acc ;
  STense   = Pres | Past | Fut | Cond ;
  Anteriority = Simul | Anter ;
  Polarity = Pos | Neg ;
  VForm    = VInf | VPres | VPast | VPastPart | VPresPart ;
  Voice    = Act | Pass ;
   
  FocusType = NoFoc | FocSubj | FocObj ;  -- sover hon/om hon sover, vem älskar hon/vem hon älskar, vem sover/vem som sover 

  Unit = UUnit ;

oper
  NAgr = Number ;
  AAgr = Unit ;
  IPAgr = Number ;

  defaultAgr : Agr = Ag Sg P3 ;
  ComplCase  = Str ; -- preposition

-- omitting rich Agr information
  agr2vagr : Agr -> VAgr = \a -> case a of {
    Ag Sg P1 => VASgP1 ;
    Ag Sg P3 => VASgP3 ;
    _        => VAPl
    } ;

  agr2aagr : Agr -> AAgr = \n -> UUnit ;

  agr2nagr : Agr -> NAgr = \a -> case a of {
    Ag n _ => n
    } ;

-- restoring full Agr
  ipagr2agr : IPAgr -> Agr = \n -> Ag n P3 ;

  ipagr2vagr : IPAgr -> VAgr = \n -> case n of {
    Sg => VASgP3 ;
    Pl => VAPl
    } ;

--- this is only needed in VPC formation
  vagr2agr : VAgr -> Agr = \a -> case a of {
    VASgP1 => Ag Sg P1 ;
    VASgP3 => Ag Sg P3 ;
    VAPl   => Ag Pl P3
    } ;

lincat
  Arg = {s : Str} ;

  V = {
    v  : VForm => Str ;             
    c1 : ComplCase ; 
    c2 : ComplCase ;
    isSubjectControl : Bool ;
    isAux : Bool ;
    } ; 

oper
  VerbPhrase = {
    v : VAgr => Str * Str * Str ;  -- ska,ha,sovit 
    inf : Str * Str ;      -- ha,sovit
    c1 : ComplCase ; 
    c2 : ComplCase ; 
    adj   : Agr => Str ; 
    obj1  : (Agr => Str) * Agr ; 
    obj2  : (Agr => Str) * Bool ; -- subject control = True 
    adv : Str ; 
    adV : Str ;
    ext : Str ;
    qforms : VAgr => Str * Str  -- special Eng for introducing "do" in questions
    } ;
 
  Clause = {
    v : Str * Str * Str ; 
    inf : Str * Str ; 
    adj,obj1,obj2 : Str ; 
    adv : Str ; 
    adV : Str ;
    ext : Str ; 
    subj : Str ; 
    c3  : ComplCase ;  -- for a slashed adjunct, not belonging to the verb valency
    qforms : Str * Str
    } ; 

lincat
  VP = VerbPhrase ;
  Cl = Clause ;

  QCl = Clause ** {
    foc : Str ; -- the focal position at the beginning, e.g. *vem* älskar hon
    focType : FocusType ; --- if already filled, then use other place: vem älskar *vem*
    } ; 

  VPC = {
    v   : VAgr => Str ;
    inf : Agr => Str ; 
    c1  : ComplCase ; 
    c2  : ComplCase
    } ;

  ClC = {
    s  : Str ;
    c3 : ComplCase ;
    } ;

  Tense = {s : Str ; t : STense} ;
  Ant   = {s : Str ; a : Anteriority} ;
  Pol   = {s : Str ; p : Polarity} ;

  NP   = {s : Case => Str ; a : Agr} ;
  Adv  = {s : Str ; isAdV : Bool} ;
  S    = {s : Str} ;
  Utt  = {s : Str} ;
  AP   = {
    s : AAgr => Str ; 
    c1, c2 : ComplCase ; 
    obj1 : Agr => Str
    } ;
  CN   = {
    s : NAgr => Str ; 
    c1, c2 : ComplCase ; 
    obj1 : Agr => Str
    } ;
  IP   = {s : Str ; a : IPAgr} ;
  Prep = {s : Str} ;
  Conj = {s : Str} ;
  IAdv = {s : Str} ;

lin
  aNone, aS, aV, aA, aQ, aN = {s = []} ;
  aNP a = a ;

  TPres  = {s = [] ; t = Pres} ;
  TPast  = {s = [] ; t = Past} ;
  TFut   = {s = [] ; t = Fut} ;
  TCond  = {s = [] ; t = Cond} ;
  ASimul = {s = [] ; a = Simul} ;
  AAnter = {s = [] ; a = Anter} ;

  PPos  = {s = [] ; p = Pos} ;
  PNeg  = {s = [] ; p = Neg} ;

  UseV a t p _ v = {
    v   = \\agr => tenseV (a.s ++ t.s ++ p.s) t.t a.a p.p Act agr v ;
    inf = tenseInfV a.s a.a p.p Act v ;
    c1  = v.c1 ;
    c2  = v.c2 ;
    adj = noObj ;
    obj1 = <noObj, defaultAgr> ; ---- not used, just default value
    obj2 = <noObj, v.isSubjectControl> ;
    adV = negAdV p ;
    adv = [] ;
    ext = [] ;
    qforms = \\agr => qformsV (a.s ++ t.s ++ p.s) t.t a.a p.p agr v ;
    } ;

  PassUseV a t p _ v = {
    v   = \\agr => tenseV (a.s ++ t.s ++ p.s) t.t a.a p.p Pass agr v ;
    inf = tenseInfV a.s a.a p.p Pass v ;
    c1  = v.c1 ;
    c2  = v.c2 ;
    adj = noObj ;
    obj1 = <noObj, defaultAgr> ; ---- not used, just default value
    obj2 = <noObj, True> ; -- becomes subject control even if object control otherwise "*she was promised by us to love ourselves"
    adV = negAdV p ;
    adv = [] ;
    ext = [] ;
    qforms = \\agr => qformsBe (a.s ++ t.s ++ p.s) t.t a.a p.p agr ;
    } ;

  AgentPassUseV a t p _ v np = {
    v   = \\agr => tenseV (a.s ++ t.s ++ p.s) t.t a.a p.p Pass agr v ;
    inf = tenseInfV a.s a.a p.p Pass v ;
    c1  = v.c1 ;
    c2  = v.c2 ;
    adj = \\a => [] ;
    obj1 = <noObj, defaultAgr> ; 
    obj2 = <noObj, True> ;
    adV = negAdV p ;
    adv = appComplCase agentCase np ; ---- add a specific field for agent?
    ext = [] ;
    qforms = \\agr => qformsBe (a.s ++ t.s ++ p.s) t.t a.a p.p agr ;
    } ;

  UseAP a t p _ ap = {
    v   = \\agr => be_Aux (a.s ++ t.s ++ p.s) t.t a.a p.p agr ;
    inf = tenseInfV a.s a.a p.p Act be_V ;
    c1  = ap.c1 ;
    c2  = ap.c2 ;
    adj = \\a => ap.s ! agr2aagr a ;
    obj1 = <ap.obj1, defaultAgr> ;
    obj2 = <noObj, True> ; --- there are no A3's
    adV = negAdV p ;
    adv = [] ;
    ext = [] ;
    qforms = \\agr => qformsBe (a.s ++ t.s ++ p.s) t.t a.a p.p agr ;
    } ;

  SlashV2 x vp np = vp ** {
    obj1 : (Agr => Str) * Agr = <\\a => np.s ! Acc, np.a>  -- np.a for object control ---- Acc to be abstracted
    } ;

  SlashV3 x vp np = addObj2VP vp (\\a => np.s ! Acc) ; -- control is preserved  ---- Acc to be abstracted

  ComplVS x vp cl = addExtVP vp (that_Compl ++ declSubordCl (lin Cl cl)) ; ---- sentence form

  ComplVQ x vp qcl = addExtVP vp (questSubordCl qcl) ; ---- question form

  ComplVV x vp vpo = addObj2VP vp (\\a => infVP a vpo) ; ---- infForm

  ComplVA x vp ap = addObj2VP vp (\\a => ap.s ! agr2aagr a ++ ap.obj1 ! a) ; ---- adjForm

  ComplVN x vp cn = addObj2VP vp (\\a => cn.s ! agr2nagr a ++ cn.obj1 ! a) ; ---- cnForm

  SlashV2S x vp cl = addExtVP vp (that_Compl ++ declSubordCl (lin Cl cl)) ; ---- sentence form

  SlashV2Q x vp cl = addExtVP vp (questSubordCl (lin QCl cl)) ; ---- question form

  SlashV2V x vp vpo = addObj2VP vp (\\a => infVP a (lin VP vpo)) ; ---- infForm

  SlashV2A x vp ap = addObj2VP vp (\\a => ap.s ! agr2aagr a ++ ap.obj1 ! a) ; ---- adjForm

  SlashV2N x vp cn = addObj2VP vp (\\a => cn.s ! agr2nagr a ++ cn.obj1 ! a) ; ---- cn form

  ReflVP x vp = vp ** {
    obj1 : (Agr => Str) * Agr = <\\a => reflPron a, defaultAgr> ; --- hack: defaultAgr will not be used but subj.a instead
    } ;

  ReflVP2 x vp = vp ** {
    obj2 : (Agr => Str) * Bool = <\\a => reflPron a, vp.obj2.p2> ; --- subj/obj control doesn't matter any more
    } ;

  PredVP x np vp = vp ** {
    v    = vp.v ! agr2vagr np.a ;
    subj = np.s ! Nom ;
    adj  = vp.adj ! np.a ;
    obj1 = vp.c1 ++ vp.obj1.p1 ! np.a ;  ---- apply complCase
    obj2 = vp.c2 ++ vp.obj2.p1 ! (case vp.obj2.p2 of {True => np.a ; False => vp.obj1.p2}) ;   ---- apply complCase
    c3   = noComplCase ;      -- for one more prep to build ClSlash 
    qforms = vp.qforms ! agr2vagr np.a ;
    } ;

  PrepCl p x cl = cl ** {   -- Cl/NP ::= Cl PP/NP
    c3   = prepComplCase p ; 
    } ;

  SlashClNP x cl np = cl ** {  -- Cl ::= Cl/NP NP 
    adv  = cl.adv ++ appComplCase cl.c3 np ; ---- again, adv just added
    c3   = noComplCase ;  -- complCase has been consumed
    } ;


-- QCl ::= Cl by just adding focus field
  QuestCl x cl = cl ** {foc = [] ; focType = NoFoc} ;  -- NoFoc implies verb first: älskar hon oss

  QuestIAdv x iadv cl = cl ** {foc = iadv.s ; focType = FocObj} ; -- FocObj implies Foc + V + Subj: varför älskar hon oss

  QuestVP x ip vp = let ipa = ipagr2agr ip.a in
   vp ** {
    v    = vp.v ! ipagr2vagr ip.a ;
    foc  = ip.s ;   -- vem älskar henne
    focType = FocSubj ;
    subj = [] ;
    adj  = vp.adj ! ipa ;
    obj1 = vp.c1 ++ vp.obj1.p1 ! ipa ; ---- appComplCase
    obj2 = vp.c2 ++ vp.obj2.p1 ! (case vp.obj2.p2 of {True => ipa ; False => vp.obj1.p2}) ; ---- appComplCase
    c3   = noComplCase ;      -- for one more prep to build ClSlash ---- ever needed for QCl?
    qforms = vp.qforms ! ipagr2vagr ip.a ;
    } ;

  QuestSlash x ip cl = 
    let
      ips = cl.c3 ++ ip.s ;     -- in Cl/NP, c3 is the only prep ---- appComplCase for ip
      focobj = case cl.focType of {
        NoFoc => <ips, [], FocObj> ;  -- put ip object to focus  if there is no focus yet
        t     => <[], ips, t>         -- put ip object in situ   if there already is a focus
        } ;
    in cl ** {
      foc  = focobj.p1 ;
      focType = focobj.p3 ;
      subj = cl.subj ;
      obj1 = cl.obj1 ++ focobj.p2 ;     ---- just add to a field?
      c3   = noComplCase ; 
      } ;

  UseCl  cl = {s = declCl cl} ;
  UseQCl cl = {s = questCl cl} ;

  UseAdvCl adv cl = {s = adv.s ++ declInvCl cl} ;

  UttS s = s ;

  AdvCl a x cl = cl ** case a.isAdV of {True => {adV = cl.adV ++ a.s ; adv = cl.adv} ; False => {adv = cl.adv ++ a.s ; adV = cl.adV}} ;

  AdvQCl a x cl = cl ** {adv = cl.adv ++ a.s} ;


  PresPartAP x v = {            
    s = \\a => v.v ! vPresPart a ;
    c1 = v.c1 ;                    -- tittande på henne
    c2 = v.c2 ;
    obj1 = noObj ;
    } ;

  PastPartAP x v = {
    s = \\a => v.v ! vPastPart a ;
    c1 = v.c1 ; 
    c2 = v.c2 ;
    obj1 = noObj ;
    } ;

  AgentPastPartAP x v np = {
    s = \\a => v.v ! vPastPart a ;
    c1 = v.c1 ; 
    c2 = v.c2 ;
    obj1 = \\_ => appComplCase agentCase np ; ---- addObj
    } ;

  StartVPC c x v w = {  ---- some loss of quality seems inevitable
    v = \\a => 
          let 
            vv = v.v ! a ; 
            wv = w.v ! a ;
            vpa = vagr2agr a ;
          in 
          vv.p1 ++ v.adV ++ vv.p2 ++ vv.p3 ++ v.adj ! vpa ++ 
          v.c1 ++ v.obj1.p1 ! vpa ++ v.c2 ++ v.obj2.p1 ! vpa ++ v.adv ++ v.ext   ---- appComplCase
            ++ c.s ++  
          wv.p1 ++ w.adV ++ wv.p2 ++ wv.p3 ++ w.adj ! vpa ++                ---- appComplCase
          w.c1 ++ w.obj1.p1 ! vpa ++ w.c2 ++ w.obj2.p1 ! vpa ++ w.adv ++ w.ext ;
    inf = \\a => 
            infVP a (lin VP v) ++ c.s ++ infVP a (lin VP w) ;
    c1 = [] ; ---- w.c1 ? --- the full story is to unify v and w...
    c2 = [] ; ---- w.c2 ? 
    } ;

  UseVPC x vpc = { ---- big loss of quality (overgeneration) seems inevitable
    v   = \\a => <[], [], vpc.v ! a> ;
    inf = <[], vpc.inf ! defaultAgr> ; ---- agreement
    c1  = vpc.c1 ;
    c2  = vpc.c2 ;
    adj = \\a => [] ;
    obj1 = <noObj, defaultAgr> ;
    obj2 = <noObj,True> ;
    adv,adV = [] ;
    ext = [] ;
    qforms = \\a => <"do", vpc.inf ! defaultAgr> ; ---- do/does/did
    } ;

  StartClC c x a b = {
    s  = declCl (lin Cl a) ++ c.s ++ declCl (lin Cl b) ;
    c3 = b.c3 ; ---- 
    } ;

  UseClC x cl = {
    subj = [] ;
    v    = <[],[],cl.s> ; ----
    inf  = <[],[]> ;
    adj  = [] ;
    obj1 = [] ;
    obj2 = [] ;
    adV  = [] ;
    adv  = [] ;
    ext  = [] ;
    c3   = cl.c3 ;
    qforms = <[],[]> ; ---- qforms
    } ;




---- the following may become parameters for a functor

oper
  vPastPart : AAgr -> VForm = \_ ->  VPastPart ;
  vPresPart : AAgr -> VForm = \_ ->  VPresPart ;

  be_V : V = lin V {v = mkVerb "be" "is" "was" "been" "being" ; c1,c2 = [] ; isAux = True ; isSubjectControl = False} ;

  negAdV : Pol -> Str = \p -> p.s ;

  reflPron : Agr -> Str = \a -> case a of {
    Ag Sg P1 => "myself" ;
    Ag Sg P2 => "yourself" ;
    Ag Sg P3 => "herself" | "himself" | "itself" ; ----
    Ag Pl P1 => "ourselves" ;
    Ag Pl P2 => "ourselves" ;
    Ag Pl P3 => "yourselves"
    } ;

  infVP : Agr -> VP -> Str = \a,vp -> 
    let 
      a2 = case vp.obj2.p2 of {True => a ; False => vp.obj1.p2} 
    in
      vp.adV ++ vp.inf.p1 ++ vp.inf.p2 ++ 
      vp.adj ! a ++ vp.c1 ++ vp.obj1.p1 ! a ++ vp.c2 ++ vp.obj2.p1 ! a2 ++ vp.adv ++ vp.ext ;

  qformsV : Str -> STense -> Anteriority -> Polarity -> VAgr -> V -> Str * Str = 
    \sta,t,a,p,agr,v -> 
    let 
      verb  = tenseActV sta t a Neg agr v ;
      averb = tenseActV sta t a p agr v
    in case <v.isAux, t, a> of {
      <False,Pres|Past,Simul> => case p of {
        Pos => < verb.p1,           verb.p3> ;   -- does , sleep
        Neg => < verb.p1,  verb.p2>              -- does , not sleep  ---- TODO: doesn't , sleep
        } ; 
      _  => <averb.p1, averb.p2>
      } ;

  qformsBe : Str -> STense -> Anteriority -> Polarity -> VAgr -> Str * Str = 
    \sta,t,a,p,agr -> 
    let verb = be_AuxL sta t a p agr
    in <verb.p1, verb.p2> ;                     -- is , not  ---- TODO isn't , 

  tenseV : Str -> STense -> Anteriority -> Polarity -> Voice -> VAgr -> V -> Str * Str * Str = 
    \sta,t,a,p,o,agr,v -> 
    case o of {  
      Act  => tenseActV sta t a p agr v ;
      Pass => tensePassV sta t a p agr v 
      } 
      |    ---- leaving out variants makes compilation time go down from 900ms to 300ms. 
           ---- parsing time of "she sleeps" goes down from 300ms to 60ms. 4/2/2014 
    case o of {  
      Act  => tenseActVContracted sta t a p agr v ;
      Pass => tensePassVContracted sta t a p agr v
      } ;

  tenseActV : Str -> STense -> Anteriority -> Polarity -> VAgr -> V -> Str * Str * Str = \sta,t,a,p,agr,v -> 
    let vt : VForm = case <t,agr> of {
        <Pres,VASgP3>  => VPres ; 
        <Past|Cond,_ > => VPast ; 
        _              => VInf
        } ; 
    in 
    case <t,a> of {  
    <Pres|Past, Simul> =>
      case v.isAux of {
        True           => <sta ++ v.v ! vt,      [],                              []> ;
        False          => case p of {
          Pos          => <[],                   sta ++ v.v ! vt,                 []> ;                 -- this is the deviating case
          Neg          => <do_Aux       vt Pos,  not_Str p,                       sta ++ v.v ! VInf>
          }
       } ;

    <Pres|Past, Anter> => <have_Aux     vt Pos,  not_Str p,                       sta ++ v.v ! VPastPart> ;
    <Fut|Cond,  Simul> => <will_Aux     vt Pos,  not_Str p,                       sta ++ v.v ! VInf> ;
    <Fut|Cond,  Anter> => <will_Aux     vt Pos,  not_Str p ++ have_Aux VInf Pos,  sta ++ v.v ! VPastPart>
    } ;

  tenseActVContracted : Str -> STense -> Anteriority -> Polarity -> VAgr -> V -> Str * Str * Str = \sta,t,a,p,agr,v -> 
    let vt : VForm = case <t,agr> of {
        <Pres,VASgP3>  => VPres ; 
        <Past|Cond,_ > => VPast ; 
        _              => VInf
        } ; 
    in 

    case <t,a> of {  
    <Pres|Past, Simul> =>
      case v.isAux of {
        True           => <sta ++ v.v ! vt,      [],                              []> ;
        False          => case p of {
          Pos          => <[],                   sta ++ v.v ! vt,                 []> ;                 -- this is the deviating case
          Neg          => <do_Aux       vt p,    [],                              sta ++ v.v ! VInf>
          }
       } ;
    <Pres|Past, Anter> => <have_AuxC    vt p,    [],                              sta ++ v.v ! VPastPart>
                        | <have_AuxC    vt Pos,  not_Str p,                       sta ++ v.v ! VPastPart> ; 
    <Fut|Cond,  Simul> => <will_AuxC    vt p,    [],                              sta ++ v.v ! VInf>
                        | <will_AuxC    vt Pos,  not_Str p,                       sta ++ v.v ! VInf> ; 
    <Fut|Cond,  Anter> => <will_AuxC    vt p,    have_Aux VInf Pos,               sta ++ v.v ! VPastPart>
                        | <will_AuxC    vt Pos,  not_Str p ++ have_Aux VInf Pos,  sta ++ v.v ! VPastPart> 
    } ;

  tensePassV : Str -> STense -> Anteriority -> Polarity -> VAgr -> V -> Str * Str * Str = \sta,t,a,p,agr,v -> 
    let 
      be   = be_AuxL sta t a p agr ;
      done = v.v ! VPastPart
    in 
    <be.p1, be.p2, be.p3 ++ done> ;
  tensePassVContracted : Str -> STense -> Anteriority -> Polarity -> VAgr -> V -> Str * Str * Str = \sta,t,a,p,agr,v -> 
    let 
      be   = be_AuxC sta t a p agr ;
      done = v.v ! VPastPart
    in 
    <be.p1, be.p2, be.p3 ++ done> ;

  tenseInfV : Str -> Anteriority -> Polarity -> Voice -> V -> Str * Str = \sa,a,p,o,v ->
    case a of {
      Simul => <[],                sa ++ v.v ! VInf> ;       -- hon vill sova
      Anter => <have_Aux VInf Pos, sa ++ v.v ! VPastPart>    -- hon vill (ha) sovit
      } ;

----- dangerous variants for PMCFG generation - keep apart as long as possible
  be_Aux : Str -> STense -> Anteriority -> Polarity -> VAgr -> Str * Str * Str = \sta,t,a,p,agr -> 
    be_AuxL sta t a p agr | be_AuxC sta t a p agr ; 
  be_AuxL : Str -> STense -> Anteriority -> Polarity -> VAgr -> Str * Str * Str = \sta,t,a,p,agr -> 
    let 
      beV = tenseActV sta t a p agr be_V 
    in
    case <t,a,p,agr> of {
      <Pres,Simul,Pos,VASgP3> => <"is" ++ sta,                 [],    []> ;
      <Pres,Simul,Pos,VASgP1> => <"am" ++ sta,                 [],    []> ;
      <Pres,Simul,Pos,VAPl>   => <"are" ++ sta,                [],    []> ;
      <Pres,Simul,Neg,VASgP3> => <"is" ++ sta,                 "not", []> ;
      <Pres,Simul,Neg,VASgP1> => <"am" ++ sta,                 "not", []> ;
      <Pres,Simul,Neg,VAPl>   => <"are" ++ sta,                "not", []> ;
      <Past,Simul,Pos,VAPl>   => <"were" ++ sta,               [],    []> ; 
      <Past,Simul,Neg,VAPl>   => <"were" ++ sta,               "not", []> ;
      <Past,Simul,Neg,_>      => <"was" ++ sta,                "not", []>  ;
      _ => beV
      } ;
  be_AuxC : Str -> STense -> Anteriority -> Polarity -> VAgr -> Str * Str * Str = \sta,t,a,p,agr -> 
    let 
      beV = tenseActVContracted sta t a p agr be_V 
    in
    case <t,a,p,agr> of {
      <Pres,Simul,Pos,VASgP3> => <Predef.BIND ++ "'s" ++ sta,  [],    []> ;
      <Pres,Simul,Pos,VASgP1> => <Predef.BIND ++ "'m" ++ sta,  [],    []> ;
      <Pres,Simul,Pos,VAPl>   => <Predef.BIND ++ "'re" ++ sta, [],    []> ;
      <Pres,Simul,Neg,VASgP3> => <Predef.BIND ++ "'s" ++ sta,  "not", []>
                               | <"isn't" ++ sta,              [],    []> ;
      <Pres,Simul,Neg,VASgP1> => <Predef.BIND ++ "'m" ++ sta,  "not", []> ;
      <Pres,Simul,Neg,VAPl>   => <Predef.BIND ++ "'re" ++ sta, "not", []>
                               | <"aren't" ++ sta,             [],    []> ;
      <Past,Simul,Pos,VAPl>   => <"were" ++ sta,               [],    []> ; 
      <Past,Simul,Neg,VAPl>   => <"weren't" ++ sta,            [],    []> ;
      <Past,Simul,Neg,_>      => <"wasn't" ++ sta,            [],    []> ;
      _ => beV
      } ;

  declCl       : Clause -> Str = \cl -> cl.subj ++ cl.v.p1 ++ cl.adV ++ cl.v.p2 ++ restCl cl ;
  declSubordCl : Clause -> Str = declCl ;
  declInvCl    : Clause -> Str = declCl ;

  questCl : QCl -> Str = \cl -> case cl.focType of {
    NoFoc   => cl.foc ++ cl.qforms.p1 ++ cl.subj ++ cl.adV ++ cl.qforms.p2 ++ restCl cl ;  -- does she sleep
    FocObj  => cl.foc ++ cl.qforms.p1 ++ cl.subj ++ cl.adV ++ cl.qforms.p2 ++ restCl cl ;  -- who does she love
    FocSubj => cl.foc ++ cl.v.p1      ++ cl.subj ++ cl.adV ++ cl.v.p2      ++ restCl cl    -- who loves her
    } ;

  questSubordCl : QCl -> Str = \cl -> 
    let 
      rest = cl.subj ++ cl.adV ++ cl.v.p1 ++ (cl.v.p2 | []) ++ restCl cl 
    in case cl.focType of {
      NoFoc   => "if" ++ cl.foc ++ rest ;  -- om she sleeps
      FocObj  =>         cl.foc ++ rest ;  -- who she loves / why she sleeps
      FocSubj =>         cl.foc ++ rest    -- who loves her
      } ;

  that_Compl : Str = "that" | [] ;

  -- this part is usually the same in all reconfigurations
  restCl : Clause -> Str = \cl -> cl.v.p3 ++ cl.adj ++ cl.obj1 ++ cl.obj2 ++ cl.adv ++ cl.ext ++ cl.c3 ;

  agentCase : ComplCase = "by" ;

  appComplCase : ComplCase -> NP -> Str = \p,np -> p ++ np.s ! Acc ;

  noComplCase : ComplCase = [] ;

  prepComplCase : Prep -> ComplCase = \p -> p.s ; 

  noObj : Agr => Str = \\_ => [] ;

  addObj2VP : VerbPhrase -> (Agr => Str) -> VerbPhrase = \vp,obj -> vp ** {
    obj2 = <\\a => vp.obj2.p1 ! a ++ obj ! a, vp.obj2.p2> ;
    } ;

  addExtVP : VerbPhrase -> Str -> VerbPhrase = \vp,ext -> vp ** {
    ext = ext ;
    } ;




---- the lexicon is just for testing: use standard Eng lexicon and morphology instead

lin
  sleep_V = mkV "sleep" "slept" "slept" [] [] ;
  walk_V = mkV "walk" ;
  love_V2 = mkV "love" ;
  look_V2 = mkV "look" "at" [] ;
  believe_VS = mkV "believe" ;
  tell_V2S = mkV "tell" "told" "told" [] [] ;
  prefer_V3 = mkV "prefer" [] "to" ;
  want_VV = mkV "want" [] "to" ;
  force_V2V = mkV "force" [] "to" ;
---  promise_V2V = mkV "promise" [] "to" ** {isSubjectControl = True} ;
  wonder_VQ = mkV "wonder" ;
  become_VA = mkV "become" "became" "become" [] [] ;
  become_VN = mkV "become" "became" "become" [] [] ;
  make_V2A = mkV "make" "made" "made" [] [] ;
  promote_V2N = mkV "promote" [] "to" ;
  ask_V2Q = mkV "ask" ;

  old_A = {s = \\_ => "old" ; c1 = [] ; c2 = [] ; obj1 = \\_ => []} ;
  married_A2 = {s = \\_ => "married" ; c1 = "to" ; c2 = [] ; obj1 = \\_ => []} ;
  eager_AV = {s = \\_ => "eager" ; c1 = [] ; c2 = "to" ; obj1 = \\_ => []} ;
  easy_A2V = {s = \\_ => "easy" ; c1 = "for" ; c2 = "to" ; obj1 = \\_ => []} ;

  professor_N = {s = table {Sg => "professor" ; Pl => "professors"} ; c1 = [] ; c2 = [] ; obj1 = \\_ => []} ;
  manager_N2 = {s = table {Sg => "manager" ; Pl => "managers"} ; c1 = "for" ; c2 = [] ; obj1 = \\_ => []} ;

  she_NP = {s = table {Nom => "she" ; Acc => "her"} ; a = Ag Sg P3} ;
  we_NP = {s = table {Nom => "we" ; Acc => "us"} ; a = Ag Pl P1} ;

  today_Adv = {s = "today" ; isAdV = False} ;
  always_AdV = {s = "always" ; isAdV = True} ;

  who_IP = {s = "who" ; a = Sg} ;

  PrepNP p np = {s = p.s ++ np.s ! Acc ; isAdV = False} ;

  with_Prep = {s = "with"} ;

  and_Conj = {s = "and"} ;

  why_IAdv = {s = "why"} ;

oper
  mkV = overload {
    mkV : Str -> V = \s -> lin V {v = mkVerb s (s + "s") (edV s) (edV s) (ingV s) ; c1 = [] ; c2 = [] ; isAux,isSubjectControl = False} ; 
    mkV : Str -> Str -> Str -> V = \s,p,q -> lin V {v = mkVerb s (s + "s") (edV s) (edV s) (ingV s) ; c1 = p ; c2 = q ; isAux,isSubjectControl = False} ; 
    mkV : Str -> Str -> Str -> Str -> Str -> V = \s,t,u,p,q -> lin V {v = mkVerb s (s + "s") t u (ingV s) ; c1 = p ; c2 = q ; isAux,isSubjectControl = False} ; 
    } ;

  mkVerb : Str -> Str -> Str -> Str -> Str -> VForm => Str = \go,goes,went,gone,going -> table {
    VInf => go ;
    VPres => goes ;
    VPast => went ;
    VPastPart => gone ;
    VPresPart => going
    } ;

  edV  : Str -> Str = \s -> case s of {us + "e" => us ; _ => s} + "ed" ;
  ingV : Str -> Str = \s -> case s of {us + "e" => us ; _ => s} + "ing" ;

---- have to split the tables to two to get reasonable PMCFG generation
  will_Aux : VForm -> Polarity -> Str = \vf,p -> case <vf,p> of {
    <VInf|VPres, Pos> => varAux "will" "ll" ;
    <VInf|VPres, Neg> => "won't" ;
    <VPast|_   , Pos> => varAux "would" "d" ; 
    <VPast|_   , Neg> => "wouldn't"
    } ; 
  will_AuxC : VForm -> Polarity -> Str = \vf,p -> case <vf,p> of {
    <VInf|VPres, Pos> => varAuxC "will" "ll" ;
    <VInf|VPres, Neg> => "won't" ;
    <VPast|_   , Pos> => varAuxC "would" "d" ; 
    <VPast|_   , Neg> => "wouldn't"
    } ; 

  have_Aux : VForm -> Polarity -> Str = \vf,p -> case <vf,p> of {
    <VInf,     Pos> => varAux "have" "ve" ;  --- slightly overgenerating if used in infinitive
    <VInf,     Neg> => "haven't" ;
    <VPres,    Pos> => varAux "has" "s" ;
    <VPres,    Neg> => "hasn't" ;
    <VPast|_ , Pos> => varAux "had" "d" ; 
    <VPast|_ , Neg> => "hadn't"
    } ; 
  have_AuxC : VForm -> Polarity -> Str = \vf,p -> case <vf,p> of {
    <VInf,     Pos> => varAuxC "have" "ve" ;  --- slightly overgenerating if used in infinitive
    <VInf,     Neg> => "haven't" ;
    <VPres,    Pos> => varAuxC "has" "s" ;
    <VPres,    Neg> => "hasn't" ;
    <VPast|_ , Pos> => varAuxC "had" "d" ; 
    <VPast|_ , Neg> => "hadn't"
    } ; 

  do_Aux : VForm -> Polarity -> Str = \vf,p -> case <vf,p> of {
    <VInf,     Pos> => "do" ;
    <VInf,     Neg> => "don't" ;
    <VPres,    Pos> => "does" ;
    <VPres,    Neg> => "doesn't" ;
    <VPast|_ , Pos> => "did" ; 
    <VPast|_ , Neg> => "didn't"
    } ; 

  varAux  : Str -> Str -> Str = \long,short -> long ; ----| Predef.BIND ++ ("'" + short) ;
  varAuxC : Str -> Str -> Str = \long,short ->              Predef.BIND ++ ("'" + short) ;

  not_Str : Polarity -> Str = \p -> case p of {Pos => [] ; Neg => "not"} ;

}