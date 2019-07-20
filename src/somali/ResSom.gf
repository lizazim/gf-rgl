resource ResSom = ParamSom ** open Prelude, Predef, ParamSom in {

--------------------------------------------------------------------------------
-- Nouns
oper

  Noun : Type = {
    s : NForm => Str ;
    gda : GenderDefArt ;
    shortPoss : Bool ;
    } ;
  Noun2 : Type = Noun ; -- TODO eventually more parameters?
  Noun3 : Type = Noun ;

  CNoun : Type = Noun ** {
    mod : Number => Case => Str ;
    hasMod : Bool ;
    isPoss : Bool -- to prevent impossible forms in ComplN2 with Ns that have short possessive, e.g. "father"
    } ;

  cn2str : Number -> Case -> CNoun -> Str = \n,c,cn ->
    cn.s ! Indef n ++ cn.mod ! n ! c ;

  PNoun : Type = {s : Str ; a : Agreement} ;

  mkPNoun : Str -> Agreement -> PNoun = \str,agr -> {s = str ; a = agr} ;

  mkNoun : (x1,_,_,x4 : Str) -> Gender -> Noun = \wiil,wiilka,wiilal,wiilasha,gender -> {
    s = table {
          Def Sg => hooya ; Def Pl => gury ;
          Indef Sg => wiil ; Indef Pl => wiilal ;
          -- Special forms for feminine nouns
          NomSg => bisadi ; Numerative => bisadood
          } ;
    gda = defAllomorph wiilka wiilasha ;
    shortPoss = False
    } where {
        hooya : Str = case wiilka of {
                        aabb + "aha" => aabb ;
                        hooya + "da" => hooya ;
                        wiila + "sha" => wiila ;
                        _ => wiil} ;
        gury : Str = case wiilasha of {
                        gury + "aha" => gury ;
                        magacya + "da" => magacya ;
                        wiila + "sha" => wiila ;
                        _ => wiilal} ;
        bisadi : Str = case gender of
                   { Fem  => case wiil of { _ + #c => wiil+"i" ; _ => wiil} ;
                     Masc => wiil } ;
        bisadood : Str = case gender of
                       { Fem  => case wiilal of {_ + "o" => wiilal+"od" ; _ => wiil} ;
                         Masc => wiil }

    } ;
-------------------------
-- Regular noun paradigms
  nHooyo, nAabbe, nMas, nUl, nGuri, nXayawaan : Str -> Noun ;

  --1) Feminine nouns that end in -o
  nHooyo hooyo =
    mkNoun hooyo (init hooyo + "ada") (hooyo + "oyin") (hooyo + "oyinka") Fem ;

  --2) Masculine nouns that end in -e
  nAabbe aabbe = let aabb = init aabbe in
    mkNoun aabbe (aabb + "aha") (aabb + "ayaal") (aabb + "ayaasha") Masc ;

  -- 3) Masculine, plural with duplication
  nMas mas = let s = last mas ;
                 a = last (init mas) ;
                 ka = allomorph mKa mas in
    mkNoun mas (mas + ka) (mas + a + s) (mas + a + s + ka) Masc ;

  -- Irregular one-syllable masculine word
  nWiil : (_,_ : Str) -> Noun = \wiil,wiilal ->
    let ka = allomorph mKa wiil ;
        sha = allomorph mTa wiilal ;
        wiila : Str = case wiilal of {wiila + "l" => wiila ; _ => wiilal} in
    mkNoun wiil (wiil + ka) wiilal (wiila + sha) Masc ;

  -- 4a) Feminine, plural with ó
  nUl ul = let o  = case last ul of { "i" => "yo" ; _ => "o" } ;
               u  = case last ul of { "l" => init ul ; _ => ul } ;
               sha = allomorph mTa ul in
    mkNoun ul (u + sha) (ul + o) (ul + "aha") Fem ;

  -- 4b) Masculine, plural with ó, 2 syllables
  nGuri guri = let o = allomorph mO guri ;
                   ga = allomorph mKa guri ;
                   gury = case last guri of { -- TODO does this generalise? Or just exception?
                                 "i" => init guri + "y" ;
                                 _   => guri } in
    mkNoun guri (guri + ga) (gury + o) (gury + "aha") Masc ;

  -- 4c) Masculine, plural with -ó, 3 syllables or longer
  nXayawaan x = let ka = allomorph mKa x ;
                    o = allomorph mO x ;
                    xo = x + o in
    mkNoun x (x + ka) xo (init xo + "ada") Masc ;

  nMaalin : (_,_ : Str) -> Gender -> Noun = \maalin,maalmo,g ->
   let ta = case g of { Masc => allomorph mKa maalin ;
                        Fem  => allomorph mTa maalin } ;
       aha = case g of { Masc|Fem  => "aha" } ; ---- ?
   in mkNoun maalin (maalin + ta) maalmo (init maalmo + aha) g ;

