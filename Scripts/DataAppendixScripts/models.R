# =============================================================================
# WHOQOL-BREF Power Analysis
# Two paradigms:
#   Paradigma A: Recovery power — popModel / naiveModel / optModel → analyzeModel
#   Paradigma B: Misspecification detection power — model_P2 → analyzeModel
#
# Sources:
#   Lin & Yao (2022) — meta-EFA + SNA, 16 studies, Psy Assessment
#   Mosqueira-Taipe et al. (2026) — systematic review COSMIN, 350 studies
# =============================================================================

# ── ITEM NOTATION ─────────────────────────────────────────────────────────────
#  Psychological  : Q5_P  Q6_P  Q7_P  Q11_P Q19_P Q26_P
#  Physical       : Q3_F  Q4_F  Q10_F Q15_F Q16_F Q17_F Q18_F
#  Social         : Q20_S Q21_S Q22_S
#  Environmental  : Q8_A  Q9_A  Q12_A Q13_A Q14_A Q23_A Q24_A Q25_A

# =============================================================================
# SECTION 1 — POPULATION MODELS (fixed parameters; data-generating)
# =============================================================================

# -----------------------------------------------------------------------------
# 1a. popModel — Meta-analytic scenario (Lin & Yao, 2022)
#     Loadings = pooled EFA estimates across 16 international studies
#     Interfactor correlations = 0.20 (midpoint of reported range 0.08–0.31)
#     Q3~~Q4 retained: subfactor signal in EFA 5-factor solution (Lin & Yao)
#     NOTE: Q8_A maintained in environment despite λ_psy > λ_env in meta-EFA;
#           this is the H0 version of the population — no cross-loadings.
# -----------------------------------------------------------------------------
popModel <- "
  # ── Factor loadings: empirical estimates from Lin & Yao (2022) ────────────
  psycho      =~ 0.92*Q5_P  + 0.81*Q6_P  + 0.94*Q7_P  +
                 0.73*Q11_P + 0.75*Q19_P + 0.63*Q26_P

  physical    =~ 0.84*Q3_F  + 0.83*Q4_F  + 0.63*Q10_F +
                 0.71*Q15_F + 0.68*Q16_F + 0.89*Q17_F  + 0.61*Q18_F

  social      =~ 0.94*Q20_S + 0.89*Q21_S + 0.78*Q22_S

  environment =~ 0.37*Q8_A  + 0.49*Q9_A  + 0.79*Q12_A + 0.81*Q13_A +
                 0.77*Q14_A + 0.75*Q23_A  + 0.64*Q24_A + 0.73*Q25_A

  # ── Residual covariance Q3~~Q4 ────────────────────────────────────────────
  # r(Q3,Q4|physical) = 0.30 (method bias / conceptual proximity)
  # cov = 0.30 × sqrt(1-0.84²) × sqrt(1-0.83²) = 0.0908
  Q4_F ~~ 0.0908*Q3_F

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  # Range reported in Lin & Yao (2022): 0.08 to 0.31
  # Conservative midpoint = 0.20 for all pairs
  psycho      ~~ 1*psycho      + 0.2*physical + 0.2*social + 0.2*environment
  physical    ~~ 1*physical    + 0.2*social   + 0.2*environment
  social      ~~ 1*social      + 0.2*environment
  environment ~~ 1*environment

  # ── Residual variances: θ = 1 − λ² (standardised indicators) ─────────────
  Q5_P  ~~ 0.1536*Q5_P    # 1 − 0.92²
  Q6_P  ~~ 0.3439*Q6_P    # 1 − 0.81²
  Q7_P  ~~ 0.1164*Q7_P    # 1 − 0.94²
  Q11_P ~~ 0.4671*Q11_P   # 1 − 0.73²
  Q19_P ~~ 0.4375*Q19_P   # 1 − 0.75²
  Q26_P ~~ 0.6031*Q26_P   # 1 − 0.63²
  Q3_F  ~~ 0.2944*Q3_F    # 1 − 0.84²
  Q4_F  ~~ 0.3111*Q4_F    # 1 − 0.83²
  Q10_F ~~ 0.6031*Q10_F   # 1 − 0.63²
  Q15_F ~~ 0.4959*Q15_F   # 1 − 0.71²
  Q16_F ~~ 0.5376*Q16_F   # 1 − 0.68²
  Q17_F ~~ 0.2079*Q17_F   # 1 − 0.89²
  Q18_F ~~ 0.6279*Q18_F   # 1 − 0.61²
  Q20_S ~~ 0.1164*Q20_S   # 1 − 0.94²
  Q21_S ~~ 0.2079*Q21_S   # 1 − 0.89²
  Q22_S ~~ 0.3916*Q22_S   # 1 − 0.78²
  Q8_A  ~~ 0.8631*Q8_A    # 1 − 0.37² — lowest loading; bridge item (betweenness=40.5)
  Q9_A  ~~ 0.7599*Q9_A    # 1 − 0.49²
  Q12_A ~~ 0.3759*Q12_A   # 1 − 0.79²
  Q13_A ~~ 0.3439*Q13_A   # 1 − 0.81²
  Q14_A ~~ 0.4071*Q14_A   # 1 − 0.77²
  Q23_A ~~ 0.4375*Q23_A   # 1 − 0.75²
  Q24_A ~~ 0.5904*Q24_A   # 1 − 0.64²
  Q25_A ~~ 0.4671*Q25_A   # 1 − 0.73²
