# =============================================================================
# WHOQOL-BREF Power Analysis
# Two paradigms:
#   Paradigma A: Recovery power — popModel / naiveModel / optModel → analyzeModel
#   Paradigma B: Misspecification detection power — H1model → analyzeModel
#
# Sources:
#   Lin & Yao (2022) — meta-EFA + SNA, 16 studies, Psy Assessment
#   Mosqueira-Taipe et al. (2026) — systematic review COSMIN, 350 studies
# =============================================================================

# ── ITEM NOTATION ─────────────────────────────────────────────────────────────
#  Psychological  : Q5  Q6  Q7  Q11 Q19 Q26
#  Physical       : Q3  Q4  Q10 Q15 Q16 Q17 Q18
#  Social         : Q20 Q21 Q22
#  Environmental  : Q8  Q9  Q12 Q13 Q14 Q23 Q24 Q25

# =============================================================================
# SECTION 1 — POPULATION MODELS (fixed parameters; data-generating)
# =============================================================================

popmodel <- '
  # ── Factor loadings: empirical estimates from Lin & Yao (2022) ────────────
  psycho      =~ 0.92*Q5  + 0.81*Q6  + 0.94*Q7  +
                 0.73*Q11 + 0.75*Q19 + 0.63*Q26

  physical    =~ 0.84*Q3  + 0.83*Q4  + 0.63*Q10 +
                 0.71*Q15 + 0.68*Q16 + 0.89*Q17  + 0.61*Q18

  social      =~ 0.94*Q20 + 0.89*Q21 + 0.78*Q22

  environment =~ 0.37*Q8  + 0.49*Q9  + 0.79*Q12 + 0.81*Q13 +
                 0.77*Q14 + 0.75*Q23  + 0.64*Q24 + 0.73*Q25

  # ── Residual covariance Q3~~Q4 ────────────────────────────────────────────
  # r(Q3,Q4|physical) = 0.30 (method bias / conceptual proximity)
  # cov = 0.30 × sqrt(1-0.84²) × sqrt(1-0.83²) = 0.0908
  Q4 ~~ 0.0908*Q3

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  # Range reported in Lin & Yao (2022): 0.08 to 0.31
  # Conservative midpoint = 0.20 for all pairs
  psycho      ~~ 1*psycho      + 0.2*physical + 0.2*social + 0.2*environment
  physical    ~~ 1*physical    + 0.2*social   + 0.2*environment
  social      ~~ 1*social      + 0.2*environment
  environment ~~ 1*environment

  # ── Residual variances: θ = 1 − λ² (standardised indicators) ─────────────
  Q5  ~~ 0.1536*Q5    # 1 − 0.92²
  Q6  ~~ 0.3439*Q6    # 1 − 0.81²
  Q7  ~~ 0.1164*Q7    # 1 − 0.94²
  Q11 ~~ 0.4671*Q11   # 1 − 0.73²
  Q19 ~~ 0.4375*Q19   # 1 − 0.75²
  Q26 ~~ 0.6031*Q26   # 1 − 0.63²
  Q3  ~~ 0.2944*Q3    # 1 − 0.84²
  Q4  ~~ 0.3111*Q4    # 1 − 0.83²
  Q10 ~~ 0.6031*Q10   # 1 − 0.63²
  Q15 ~~ 0.4959*Q15   # 1 − 0.71²
  Q16 ~~ 0.5376*Q16   # 1 − 0.68²
  Q17 ~~ 0.2079*Q17   # 1 − 0.89²
  Q18 ~~ 0.6279*Q18   # 1 − 0.61²
  Q20 ~~ 0.1164*Q20   # 1 − 0.94²
  Q21 ~~ 0.2079*Q21   # 1 − 0.89²
  Q22 ~~ 0.3916*Q22   # 1 − 0.78²
  Q8  ~~ 0.8631*Q8    # 1 − 0.37² — lowest loading; bridge item (betweenness=40.5)
  Q9  ~~ 0.7599*Q9    # 1 − 0.49²
  Q12 ~~ 0.3759*Q12   # 1 − 0.79²
  Q13 ~~ 0.3439*Q13   # 1 − 0.81²
  Q14 ~~ 0.4071*Q14   # 1 − 0.77²
  Q23 ~~ 0.4375*Q23   # 1 − 0.75²
  Q24 ~~ 0.5904*Q24   # 1 − 0.64²
  Q25 ~~ 0.4671*Q25   # 1 − 0.73²
'

