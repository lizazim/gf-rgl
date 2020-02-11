resource ParadigmsJpn = CatJpn **
  open ResJpn, CatJpn, Prelude in {

flags coding = utf8 ;

oper

  VerbGroup : Type ;
  gr1 : VerbGroup ; -- Basic form ends in -u, consonant stem.
  gr2 : VerbGroup ; -- Basic form ends in -iru/-eru, vowel stem.
  suru : VerbGroup ; -- Irregular: kuru
  kuru : VerbGroup ; -- Irregular: suru

  mkN = overload {
    mkN : (man : Str) -> N -- Inanimate noun. Counter is つ and not replaceable.
      = \n -> lin N (regNoun n Inanim "つ" False True) ;  ---- AR 15/11/2014
    mkN : (man : Str) -> (anim : Animateness) -> N -- Animacy given as argument. Counter is つ and not replaceable.
      = \n,a -> lin N (regNoun n a "つ" False True) ;
    mkN : (kane,okane : Str) -> (anim : Animateness) -> N -- Style variation (plain, respectful) and animacy given. Counter is つ and not replaceable.
      = \kane,okane,a -> lin N (styleNoun kane okane a "つ" False True) ;
    mkN : (man : Str) -> (anim : Animateness) -> (counter : Str) -> (counterReplace : Bool) -> N -- No style variation. Arguments are animacy, counter and whether counter is replaceable.
      = \n,a,c,b -> lin N (regNoun n a c b False) ;
    mkN : (man : Str) -> (anim : Animateness) -> (counter : Str) -> (counterReplace : Bool) ->
          (men : Str) -> N -- Like previous, but unpredictable plural.
      = \n,a,c,b,pl -> lin N (numberNoun n a c b pl False) ;
    mkN : (kane,okane : Str) -> (anim : Animateness) -> (counter : Str) ->
          (counterReplace : Bool) -> N -- Style variation, animacy, counter and whether counter is replaceable.
      = \kane,okane,a,c,b -> lin N (styleNoun kane okane a c b False) ;
    mkN : (tsuma,okusan : Str) -> (anim : Animateness) -> (counter : Str) ->
          (counterReplace : Bool) -> (tsumatachi : Str) -> N  -- Worst case paradigm: style variation, animacy, counter, whether counter is replaceable and unpredictable plural.
      = \tsuma,okusan,a,c,b,tsumatachi ->
             lin N (mkNoun tsuma okusan tsumatachi tsumatachi a c b False)
    } ;

  mkN2 : (man : Str) -> (anim : Animateness) -> (counter : Str) -> (counterReplace : Bool) ->
         (men : Str) -> (prep : Str) -> N2 = \n,a,c,b,pl,pr ->
          lin N2 (numberNoun n a c b pl False) ** {prep = pr ; object = \\st => []} ;

  mkN3 : (distance : Str) -> (prep1: Str) -> (prep2: Str) -> (anim : Animateness) -> N3
      = \n,p1,p2,a -> lin N3 (regNoun n a "つ" False True) ** {prep1 = p1; prep2 = p2} ;

  mkPN = overload {
    mkPN : (paris : Str) -> PN
      = \n -> lin PN (regPN n) ;
    mkPN : (jon,jonsan : Str) -> PN
      = \jon,jonsan -> lin PN (personPN jon jonsan)
    } ;

  mkPron = overload {
    mkPron : (kare : Str) -> (Pron1Sg : Bool) -> (anim : Animateness) -> Pron
      = \kare,b,a -> lin Pron (regPron kare b a) ;
    mkPron : (boku,watashi : Str) -> (Pron1Sg : Bool) -> (anim : Animateness) -> Pron
      = \boku,watashi,b,a -> lin Pron (stylePron boku watashi b a)
    } ;

  mkA = overload {
    mkA : (ookina : Str) -> A = \a -> lin A (regAdj a) ;
    mkA : (kekkonshiteiru,kikonno : Str) -> A = \pred,attr -> lin A (VerbalA pred attr)
    } ;

  mkA2 = overload {
    mkA2 : (yasui : Str) -> (prep : Str) -> A2 = \a,p -> lin A2 (regAdj a) ** {prep = p} ;
    mkA2 : (pred : Str) -> (attr : Str) -> (prep : Str) -> A2 =
           \pred,attr,pr -> lin A2 (VerbalA pred attr) ** {prep = pr}
    } ;

  mkV = overload {
    mkV : (yomu : Str) -> V -- Default: group 1 verb
      = \yomu -> lin V (mkVerb yomu Gr1) ; ---- AR 15/11/2014
    mkV : (yomu : Str) -> (group : VerbGroup) -> V
      = \yomu,gr -> lin V (mkVerb yomu gr) ; -- Base form and verb group given
    } ;

  mkV2 = overload {
    mkV2 : (yomu : Str) -> V2 -- Group 1 verb, を as object marker
        = \yomu -> lin V2 (mkVerb2 yomu "を" Gr1) ;   ---- AR 15/11/2014
    mkV2 : (yomu, prep : Str) -> (group : VerbGroup) -> V2 -- Base form, object marker and verb group given
        = \yomu,p,gr -> lin V2 (mkVerb2 yomu p gr) ;
    } ;

  mkV3 = overload {
    mkV3 : (yomu : Str) -> V3 -- Group 1 verb, に and を as object markers
      = \yomu -> lin V3 (mkVerb3 yomu "に" "を" Gr1) ;
    mkV3 : (uru, p1, p2 : Str) -> (group : VerbGroup) -> V3 -- Base form, object markers and verb group given
      = \uru,p1,p2,gr -> lin V3 (mkVerb3 uru p1 p2 gr) ;
    } ;

  mkVS : (yomu : Str) -> VS
    = \yomu -> lin VS (mkVerb2 yomu "ことを" Gr1) ;

  mkVV : (yomu : Str) -> VV
    = \yomu -> lin VV (mkVerbV yomu Gr1) ;

  mkV2V : (yomu : Str) -> V2V
    = \yomu -> lin V2V (mkVerb yomu Gr1) ;

  mkV2S : (yomu : Str) -> V2S
    = \yomu -> lin V2S (mkVerb yomu Gr1) ;

  mkVQ : (yomu : Str) -> VQ
    = \yomu -> lin VQ (mkVerb2 yomu "を" Gr1) ;

  mkVA : (yomu : Str) -> VA
     = \yomu -> lin VA (mkVerb yomu Gr1) ;

  mkV2A : (yomu : Str) -> V2A
    = \yomu -> lin V2A (mkVerb yomu Gr1) ;

  mkAdv : Str -> Adv
    = \s -> lin Adv (ResJpn.mkAdv s) ;   ---- AR 15/11/2014

  mkPrep : Str -> Prep
    = \s -> lin Prep (ResJpn.mkPrep s) ;   ---- AR 15/11/2014

  mkDet : Str -> Det = \d -> lin Det (ResJpn.mkDet d d ResJpn.Sg) ;

  mkConj : Str -> Conj = \c -> lin Conj (ResJpn.mkConj c ResJpn.And) ;

  mkInterj : Str -> Interj
    = \s -> lin Interj (ss s) ;

  mkgoVV : VV = lin VV {s = \\sp => mkGo.s ; te = \\sp => mkGo.te ;
             a_stem = \\sp => mkGo.a_stem ;
             i_stem = \\sp => mkGo.i_stem ;
             ba = \\sp => mkGo.ba ;
             te_neg = \\sp => "行かないで" ;
             ba_neg = \\sp => "行かなければ" ;
             sense = Abil} ;

--.
  -- Hidden definitions

  VerbGroup : Type = ResJpn.VerbGroup ;
  gr1 : VerbGroup = Gr1 ;
  gr2 : VerbGroup = Gr2 ;
  suru : VerbGroup = Suru ;
  kuru : VerbGroup = Kuru ;
}