"

# -----------------------------------------------------------------------------
# 1b. naiveModel — Pessimistic scenario (empirically grounded)
#
#     APPROACH: Cronbach's alpha → Spearman-Brown → uniform λ per domain
#     Formula: λ = sqrt(α / (k − α(k−1)))    θ = 1 − λ²
#     Assumption: tau-equivalence within each domain (equal loadings),
#       which is the standard requirement for the Spearman-Brown formula.
#       Items within a domain therefore share the same λ and θ.
#
#     ALPHA SOURCES (original 4-factor structure, both articles):
#       Physical (k=7):      α = 0.672 → Morales-Valiente et al. (2023)
#       Psychological (k=6): α = 0.704 → Morales-Valiente et al. (2023)
#       Social (k=3):        α = 0.630 → Morales-Valiente et al. (2023)
#       Environmental (k=8): α = 0.709 → Morales-Valiente et al. (2023)
#     All values confirmed within M−1SD range reported in Lin & Yao (2022)
#       (Physical M=0.78/SD=0.06; Psy M=0.78/SD=0.05;
#        Social M=0.68/SD=0.08; Environmental M=0.78/SD=0.04).
#     Morales-Valiente (2023) is the unique study in Mosqueira-Taipe et al. (2026)
#       to report the lowest alpha for ALL four domains simultaneously
#       in the original unmodified structure.
#
#     INTERFACTOR CORRELATIONS: φ = 0.30 (upper bound, Lin & Yao 2022)
#       Higher φ → factors harder to distinguish → conservative power estimate.
#
#     DERIVED PARAMETERS:
#       Physical:      λ = 0.4758, ρ̄ = 0.2264, θ = 0.7736
#       Psychological: λ = 0.5328, ρ̄ = 0.2839, θ = 0.7161
#       Social:        λ = 0.6017, ρ̄ = 0.3621, θ = 0.6379
#       Environmental: λ = 0.4832, ρ̄ = 0.2335, θ = 0.7665
#       Q3~~Q4 cov = 0.30 × (1 − 0.4758²) = 0.2321
# -----------------------------------------------------------------------------
naiveModel <- "
  # ── Factor loadings: tau-equivalent (uniform λ per domain) ───────────────
  psycho      =~ 0.5328*Q5_P  + 0.5328*Q6_P  + 0.5328*Q7_P  +
                 0.5328*Q11_P + 0.5328*Q19_P + 0.5328*Q26_P

  physical    =~ 0.4758*Q3_F  + 0.4758*Q4_F  + 0.4758*Q10_F +
                 0.4758*Q15_F + 0.4758*Q16_F + 0.4758*Q17_F  + 0.4758*Q18_F

  social      =~ 0.6017*Q20_S + 0.6017*Q21_S + 0.6017*Q22_S

  environment =~ 0.4832*Q8_A  + 0.4832*Q9_A  + 0.4832*Q12_A + 0.4832*Q13_A +
                 0.4832*Q14_A + 0.4832*Q23_A  + 0.4832*Q24_A + 0.4832*Q25_A

  # ── Residual covariance Q3~~Q4 ────────────────────────────────────────────
  # r(Q3,Q4|physical) = 0.30; cov = 0.30 × (1 − 0.4758²) = 0.2321
  Q4_F ~~ 0.2321*Q3_F

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  # φ = 0.30: upper bound of Lin & Yao (2022) range — pessimistic scenario
  psycho      ~~ 1*psycho      + 0.3*physical + 0.3*social + 0.3*environment
  physical    ~~ 1*physical    + 0.3*social   + 0.3*environment
  social      ~~ 1*social      + 0.3*environment
  environment ~~ 1*environment

  # ── Residual variances: θ = 1 − λ² per domain ────────────────────────────
  Q5_P  ~~ 0.7161*Q5_P    # Psychological: θ = 1 − 0.5328² = 0.7161
  Q6_P  ~~ 0.7161*Q6_P
  Q7_P  ~~ 0.7161*Q7_P
  Q11_P ~~ 0.7161*Q11_P
  Q19_P ~~ 0.7161*Q19_P
  Q26_P ~~ 0.7161*Q26_P
  Q3_F  ~~ 0.7736*Q3_F    # Physical: θ = 1 − 0.4758² = 0.7736
  Q4_F  ~~ 0.7736*Q4_F
  Q10_F ~~ 0.7736*Q10_F
  Q15_F ~~ 0.7736*Q15_F
  Q16_F ~~ 0.7736*Q16_F
  Q17_F ~~ 0.7736*Q17_F
  Q18_F ~~ 0.7736*Q18_F
  Q20_S ~~ 0.6379*Q20_S   # Social: θ = 1 − 0.6017² = 0.6379
  Q21_S ~~ 0.6379*Q21_S
  Q22_S ~~ 0.6379*Q22_S
  Q8_A  ~~ 0.7665*Q8_A    # Environmental: θ = 1 − 0.4832² = 0.7665
  Q9_A  ~~ 0.7665*Q9_A
  Q12_A ~~ 0.7665*Q12_A
  Q13_A ~~ 0.7665*Q13_A
  Q14_A ~~ 0.7665*Q14_A
  Q23_A ~~ 0.7665*Q23_A
  Q24_A ~~ 0.7665*Q24_A
  Q25_A ~~ 0.7665*Q25_A