naivemodel <- '
  # ── Factor loadings: tau-equivalent (uniform λ per domain) ───────────────
  psycho      =~ 0.5328*Q5  + 0.5328*Q6  + 0.5328*Q7  +
                 0.5328*Q11 + 0.5328*Q19 + 0.5328*Q26

  physical    =~ 0.4758*Q3  + 0.4758*Q4  + 0.4758*Q10 +
                 0.4758*Q15 + 0.4758*Q16 + 0.4758*Q17  + 0.4758*Q18

  social      =~ 0.6017*Q20 + 0.6017*Q21 + 0.6017*Q22

  environment =~ 0.4832*Q8  + 0.4832*Q9  + 0.4832*Q12 + 0.4832*Q13 +
                 0.4832*Q14 + 0.4832*Q23  + 0.4832*Q24 + 0.4832*Q25

  # ── Residual covariance Q3~~Q4 ────────────────────────────────────────────
  # r(Q3,Q4|physical) = 0.30; cov = 0.30 × (1 − 0.4758²) = 0.2321
  Q4 ~~ 0.2321*Q3

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  # φ = 0.30: upper bound of Lin & Yao (2022) range — pessimistic scenario
  psycho      ~~ 1*psycho      + 0.3*physical + 0.3*social + 0.3*environment
  physical    ~~ 1*physical    + 0.3*social   + 0.3*environment
  social      ~~ 1*social      + 0.3*environment
  environment ~~ 1*environment

  # ── Residual variances: θ = 1 − λ² per domain ────────────────────────────
  Q5  ~~ 0.7161*Q5    # Psychological: θ = 1 − 0.5328² = 0.7161
  Q6  ~~ 0.7161*Q6
  Q7  ~~ 0.7161*Q7
  Q11 ~~ 0.7161*Q11
  Q19 ~~ 0.7161*Q19
  Q26 ~~ 0.7161*Q26
  Q3  ~~ 0.7736*Q3    # Physical: θ = 1 − 0.4758² = 0.7736
  Q4  ~~ 0.7736*Q4
  Q10 ~~ 0.7736*Q10
  Q15 ~~ 0.7736*Q15
  Q16 ~~ 0.7736*Q16
  Q17 ~~ 0.7736*Q17
  Q18 ~~ 0.7736*Q18
  Q20 ~~ 0.6379*Q20   # Social: θ = 1 − 0.6017² = 0.6379
  Q21 ~~ 0.6379*Q21
  Q22 ~~ 0.6379*Q22
  Q8  ~~ 0.7665*Q8    # Environmental: θ = 1 − 0.4832² = 0.7665
  Q9  ~~ 0.7665*Q9
  Q12 ~~ 0.7665*Q12
  Q13 ~~ 0.7665*Q13
  Q14 ~~ 0.7665*Q14
  Q23 ~~ 0.7665*Q23
  Q24 ~~ 0.7665*Q24
  Q25 ~~ 0.7665*Q25
'

optmodel <- '
  # ── Factor loadings: tau-equivalent (uniform λ per domain) ───────────────
  psycho      =~ 0.7113*Q5  + 0.7113*Q6  + 0.7113*Q7  +
                 0.7113*Q11 + 0.7113*Q19 + 0.7113*Q26

  physical    =~ 0.6837*Q3  + 0.6837*Q4  + 0.6837*Q10 +
                 0.6837*Q15 + 0.6837*Q16 + 0.6837*Q17  + 0.6837*Q18

  social      =~ 0.7661*Q20 + 0.7661*Q21 + 0.7661*Q22

  environment =~ 0.6424*Q8  + 0.6424*Q9  + 0.6424*Q12 + 0.6424*Q13 +
                 0.6424*Q14 + 0.6424*Q23  + 0.6424*Q24 + 0.6424*Q25

  # ── Residual covariance Q3~~Q4 ────────────────────────────────────────────
  # r(Q3,Q4|physical) = 0.30; cov = 0.30 × (1 − 0.6837²) = 0.1598
  Q4 ~~ 0.1598*Q3

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  # φ = 0.08: lower bound of Lin & Yao (2022) range — optimistic scenario
  psycho      ~~ 1*psycho      + 0.08*physical + 0.08*social + 0.08*environment
  physical    ~~ 1*physical    + 0.08*social   + 0.08*environment
  social      ~~ 1*social      + 0.08*environment
  environment ~~ 1*environment

  # ── Residual variances: θ = 1 − λ² per domain ────────────────────────────
  Q5  ~~ 0.4941*Q5    # Psychological: θ = 1 − 0.7113² = 0.4941
  Q6  ~~ 0.4941*Q6
  Q7  ~~ 0.4941*Q7
  Q11 ~~ 0.4941*Q11
  Q19 ~~ 0.4941*Q19
  Q26 ~~ 0.4941*Q26
  Q3  ~~ 0.5326*Q3    # Physical: θ = 1 − 0.6837² = 0.5326
  Q4  ~~ 0.5326*Q4
  Q10 ~~ 0.5326*Q10
  Q15 ~~ 0.5326*Q15
  Q16 ~~ 0.5326*Q16
  Q17 ~~ 0.5326*Q17
  Q18 ~~ 0.5326*Q18
  Q20 ~~ 0.4130*Q20   # Social: θ = 1 − 0.7661² = 0.4130
  Q21 ~~ 0.4130*Q21
  Q22 ~~ 0.4130*Q22
  Q8  ~~ 0.5873*Q8    # Environmental: θ = 1 − 0.6424² = 0.5873
  Q9  ~~ 0.5873*Q9
  Q12 ~~ 0.5873*Q12
  Q13 ~~ 0.5873*Q13
  Q14 ~~ 0.5873*Q14
  Q23 ~~ 0.5873*Q23
  Q24 ~~ 0.5873*Q24
  Q25 ~~ 0.5873*Q25