-------------------------
-- Smart paradigms

  mkN1 : Str -> Noun = \n -> case n of {
      _ + ("ad"|"adh") => nUl n ;
      _ + "o"          => nHooyo n ;
      _ + "e"          => nAabbe n ;
      _ + "ri"         => nGuri n ;
      (#c + #v + #v + #c) -- One syllable words
       | (#v + #v + #c)
       | (#c + #v + #c)
       | (#v + #c)     => nMas n ;
      _                => nXayawaan n } ;

  mk2N : Str -> Str -> Noun = nWiil ;

  mkNg : Str -> Gender -> Noun = \n,g -> case n of {
      _ -- + ("r"|"n"|"l"|"g")
          => case g of {
                  Fem  => nUl n ;
                  Masc => mkN1 n } ;
      _   => mkN1 n
   } ; -- TODO: add more exceptional cases

---------------------------------------------
-- NP

  BaseNP : Type = {
    a : Agreement ;
    isPron : Bool ;
    empty : Str ;
    } ;

  NounPhrase : Type = BaseNP ** {s : Case => Str} ;

  NPLite : Type = {s : Str ; a : AgreementPlus} ; -- Used in Adv and as an object in VP

  nplite : NounPhrase -> NPLite = \np ->
    let aplus : AgreementPlus = agr2agrplus np.isPron np.a in
    case <np.isPron,np.a> of {
      <False,_>          => {s = np.s ! Abs ; a = aplus} ;
      -- <True,(Sg3 _|Pl3)> => {s = np.empty ++ (pronTable ! np.a).sp ; a = aplus} ; -- uncomment if you want to add long object pronoun for 3rd person object
      _ => {s = np.empty ; a = aplus} } ; -- no long object for other pronouns

  useN : Noun -> CNoun ** BaseNP = \n -> n **
    { mod = \\_,_ => [] ; hasMod = False ;
      a = Sg3 (gender n) ; isPron,isPoss = False ;
      empty = [] ;
    } ;

  emptyNP : NounPhrase = {
    s = \\_ => [] ;
    a = Pl3 ;
    isPron = False ;
    empty = [] ;
    } ;

  impersNP : NounPhrase = emptyNP ** {
    a = Impers ;
    isPron = True
    } ;

--------------------------------------------------------------------------------
-- Pronouns

  Pronoun : Type = NounPhrase ** {
    poss : { -- for PossPron : Pron -> Quant
      s : DefArticle => Str ;
      sp : GenNum => Str ; -- independent forms, e.g. M:kayga F:tayda Pl:kuwayga
      short : DefArticle => Str -- short possessive suffix: e.g. family members, my/your name
      } ;
    sp : Str ;
    } ;

  pronTable : Agreement => Pronoun = table {
    Sg1 => {
      s = table {Nom => "aan" ; Abs => "i"} ;
      a = Sg1 ; isPron = True ; sp = "aniga" ;
      empty = [] ;
      poss = {s = quantTable "ayg" "ayd" ; short = quantTable "ay" ; sp = gnTable "ayg" "ayd" "uwayg"}
      } ;
    Sg2 => {
      s = table {Nom => "aad" ; Abs => "ku"} ;
      a = Sg2 ; isPron = True ; sp ="adiga" ;
      empty = [] ;
      poss = {s = quantTable "aag" "aad" ; short = quantTable "aa" ; sp = gnTable "aag" "aad" "uwaag"}
      } ;
    Sg3 Masc => {
      s = table {Nom => "uu" ; Abs => []} ;
      a = Sg3 Masc ; isPron = True ; sp ="isaga" ;
      empty = [] ;
      poss = {s, short = quantTable "iis" ; sp = gnTable "iis" "iis" "uwiis"}
      } ;
    Sg3 Fem => {
      s = table {Nom => "ay" ; Abs => []} ;
      a = Sg3 Fem ; isPron = True ; sp = "iyada" ;
      empty = [] ;
      poss = {s, short = quantTable "eed" ; sp = gnTable "eed" "eed" "uweed"}
      } ;
    Pl1 Excl => {
      s = table {Nom => "aan" ; Abs => "na"} ;
      a = Pl1 Excl ; isPron = True ; sp ="annaga" ;
      empty = [] ;
      poss = {s = quantTable "eenn" ; short = quantTable "een" ; sp = gnTable "eenn" "eenn" "uweenn"}
      } ;
    Pl1 Incl => {
      s = table {Nom => "aynu" ; Abs => "ina"} ;
      a = Pl1 Incl ; isPron = True ; sp ="innaga" ;
      empty = [] ;
      poss = {s = quantTable "eenn" ; short = quantTable "een" ; sp = gnTable "eenn" "eenn" "uweenn"}
      } ;
    Pl2 => {
      s = table {Nom => "aad" ; Abs => "idin"} ;
      a =  Pl2 ; isPron = True ; sp ="idinka" ;
      empty = [] ;
      poss = {s = quantTable "iinn" ; short = quantTable "iin" ; sp = gnTable "iinn" "iinn" "uwiinn"}
      } ;
    Pl3 => {
      s = table {Nom => "ay" ; Abs => []} ;
      a = Pl3 ; isPron = True ; sp = "iyaga" ;
      empty = [] ;
      poss = {s, short = quantTable "ood" ; sp = gnTable "ood" "ood" "uwood"}
      } ;
    Impers => {
      s = table {Nom => "la" ; Abs => "??"} ;
      a = Impers ; isPron = True ; sp = "??" ;
      empty = [] ;
      poss = {s, short = quantTable "??" ; sp = gnTable "??" "??" "??"}
      }
    } ;

  secondObject : AgreementPlus => Str = table {
    IsPron Sg1        => "kay" ;
    IsPron Sg2        => "kaa" ;
    IsPron (Pl1 Excl) => "kayo" ;
    IsPron (Pl1 Incl) => "keen" ;
    IsPron Pl2        => "kiin" ;
    _                 => []
    } ;

--------------------------------------------------------------------------------
-- Det, Quant, Card, Ord

  BaseQuant : Type = {
    s : DefArticle => Case => Str ;
    isPoss : Bool ;
    shortPoss : DefArticle => Str ; -- short form of possessive, e.g. family members
    st : State ;
    } ;

  Determiner : Type = BaseQuant ** {
    sp : Gender => Case => Str ;
    n : Number ;
    isNum : Bool ;  -- placement in NP + whether to choose Numerative from CN
    } ;

  Quant : Type = BaseQuant ** {
    sp : GenNum => Case => Str ;
    } ;

  BaseNum : Type = {
    s : DForm => Str ; -- independent or attribute
    thousand : Str ; -- TODO check where possessive suffix goes
    da : DefArticle ;
    n : Number
    } ;

  baseNum : Num = {
    s = \\_ => [] ;
    thousand = [] ;
    da = M KA ;
    n = Sg ;
    isNum = False
    } ;

  Num : Type = BaseNum ** {
    isNum : Bool -- whether to choose Numerative as the value of NForm
    } ;

  Numeral : Type = BaseNum ** {
    ord : Str -- whether to choose Numerative as the value of NForm
    } ;

  baseQuant : BaseQuant = {
    s = \\alm,c => [] ;
    isPoss = False ;
    shortPoss = \\_ => [] ;
    st = Indefinite
  } ;

  defQuant = defQuantBind True ;

  defQuantBind : (bind : Bool) -> (s, kan, tan, kuwan : Str) -> (vowIsI : Bool) -> Quant = \b,s,spm,spf,spp,v ->
    let bind : Str -> Str = \x -> case b of {False => x ; True => BIND ++ x} ;
    in baseQuant ** {
        s = \\allomorph,c =>
           let nom = case v of {False => "u" ; _ => s + "i"}
            in case c of {
                Nom => bind (quantTable nom ! allomorph) ;
                _   => bind (quantTable s ! allomorph) } ;
        sp = \\gn,c =>
           let i = case c of {Nom => "i"; _ => []}
           in gnTable (spm + i) (spf + i) (spp + i) ! gn ;
        st = Definite ;
        } ;

  gnTable : (m,f,p : Str) -> (GenNum => Str) = \m,f,p ->
    table {SgMasc => m ; SgFem => f ; _ => p} ;

  indefQuant : Quant = baseQuant ** {
    s = \\da,c => [] ;
    sp = \\gn,c => [] ;
    st = Indefinite ;
    } ;

--------------------------------------------------------------------------------
-- Prepositions

  Prep : Type = {s : Agreement => Str} ;

  mkPrep : (x1,_,_,_,_,x6 : Str) -> Prep = \ku,ii,kuu,noo,idiin,loo -> {
    s = table {
          Sg1      => ii ;
          Sg2      => kuu ;
          Pl2      => idiin ;
          Pl1 Excl => noo ;
          Pl1 Incl => "i" + noo ;
          Impers   => loo ;
          _        => ku
        }
    } ;
  prep : Preposition -> (Prep ** {c2 : Preposition}) = \p -> prepTable ! P p ** {c2 = p} ;

  prepTable : PrepositionPlus => Prep = table {
    P Ku => mkPrep "ku" "igu" "kugu" "nagu" "idinku" "lagu" ;
    P Ka => mkPrep "ka" "iga" "kaa" "naga" "idinka" "laga" ;
    P La => mkPrep "la" "ila" "kula" "nala" "idinla" "lala" ;
    P U  => mkPrep "u" "ii" "kuu" "noo" "idiin" "loo" ;
    P NoPrep => mkPrep [] "i" "ku" "na" "idin" "la" ;
    -- impersonal subject clitic combining with object clitics.
    Passive => mkPrep "la" "la i" "lagu" "nala" "laydin" "la"
  } ;

  prepCombTable : Agreement => PrepCombination => Str = table {
    Sg1 => table { Ugu => "iigu" ; Uga => "iiga" ;
                   Ula => "iila" ; Kaga => "igaga" ;
                   Kula => "igula" ; Kala => "igala" ;
                   Single p => (prepTable ! p).s ! Sg1 } ;
    Sg2 => table { Ugu => "kuugu" ; Uga => "kaaga" ;
                   Ula => "kuula" ; Kaga => "kaaga" ;
                   Kula => "kugula" ; Kala => "kaala" ;
                   Single p => (prepTable ! p).s ! Sg2 } ;
    Pl1 Excl =>
           table { Ugu => "noogu" ; Uga => "nooga" ;
                   Ula => "noola" ; Kaga => "nagaga" ;
                   Kula => "nagula" ; Kala => "nagala" ;
                   Single p => (prepTable ! p).s ! Pl1 Excl } ;
    Pl1 Incl =>
           table { Ugu => "inoogu" ; Uga => "inooga" ;
                   Ula => "inoola" ; Kaga => "inagaga" ;
                   Kula => "inagula" ; Kala => "inagala" ;
                   Single p => (prepTable ! p).s ! Pl1 Incl } ;
    Pl2 => table { Ugu => "idiinku" ; Uga => "idiinka" ;
                   Ula => "idiinla" ; Kaga => "idinkaga" ;
                   Kula => "idinkula" ; Kala => "idinkala" ;
                   Single p => (prepTable ! p).s ! Pl2 } ;
    Impers =>
           table { Ugu => "loogu" ; Uga => "looga" ;
                   Ula => "loola" ; Kaga => "lagaga" ;
                   Kula => "lagula" ; Kala => "lagala" ;
                   Single p => (prepTable ! p).s ! Impers } ;
    a   => table { Ugu => "ugu" ; Uga => "uga" ;
                   Ula => "ula" ; Kaga => "kaga" ;
                   Kula => "kula" ; Kala => "kala" ;
                   Single p => (prepTable ! p).s ! a }
  } ;

--------------------------------------------------------------------------------
-- Adjectives

-- Sequences of adjectives follow the rules for restrictive relatives clauses, i.e. are linked by oo 'and' on an indefinite head NounPhrase and by ee 'and' on a definite NounPhrase (8.1).

 -- Komparativ
 -- För att uttrycka motsvarigheten till svenskans komparativ placerar man på somaliska helt enkelt prepositionen ká 'från, av, än' framför adjektivet i fråga. Adjektivet får ingen ändelse.
 -- Shan waa ay ká yar tahay siddéed. Fem är mindre än åtta.
 -- Superlativ
 -- Motsvarigheten till svenskans superlativ bildas med prepositionsklustret ugú som till sin betydelse närmast motsvarar svenskans allra, t.ex.
 -- ugu horrayntii (det att komma) allra först

  Adjective : Type = {s : AForm => Str} ;
  Adjective2 : Type = Adjective ** {c2 : Preposition} ;


  duplA : Str -> Adjective = \yar ->
    let yaryar = duplicate yar
    in mkAdj yar yaryar ;

  mkAdj : (str,pl : Str) -> Adjective = \sg,pl -> {
    s = table {
          AF Sg Nom => sg + "i" ;
          AF Pl Nom => pl + "i" ;
          AF Sg _ => sg ;
          AF Pl _ => pl }
    } ;

  duplicate : Str -> Str = \sg -> case sg of {
    -- some hard-coded cases; in general, better to
    -- use 2-paradigm mkAdj for irregular adjectives.
    "dheer" => "dhaadheer" ;
    "weyn"  => "waaweyn" ;

    -- general patterns
    a@#v + d@#c + ? + ?  -- 4 letters of form CVXX
        => a + d + sg ; -- ad+adag
    g@#c + aa@#vv + _
        => g + aa + sg ; -- gaa+gaaban
    y@#c + a@#v + r@#c + _
        => y + a + r + sg ; -- yar+yar ; fud+fudud
    d@#c + h@#c + uu@#vv + _
        => d + h + uu + sg ; -- dhuu+dhuuban
    q@#c + a@#v + y@#vstar + b@#c + _
        => q + a + y + b + sg ; --qayb+qaybsan, fiic+fiican
    _   => sg + sg } ;

  AdjPhrase : Type = Adjective ;
--------------------------------------------------------------------------------
-- Verbs

  BaseVerb : Type = {
    s : VForm => Str ;
    } ;

  Verb : Type = BaseVerb ** {
    sii : Str ; -- closed class of particles: sii, soo, kala, wada (Sayeed 171)
    dhex : Str ; -- closed class of adverbials: hoos, kor, dul, dhex, …
    } ;
  Verb2 : Type = Verb ** {c2 : Preposition} ;
  Verb3 : Type = Verb2 ** {c3 : Preposition} ;


  -- Saeed page 79:
  -- "… the reference form is the imperative singular form
  -- since it corresponds to the form of the basic root."
  mkVerb : (imperative,sg1,pl2 : Str) -> Verb = \qaado,qaat,ark ->
    let stems : {p1 : Str ; p2 : Str} = case ark of {
          a + r@#c + k@#c -- two consonants need a vowel in between
            => <ark + "i", a + r + a + voiced k> ;
          _ + #c -- if the pl2 root ends in consonant, infinitive needs a vowel
            => <ark + "i", ark> ;
          yar + "ee"  -- double e turns into ey
            => <ark + "n", yar + "ey"> ;
          _ => <ark + "n", ark> -- no changes, just add n for infinitive
        } ;
        arki = stems.p1 ;
        arag = stems.p2 ;
        arkin = case last arki of { -- The negative past tense ends in n:
                  "n" => arki ;         -- if infinitive ends in n, no change;
                   _  => arki + "n" } ; -- otherwise add n.


        progr : Str = case qaat of { -- Progressive
               _ + "eey"     => stems.p2 + "nay" ; -- bireey -> bireynay
               _ + ("y"|"n") => init qaat + "nay" ; -- akhriy -> akhrinay ; gashad -> gashanay
               _ + #v + "t"  => qaat + "ay" ;
               _ + #c + "t"  => init qaat + "anay" ;
               _             => qaat + "ay" } ;

        -- Some predictable sound changes
        t : Str = case arag of { -- kari+seen, bixi noq+deen, (sug|joogsa|qaada)+teen,
               _ + ("i"|"y") => "s" ;     -- t changes into s in front of i/y
               _ + ("x"|"q"|"c") => "d" ; -- t changes into d in front of x/q/c
               _             => "t" } ;
        ay : Str = case ark of {
               _ + ("i"|"e") => "ey" ;
               _             => "ay" } ;
        n : Str = case arag of {
               _ + #v => "nn" ; -- n duplicates after vowel
               _      => "n" } ;
        an : Str = case qaado of {
               _ + "o" => "an" ; -- Allomorph for imperatives
               _       => "in" } ;

   in { s = table {
          VPres Simple Sg1_Sg3Masc pol
                                    => qaat     + if_then_Pol pol "aa" "o" ;
          VPres Simple Sg2_Sg3Fem pol
                                    => arag + t + if_then_Pol pol "aa" "o" ;
          VPres Simple Pl1_ pol     => arag + n + if_then_Pol pol "aa" "o"  ;
          VPres Simple Pl2_ pol     => arag + t + "aan" ;
          VPres Simple Pl3_ pol     => qaat     + "aan" ;

          VPres Progressive Sg1_Sg3Masc pol
                                     => progr + if_then_Pol pol "aa" "o" ;
          VPres Progressive Sg2_Sg3Fem pol
                                     => progr + if_then_Pol pol "saa" "so" ;
          VPres Progressive Pl1_ pol
                                     => progr + if_then_Pol pol "naa" "no"  ;
          VPres Progressive Pl2_ pol => progr + "saan" ;
          VPres Progressive Pl3_ pol => progr + "aan" ;

          VPast Simple Sg1_Sg3Masc
                                     => qaat     + ay ;
          VPast Simple Sg2_Sg3Fem => arag + t + ay ; -- t, d or s
          VPast Simple Pl1_       => arag + n + ay ;
          VPast Simple Pl2_       => arag + t + "een" ; -- t, d or s
          VPast Simple Pl3_       => qaat     + "een" ;

          VPast Progressive Sg1_Sg3Masc
                                          => progr + "ey" ;
          VPast Progressive Sg2_Sg3Fem => progr + "sey" ;
          VPast Progressive Pl1_       => progr + "ney" ;
          VPast Progressive Pl2_       => progr + "seen" ;
          VPast Progressive Pl3_       => progr + "een" ;

          VNegPast Simple      => arkin ;
          VNegPast Progressive => progr + "n" ;


          VImp Sg Pos   => arag ;
          VImp Pl Pos   => qaat + "a" ;
          VImp Sg Neg   => arag + an ;
          VImp Pl Neg   => qaat + "ina" ;

          VInf          => arki ;
          VRel          => arki } ; -- TODO does this exist?
        sii, dhex = [] ;
      } ;

-------------------------
-- Regular verb paradigms

  cSug, cKari, cYaree, cJoogso, cQaado : Str -> Verb ;

  -- 1: Root verbs with no lexical affixes, e.g. sug TR 'wait for', kar INTR 'boil, cook';
  cSug sug =
    let cabb : Str = case sug of {
          _ + "b" => sug + "b" ; -- TODO: more duplication patterns
          _       => sug }
     in mkVerb sug cabb sug ;

  -- 2A: Verbs derived from root verbs by the causative affix -i/-is, e.g. kari TR 'cook' (from conjugation 1 kar INTR 'boil, cook');
  -- 2B: Verbs derived from nouns and adjectives by the causative/factitive affix -eel-ayn, e.g. yaree 'make small' (from yar ADJ 'small');
  cKari, cYaree = \kari -> mkVerb kari (kari+"y") kari ;

  -- 3A: Verbs derived from verbal stems by the middle voice affix -ol­/at
  -- e.g. karsó 'cook for oneself (from conjugation 2 kâri TR 'cook');
  cJoogso joogso =
    let joogsa = init joogso + "a" ;
     in mkVerb joogso (joogsa + "d") joogsa ;

  -- 3B: As conjugation 3A but verbs whose syllable structure triggers
  -- stem contraction and subsequent sandhi rules, e.g. qaadó 'take for oneself
  -- (from conjugation 1 qàad TR 'take').
  cQaado qaado =
    let qaa = init (init qaado)
     in mkVerb qaado  -- Imperative sg, with the vowel
              (qaa + "t")    -- Per1 Sg, Per3 Pl and Per3 Sg Masc
              (qaa + "da") ; -- Per2 Pl and others

  -- Constructs verbs like u baahan+ahay
  prefixV : Str -> Verb -> Verb = \s,v -> v ** {
    s = \\vf => s + v.s ! vf
  } ;

------------------
-- Irregular verbs
  presCopula : {agr:Agreement ; pol:Polarity} => Str =
    \\a => case <a.agr,a.pol> of {
        <Sg1,pol>    => if_then_Pol pol "ahay" "ihi" ;
        <Sg2,pol>    => if_then_Pol pol "tahay" "ihid" ;
        <(Sg3 Masc|Impers),pol> => if_then_Pol pol "yahay" "aha" ;
        <(Sg3 Fem),pol> => if_then_Pol pol "tahay" "aha" ;
        <(Pl1 _),pol> => if_then_Pol pol "nahay" "ihin" ;
        <Pl2,pol>     => if_then_Pol pol "tihiin" "ihidin" ;
        <Pl3,pol>     => if_then_Pol pol "yihiin" "aha"
  } ;

  copula : Verb = {
    s = table {
          VPast _ Sg1_Sg3Masc
                          => "ahaa" ;
          VPast _ Sg2_Sg3Fem
                          => "ahayd" ;
          VPast _ Pl1_    => "ahayn" ;
          VPast _ Pl2_    => "ahaydeen" ;
          VPast _ Pl3_    => "ahaayeen" ;
          VNegPast _      => "ahi" ;
          VRel            => "ah" ;
          VInf            => "ahaan" ;
          VImp Sg pol     => if_then_Pol pol "ahaw" "ahaanin" ;
          VImp Pl pol     => if_then_Pol pol "ahaada" "ahaanina" ;
          VPres _ _ _     => nonExist -- use presCopula instead
          } ;
      sii, dhex = []
     } ;

  have_V : Verb =
   let hold_V = mkVerb "hayso" "haysat" "haysa" in hold_V ** {
    s = table {
          VPres _ Sg1_Sg3Masc Pos => "leeyahay" ;
          VPres _ Sg2_Sg3Fem  Pos => "leedahay" ;
          VPres _ Pl1_        Pos => "leenahay" ;
          VPres _ Pl2_        Pos => "leedihiin" ;
          VPres _ Pl3_        Pos => "leeyihiin" ;
          VPast asp agr          => "l" + copula.s ! VPast asp agr ;
          VRel                  => "leh" ;
          x                     => hold_V.s ! x }
    } ;

-- Till VERBFRASEN ansluter sig
-- · satstypsmarkörer (waa, ma...),
-- · subjekts-pronomenet la man,
-- · objektspronomenen,
-- · prepositionerna och
-- · riktnings-adverben soó (mot en plats/person), sií (bort frånen plats/person), wadá tillsammans (mot en gemensam punkt), kalá iväg, isär (bort från en gemensam punkt).
-- Riktningsadverben har ibland en mycket konkret betydelse, men många gånger är betydelsen mera abstrakt.

-- Till satsmarkörerna, dvs. både fokusmarkörerna och satstypsmarkörerna ansluter sig
-- subjektspronomenen aan, aad, uu, ay, aynu, men inte la (man).

------------------
-- VP

  BaseAdv : Type = {
    sii, -- sii, soo, wala, kada go inside VP.
    dhex, -- dhex, hoos, koor, dul, … go inside VP.
    berri : Str -- e.g. "tomorrow"; goes before VP.
    } ;

  Adverb : Type = BaseAdv ** {
    c2 : Preposition ; -- adverbs can contribute to preposition contraction.
    np : NPLite ; -- NP from PrepNP can be promoted into a core argument.
    } ;

  Complement : Type = {
    comp : Agreement => {p1,p2 : Str} ; -- Agreement for AP complements
    pred : PredType ; -- to choose right sentence type marker and copula
    } ;

  VerbPhrase : Type = BaseVerb ** Complement ** BaseAdv ** {
    -- Prepositions can combine together and with object pronoun.
    c2 : PrepositionPlus ; -- hack to implement passives more efficiently:
    c3 : Preposition ;     -- if c2 is Passive, the real preposition is in c3.
    obj2 : NPLite ; -- {s : Str ; a : AgreementPlus}
    secObj : Str ; -- if two overt pronoun objects
    vComp : Str ; -- VV complement
    refl : Str ; -- reflexive is put here, if the verb has an obj2.
    miscAdv : Str ; -- dump for any other kind of adverb, that isn't
    } ;             -- in a closed class of particles or made with PrepNP.

  VPSlash : Type = VerbPhrase ;

  useV : Verb -> VerbPhrase = \v -> v ** {
    comp = \\_ => <[],[]> ;
    pred = NoPred ;
    vComp,berri,miscAdv,refl = [] ;
    c2 = P NoPrep ;
    c3 = NoPrep ;
    obj2 = {s = [] ; a = NotPronP3} ;
    secObj = []
    } ;

  useVc : Verb2 -> VPSlash = \v2 -> useV v2 ** {
    c2 = P v2.c2
    } ;

  passV2 : Verb2 -> VerbPhrase = \v2 -> passVP (useV v2) ;

  passVP : VerbPhrase -> VerbPhrase = \vp -> vp ** {
    c2 = Passive ;
    c3 = pp2prep vp.c2 ;
    } ;

  complSlash : VPSlash -> VerbPhrase = \vps ->  let np = vps.obj2 in vps ** {
    comp = \\agr => let cmp = vps.comp ! agr in
      {p1 = np.s ++ cmp.p1 ; -- if object is a noun, it will come before verb in the sentence.
                             -- if object is a pronoun, np.s is empty.
       p2 = cmp.p2 ++ vps.refl ++ compl np.a vps} -- object combines with the preposition of the verb.
      } ;

  compl : AgreementPlus -> VerbPhrase -> Str = \a,vp ->
    let agr = case a of {IsPron x => x ; _ => Pl3} ;
     in prepCombTable ! agr ! combine vp.c2 vp.c3 ;

  insertRefl : VPSlash -> VPSlash = \vps ->
    case <vps.c2,vps.c3> of {
            <P NoPrep,NoPrep> => vps ** {refl = "is"} ; -- not bound
            _ => vps ** {refl = "is" ++ BIND}
    } ;

  insertComp : VPSlash -> NounPhrase -> VerbPhrase = \vp,np ->
    insertCompAgrPlus vp (nplite np) ;

  insertCompAgrPlus : VPSlash -> NPLite -> VerbPhrase = \vp,nplite ->
    case vp.obj2.a of {
      -- If the old object is 3rd person (or nonexistent), we replace its agreement.
      -- We keep both old and new string (=noun, if there was one) in obj2.s.
      NotPronP3|IsPron (Sg3 _|Pl3|Impers) =>
        vp ** {obj2 = nplite ** {
                  s = vp.obj2.s ++ nplite.s}
                  } ; -- no secObj, because there's ≤1 non-3rd-person pronoun.

      -- If old object was non-3rd person, we keep its agreement.
      -- The new object is put in the secondObject field.
      _ =>
          vp ** {obj2 = vp.obj2 ** {
                    s = vp.obj2.s ++ nplite.s
                    } ;
                 secObj = vp.secObj ++ secondObject ! nplite.a}

    } ;

  insertAdv : VerbPhrase -> Adverb -> VerbPhrase = \vp,adv ->
    case <adv.c2, adv.np.a> of { --isP3 adv.np.a, adv.np.isPron> of {
      <NoPrep,_>    => vp ** adv'' ; -- a) the adverb is not formed with PrepNP, e.g. "tomorrow"
      <_,NotPronP3> => vp ** adv'' ; -- b) is formed with PrepNP, and has 3rd person obj, which is a noun.
      _ => case <vp.c2,isP3 vp.obj2.a,vp.c3> of {
             -- if free complement slots, introduce adv.np with insertComp
             <P NoPrep,True,_> => insertCompAgrPlus (vp ** {c2 = P adv.c2}) adv.np ** adv' ;
             <_  ,_   ,NoPrep> => insertCompAgrPlus (vp ** {c3 =   adv.c2}) adv.np ** adv' ;

             -- if complement slots are full, just insert strings.
             _ => vp ** adv''
            }
    } where {
        adv' : {sii,dhex,berri : Str} = adv ; -- adv.np done with insertComp
        adv'' : {sii,dhex,berri,miscAdv : Str} -- adv.np inserted into miscAdv
          = adv ** {dhex = (prepTable ! P adv.c2).s ! agrplus2agr adv.np.a ++ adv.dhex ;
                    miscAdv = adv.np.s}
        } ;
--------------------------------------------------------------------------------
-- Sentences etc.
  Clause : Type = {s : Bool {-is question-} => Tense => Anteriority => Polarity => Str} ;
  QClause : Type = {s : Tense => Anteriority => Polarity => Str} ;
  RClause,
  ClSlash,
  Sentence : Type = SS ; ---- TODO

  predVP : NounPhrase -> VerbPhrase -> Clause = \np,vps -> {
    s = \\isQ,t,a,p =>
       let predRaw : {fin : Str ; inf : Str} = vf t a p subj.a vp ;
           pred : {fin : Str ; inf : Str} = case <isQ,p,vp.pred> of {
              <False,Pos,NoCopula> => {fin,inf = []} ;
              <_    ,  _,Copula>   => {fin = presCopula ! {agr=subj.a ; pol=p} ; inf=[]} ;
              _                    => predRaw
           } ;
           subjnoun : Str = if_then_Str np.isPron np.empty (subj.s ! Nom) ;
           subjpron : Str = if_then_Str np.isPron (subj.s ! Nom) np.empty ;
           obj : {p1,p2 : Str} =
              let o : {p1,p2 : Str} = vp.comp ! subj.a ;
                  bind : Str = case <isP3 vp.obj2.a, vp.c2> of {
                                 <True,P NoPrep> => [] ;
                                 _               => BIND } ;
               in case p of {
                    Pos => o ;
                    Neg => {p2 = [] ; p1 = o.p1 ++ o.p2 ++ bind} -- object pronoun, prepositions and negation all contract
                  } ;
           stm : Str = case  <isQ,p,vp.pred,subj.a> of {
                       <False,Pos,Copula|NoCopula,Sg3 _|Impers> => "waa" ;
                       <True ,Pos,_              ,_           > => "ma" ;
                       _ => case <np.isPron,p> of {
                              <True,Pos> => "waa" ++ subjpron ; -- to force some string from NP to show in the tree
                              <True,Neg> => "ma" ; -- ++ subjpron ; -- TODO check subj pron or not?
                              <False>    => stmarkerNoContr ! subj.a ! p
                            }
                  } ;
      in wordOrder subjnoun subjpron stm obj pred vp ;
    } where {
        vp = case vps.c2 of {
               Passive => complSlash (insertComp vps np) ;
               _       => complSlash vps } ;
        subj = case vps.c2 of {Passive => impersNP ; _ => np} ;
      } ;

  wordOrder : (sn,sp,stm : Str) -> {p1,p2 : Str} -> {fin,inf : Str} -> VerbPhrase -> Str =
    \subjnoun,subjpron,stm,obj,pred,vp -> vp.berri -- AdV
                  ++ subjnoun -- subject if it's a noun
                  ++ obj.p1   -- object if it's a noun
                  ++ stm      -- sentence type marker + possible subj. pronoun
                  ++ obj.p2   -- object if it's a pronoun
                  ++ vp.sii   -- restricted set of particles
                  ++ vp.dhex  -- restricted set of nouns/adverbials
                  ++ vp.secObj   -- "second object"
                  ++ vp.vComp    -- VV complement
                  ++ pred.inf    -- potential infinitive/participle
                  ++ pred.fin    -- the verb inflected
                  ++ vp.miscAdv ; ---- NB. Only used if there are several adverbs.
                                  ---- Primary places for adverbs are obj, sii or dhex.

  vf : Tense -> Anteriority -> Polarity -> Agreement -> Verb
    -> {fin : Str ; inf : Str} = \t,ant,p,agr,vp ->
    case <t,ant> of {
      <Pres,Simul> => {fin = presV vp      ; inf = [] } ;
      <Past,Simul> => {fin = pastV vp      ; inf = [] } ;
      <Pres,Anter> => {fin = presCopula ! agrPol ; inf = vp.s ! VInf } ; ---- just guessing
      <Past,Anter> => {fin = pastV (cSug "jir")  ; inf = vp.s ! VInf} ;
      <Fut,Simul>  => {fin = presV (cSug "doon") ; inf = vp.s ! VInf} ;
      <Fut,Anter>  => {fin = pastV (cSug "doon") ; inf = vp.s ! VInf} ;
      <Cond,Simul> => {fin = pastV have_V ; inf = vp.s ! VInf} ; -- TODO check
      <Cond,Anter> => {fin = pastV have_V ; inf = vp.s ! VInf}   -- TODO check
      }
  where {
    agrPol : {agr:Agreement ; pol:Polarity} = {agr=agr; pol=p} ;
    pastV : Verb -> Str = \v ->
      case p of { Neg => v.s ! VNegPast Simple ;
                  Pos => v.s ! VPast Simple (agr2vagr agr) } ;

    presV : Verb -> Str = \v -> v.s ! VPres Simple (agr2vagr agr) p ;
  } ;

  infVP : VerbPhrase -> Str = \vp ->
    let inf = (vf Past Anter Pos (Sg3 Masc) vp) ** {fin=[]}
     in wordOrder [] [] [] (vp.comp ! Pl3) inf vp ;

  stmarker : Agreement => Polarity => Str = \\a,b =>
    let stm = if_then_Pol b "w" "m"
     in stm + subjpron ! a ;

  stmarkerNoContr : Agreement => Polarity => Str = \\a,b =>
    let stm = if_then_Pol b "waa" "ma"
     in stm ++ subjpron ! a ;

  subjpron : Agreement => Str = table {
    Sg1|Pl1 Excl => "aan" ;
    Pl1 Incl  => "aynu" ;
    Sg2|Pl2   => "aad" ;
    Sg3 Masc  => "uu" ;
    Impers    => [] ;
    _         => "ay" } ;

--------------------------------------------------------------------------------
-- linrefs

oper
  linVP : VerbPhrase -> Str = infVP ;
  linCN : CNoun -> Str = \cn -> cn.s ! NomSg ++ cn.mod ! Sg ! Abs ;
  linAdv : Adverb -> Str = \adv ->
     adv.berri
  ++ adv.sii
  ++ (prepTable ! P adv.c2).s ! Pl3 --adv.np.a
  ++ adv.dhex
  ++ adv.np.s ;

}