"

# -----------------------------------------------------------------------------
# 1c. optModel — Optimistic scenario (empirically grounded)
#
#     APPROACH: same Spearman-Brown derivation as naiveModel,
#       now using the highest observed alpha per domain.
#
#     ALPHA SOURCES (original 4-factor structure, both articles):
#       Physical (k=7):      α = 0.860 → Abbasi-Ghahramanloo et al. (2020)
#       Psychological (k=6): α = 0.860 → Kruithof et al. (2018)
#       Social (k=3):        α = 0.810 → Suárez et al. (2018)
#       Environmental (k=8): α = 0.849 → Kruithof et al. (2018)
#     All values confirmed within M+1SD range in Lin & Yao (2022).
#
#     INTERFACTOR CORRELATIONS: φ = 0.08 (lower bound, Lin & Yao 2022)
#       Lower φ → factors well distinguished → optimistic power estimate.
#
#     DERIVED PARAMETERS:
#       Physical:      λ = 0.6837, ρ̄ = 0.4674, θ = 0.5326
#       Psychological: λ = 0.7113, ρ̄ = 0.5059, θ = 0.4941
#       Social:        λ = 0.7661, ρ̄ = 0.5870, θ = 0.4130
#       Environmental: λ = 0.6424, ρ̄ = 0.4127, θ = 0.5873
#       Q3~~Q4 cov = 0.30 × (1 − 0.6837²) = 0.1598
# -----------------------------------------------------------------------------
optModel <- "
  # ── Factor loadings: tau-equivalent (uniform λ per domain) ───────────────
  psycho      =~ 0.7113*Q5_P  + 0.7113*Q6_P  + 0.7113*Q7_P  +
                 0.7113*Q11_P + 0.7113*Q19_P + 0.7113*Q26_P

  physical    =~ 0.6837*Q3_F  + 0.6837*Q4_F  + 0.6837*Q10_F +
                 0.6837*Q15_F + 0.6837*Q16_F + 0.6837*Q17_F  + 0.6837*Q18_F

  social      =~ 0.7661*Q20_S + 0.7661*Q21_S + 0.7661*Q22_S

  environment =~ 0.6424*Q8_A  + 0.6424*Q9_A  + 0.6424*Q12_A + 0.6424*Q13_A +
                 0.6424*Q14_A + 0.6424*Q23_A  + 0.6424*Q24_A + 0.6424*Q25_A

  # ── Residual covariance Q3~~Q4 ────────────────────────────────────────────
  # r(Q3,Q4|physical) = 0.30; cov = 0.30 × (1 − 0.6837²) = 0.1598
  Q4_F ~~ 0.1598*Q3_F

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  # φ = 0.08: lower bound of Lin & Yao (2022) range — optimistic scenario
  psycho      ~~ 1*psycho      + 0.08*physical + 0.08*social + 0.08*environment
  physical    ~~ 1*physical    + 0.08*social   + 0.08*environment
  social      ~~ 1*social      + 0.08*environment
  environment ~~ 1*environment

  # ── Residual variances: θ = 1 − λ² per domain ────────────────────────────
  Q5_P  ~~ 0.4941*Q5_P    # Psychological: θ = 1 − 0.7113² = 0.4941
  Q6_P  ~~ 0.4941*Q6_P
  Q7_P  ~~ 0.4941*Q7_P
  Q11_P ~~ 0.4941*Q11_P
  Q19_P ~~ 0.4941*Q19_P
  Q26_P ~~ 0.4941*Q26_P
  Q3_F  ~~ 0.5326*Q3_F    # Physical: θ = 1 − 0.6837² = 0.5326
  Q4_F  ~~ 0.5326*Q4_F
  Q10_F ~~ 0.5326*Q10_F
  Q15_F ~~ 0.5326*Q15_F
  Q16_F ~~ 0.5326*Q16_F
  Q17_F ~~ 0.5326*Q17_F
  Q18_F ~~ 0.5326*Q18_F
  Q20_S ~~ 0.4130*Q20_S   # Social: θ = 1 − 0.7661² = 0.4130
  Q21_S ~~ 0.4130*Q21_S
  Q22_S ~~ 0.4130*Q22_S
  Q8_A  ~~ 0.5873*Q8_A    # Environmental: θ = 1 − 0.6424² = 0.5873
  Q9_A  ~~ 0.5873*Q9_A
  Q12_A ~~ 0.5873*Q12_A
  Q13_A ~~ 0.5873*Q13_A
  Q14_A ~~ 0.5873*Q14_A
  Q23_A ~~ 0.5873*Q23_A
  Q24_A ~~ 0.5873*Q24_A
  Q25_A ~~ 0.5873*Q25_A