'

h1model <- '
  # ── Factor loadings (with three cross-loadings) ───────────────────────────
  psycho      =~ 0.92*Q5  + 0.81*Q6  + 0.94*Q7  +
                 0.73*Q11 + 0.75*Q19 + 0.63*Q26  +
                 0.55*Q8  +                             # cross-load (1)
                 0.21*Q9                                # cross-load (2)

  physical    =~ 0.84*Q3  + 0.83*Q4  + 0.63*Q10 +
                 0.71*Q15 + 0.68*Q16 + 0.89*Q17  + 0.61*Q18

  social      =~ 0.94*Q20 + 0.89*Q21 + 0.78*Q22

  environment =~ 0.37*Q8  + 0.49*Q9  + 0.79*Q12 + 0.81*Q13 +
                 0.77*Q14 + 0.75*Q23  + 0.64*Q24 + 0.73*Q25 +
                 0.24*Q15                               # cross-load (3)

  # ── Residual covariance Q3~~Q4 (fixed in both P2 and analyzeModel) ────────
  Q4 ~~ 0.0908*Q3

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  psycho      ~~ 1*psycho      + 0.2*physical + 0.2*social + 0.2*environment
  physical    ~~ 1*physical    + 0.2*social   + 0.2*environment
  social      ~~ 1*social      + 0.2*environment
  environment ~~ 1*environment

  # ── Residual variances ────────────────────────────────────────────────────
  Q5  ~~ 0.1536*Q5
  Q6  ~~ 0.3439*Q6
  Q7  ~~ 0.1164*Q7
  Q11 ~~ 0.4671*Q11
  Q19 ~~ 0.4375*Q19
  Q26 ~~ 0.6031*Q26
  Q3  ~~ 0.2944*Q3
  Q4  ~~ 0.3111*Q4
  Q10 ~~ 0.6031*Q10
  Q15 ~~ 0.3701*Q15   # UPDATED: was 0.4959 — cross-load on environment
  Q16 ~~ 0.5376*Q16
  Q17 ~~ 0.2079*Q17
  Q18 ~~ 0.6279*Q18
  Q20 ~~ 0.1164*Q20
  Q21 ~~ 0.2079*Q21
  Q22 ~~ 0.3916*Q22
  Q8  ~~ 0.4792*Q8    # UPDATED: was 0.8631 — cross-load on psycho
  Q9  ~~ 0.6746*Q9    # UPDATED: was 0.7599 — cross-load on psycho
  Q12 ~~ 0.3759*Q12
  Q13 ~~ 0.3439*Q13
  Q14 ~~ 0.4071*Q14
  Q23 ~~ 0.4375*Q23
  Q24 ~~ 0.5904*Q24
  Q25 ~~ 0.4671*Q25
'

# =============================================================================
# SECTION 2 — ANALYSIS MODEL (free parameters; used in BOTH paradigmas)
# =============================================================================

analyzemodel <- '
  # ── Factor loadings: freely estimated ─────────────────────────────────────
  psycho      =~ Q5  + Q6  + Q7  + Q11 + Q19 + Q26
  physical    =~ Q3  + Q4  + Q10 + Q15 + Q16 + Q17 + Q18
  social      =~ Q20 + Q21 + Q22
  environment =~ Q8  + Q9  + Q12 + Q13 + Q14 + Q23 + Q24 + Q25

  # ── Factor variances (=1) and free interfactor correlations ───────────────
  psycho      ~~ 1*psycho      + physical + social + environment
  physical    ~~ 1*physical    + social   + environment
  social      ~~ 1*social      + environment
  environment ~~ 1*environment

  # ── Residual covariance Q3~~Q4: freely estimated ──────────────────────────
  Q4 ~~ Q3

  # ── Residual variances: freely estimated ──────────────────────────────────
  Q5  ~~ Q5;  Q6  ~~ Q6;  Q7  ~~ Q7
  Q11 ~~ Q11; Q19 ~~ Q19; Q26 ~~ Q26
  Q3  ~~ Q3;  Q4  ~~ Q4;  Q10 ~~ Q10
  Q15 ~~ Q15; Q16 ~~ Q16; Q17 ~~ Q17; Q18 ~~ Q18
  Q20 ~~ Q20; Q21 ~~ Q21; Q22 ~~ Q22
  Q8  ~~ Q8;  Q9  ~~ Q9;  Q12 ~~ Q12; Q13 ~~ Q13
  Q14 ~~ Q14; Q23 ~~ Q23; Q24 ~~ Q24; Q25 ~~ Q25
'