"

# -----------------------------------------------------------------------------
# 1d. model_H1 — Cross-loading population model (Paradigma B)
#     Three cross-loadings added over the 4-factor WHO baseline + Q3~~Q4:
#       (1) Q8_A → psycho (λ=0.55):  Lin & Yao (2022) Table 3;
#           Q8 in psy factor in 9/16 studies; betweenness = 40.50 (highest);
#           confirmed CFA: Morales-Valiente (2023), Rondung (2023).
#       (2) Q9_A → psycho (λ=0.21):  Lin & Yao (2022) Table 3;
#           betweenness = 0; secondary load in psy in 5-factor solution;
#           Rondung (2023) fully relocated Q9 to psy domain.
#       (3) Q15_F → environment (λ=0.24): Lin & Yao (2022) Table 3;
#           betweenness = 36.50 (2nd highest); 'mobility' bridges physical
#           and environmental access.
#
#     Residuals for cross-loaded items recalculated as:
#       θ = 1 − λ_primary² − λ_secondary² − 2·λ_p·λ_s·φ  (φ = 0.20)
#       Q8_A : 1 − 0.37² − 0.55² − 2(0.37)(0.55)(0.20) = 0.4792
#       Q9_A : 1 − 0.49² − 0.21² − 2(0.49)(0.21)(0.20) = 0.6746
#       Q15_F: 1 − 0.71² − 0.24² − 2(0.71)(0.24)(0.20) = 0.3701
# -----------------------------------------------------------------------------
model_H1 <- "
  # ── Factor loadings (with three cross-loadings) ───────────────────────────
  psycho      =~ 0.92*Q5_P  + 0.81*Q6_P  + 0.94*Q7_P  +
                 0.73*Q11_P + 0.75*Q19_P + 0.63*Q26_P  +
                 0.55*Q8_A  +                             # cross-load (1)
                 0.21*Q9_A                                # cross-load (2)

  physical    =~ 0.84*Q3_F  + 0.83*Q4_F  + 0.63*Q10_F +
                 0.71*Q15_F + 0.68*Q16_F + 0.89*Q17_F  + 0.61*Q18_F

  social      =~ 0.94*Q20_S + 0.89*Q21_S + 0.78*Q22_S

  environment =~ 0.37*Q8_A  + 0.49*Q9_A  + 0.79*Q12_A + 0.81*Q13_A +
                 0.77*Q14_A + 0.75*Q23_A  + 0.64*Q24_A + 0.73*Q25_A +
                 0.24*Q15_F                               # cross-load (3)

  # ── Residual covariance Q3~~Q4 (fixed in both P2 and analyzeModel) ────────
  Q4_F ~~ 0.0908*Q3_F

  # ── Factor variances (=1) and interfactor correlations ────────────────────
  psycho      ~~ 1*psycho      + 0.2*physical + 0.2*social + 0.2*environment
  physical    ~~ 1*physical    + 0.2*social   + 0.2*environment
  social      ~~ 1*social      + 0.2*environment
  environment ~~ 1*environment

  # ── Residual variances ────────────────────────────────────────────────────
  Q5_P  ~~ 0.1536*Q5_P
  Q6_P  ~~ 0.3439*Q6_P
  Q7_P  ~~ 0.1164*Q7_P
  Q11_P ~~ 0.4671*Q11_P
  Q19_P ~~ 0.4375*Q19_P
  Q26_P ~~ 0.6031*Q26_P
  Q3_F  ~~ 0.2944*Q3_F
  Q4_F  ~~ 0.3111*Q4_F
  Q10_F ~~ 0.6031*Q10_F
  Q15_F ~~ 0.3701*Q15_F   # UPDATED: was 0.4959 — cross-load on environment
  Q16_F ~~ 0.5376*Q16_F
  Q17_F ~~ 0.2079*Q17_F
  Q18_F ~~ 0.6279*Q18_F
  Q20_S ~~ 0.1164*Q20_S
  Q21_S ~~ 0.2079*Q21_S
  Q22_S ~~ 0.3916*Q22_S
  Q8_A  ~~ 0.4792*Q8_A    # UPDATED: was 0.8631 — cross-load on psycho
  Q9_A  ~~ 0.6746*Q9_A    # UPDATED: was 0.7599 — cross-load on psycho
  Q12_A ~~ 0.3759*Q12_A
  Q13_A ~~ 0.3439*Q13_A
  Q14_A ~~ 0.4071*Q14_A
  Q23_A ~~ 0.4375*Q23_A
  Q24_A ~~ 0.5904*Q24_A
  Q25_A ~~ 0.4671*Q25_A
"

# =============================================================================
# SECTION 2 — ANALYSIS MODEL (free parameters; used in BOTH paradigmas)
# =============================================================================
# analyzeModel serves dual purpose:
#   Paradigma A: estimates 4F + Q3~~Q4 given data from popModel/naiveModel/optModel
#   Paradigma B: acts as H0 (no cross-loadings) given data from model_H1
#     → power = P(reject model | cross-loadings exist in population)
#
# Identification: factor variances fixed to 1 (marker-free scaling);
#   first indicator freely estimated (not fixed to 1).
# Q3~~Q4 included: supported in both Lin & Yao (2022) and Mosqueira-Taipe et al. (2026);
#   treated as a known, theoretically justified feature of the instrument.
# Cross-loadings of Q8, Q9, Q15 deliberately EXCLUDED from analyzeModel:
#   their omission defines the misspecification tested in Paradigma B.
# =============================================================================
analyzeModel <- "
  # ── Factor loadings: freely estimated ─────────────────────────────────────
  psycho      =~ Q5_P  + Q6_P  + Q7_P  + Q11_P + Q19_P + Q26_P
  physical    =~ Q3_F  + Q4_F  + Q10_F + Q15_F + Q16_F + Q17_F + Q18_F
  social      =~ Q20_S + Q21_S + Q22_S
  environment =~ Q8_A  + Q9_A  + Q12_A + Q13_A + Q14_A + Q23_A + Q24_A + Q25_A

  # ── Factor variances (=1) and free interfactor correlations ───────────────
  psycho      ~~ 1*psycho      + physical + social + environment
  physical    ~~ 1*physical    + social   + environment
  social      ~~ 1*social      + environment
  environment ~~ 1*environment

  # ── Residual covariance Q3~~Q4: freely estimated ──────────────────────────
  Q4_F ~~ Q3_F

  # ── Residual variances: freely estimated ──────────────────────────────────
  Q5_P  ~~ Q5_P;  Q6_P  ~~ Q6_P;  Q7_P  ~~ Q7_P
  Q11_P ~~ Q11_P; Q19_P ~~ Q19_P; Q26_P ~~ Q26_P
  Q3_F  ~~ Q3_F;  Q4_F  ~~ Q4_F;  Q10_F ~~ Q10_F
  Q15_F ~~ Q15_F; Q16_F ~~ Q16_F; Q17_F ~~ Q17_F; Q18_F ~~ Q18_F
  Q20_S ~~ Q20_S; Q21_S ~~ Q21_S; Q22_S ~~ Q22_S
  Q8_A  ~~ Q8_A;  Q9_A  ~~ Q9_A;  Q12_A ~~ Q12_A; Q13_A ~~ Q13_A
  Q14_A ~~ Q14_A; Q23_A ~~ Q23_A; Q24_A ~~ Q24_A; Q25_A ~~ Q25_A
"
