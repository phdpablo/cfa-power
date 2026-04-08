# =============================================================================
# models.R — Shared CFA Model Definitions
# =============================================================================

# --- Population model — Meta-analytic (Lin & Yao, 2022) -----------------------
popModel <- "
  # Factor loadings from Lin and Yao (2022) meta-analysis
  psycho =~ 0.92*Q5_P + 0.81*Q6_P + 0.94*Q7_P +
            0.73*Q11_P + 0.75*Q19_P + 0.63*Q26_P
  physical =~ 0.84*Q3_F + 0.83*Q4_F + 0.63*Q10_F +
              0.71*Q15_F + 0.68*Q16_F + 0.89*Q17_F + 0.61*Q18_F
  social =~ 0.94*Q20_S + 0.89*Q21_S + 0.78*Q22_S
  environment =~ 0.37*Q8_A + 0.49*Q9_A + 0.79*Q12_A + 0.81*Q13_A +
                 0.77*Q14_A + 0.75*Q23_A + 0.64*Q24_A + 0.73*Q25_A

  # Correlated residual between Q3 and Q4
  Q4_F ~~ 0.3*Q3_F

  # Factor variances fixed to 1; interfactor correlations = 0.3
  psycho ~~ 1*psycho + 0.3*physical + 0.3*social + 0.3*environment
  physical ~~ 1*physical + 0.3*social + 0.3*environment
  social ~~ 1*social + 0.3*environment
  environment ~~ 1*environment

  # Residual variances = 1 - lambda^2
  Q5_P ~~ 0.15*Q5_P
  Q6_P ~~ 0.34*Q6_P
  Q7_P ~~ 0.12*Q7_P
  Q11_P ~~ 0.47*Q11_P
  Q19_P ~~ 0.44*Q19_P
  Q26_P ~~ 0.60*Q26_P
  Q10_F ~~ 0.60*Q10_F
  Q15_F ~~ 0.50*Q15_F
  Q16_F ~~ 0.54*Q16_F
  Q17_F ~~ 0.21*Q17_F
  Q18_F ~~ 0.63*Q18_F
  Q20_S ~~ 0.12*Q20_S
  Q21_S ~~ 0.21*Q21_S
  Q22_S ~~ 0.39*Q22_S
  Q8_A ~~ 0.86*Q8_A
  Q9_A ~~ 0.76*Q9_A
  Q12_A ~~ 0.38*Q12_A
  Q13_A ~~ 0.34*Q13_A
  Q14_A ~~ 0.41*Q14_A
  Q23_A ~~ 0.44*Q23_A
  Q24_A ~~ 0.59*Q24_A
  Q25_A ~~ 0.47*Q25_A
"

# --- Naive model — Minimally acceptable scenario ------------------------------
naiveModel <- "
  # All loadings = 0.5
  psycho =~ 0.5*Q5_P + 0.5*Q6_P + 0.5*Q7_P +
            0.5*Q11_P + 0.5*Q19_P + 0.5*Q26_P
  physical =~ 0.5*Q3_F + 0.5*Q4_F + 0.5*Q10_F +
              0.5*Q15_F + 0.5*Q16_F + 0.5*Q17_F + 0.5*Q18_F
  social =~ 0.5*Q20_S + 0.5*Q21_S + 0.5*Q22_S
  environment =~ 0.5*Q8_A + 0.5*Q9_A + 0.5*Q12_A + 0.5*Q13_A +
                 0.5*Q14_A + 0.5*Q23_A + 0.5*Q24_A + 0.5*Q25_A

  # Correlated residual between Q3 and Q4
  Q4_F ~~ 0.3*Q3_F

  psycho ~~ 1*psycho + 0.3*physical + 0.3*social + 0.3*environment
  physical ~~ 1*physical + 0.3*social + 0.3*environment
  social ~~ 1*social + 0.3*environment
  environment ~~ 1*environment

  # Residual variances = 1 - 0.5^2 = 0.75
  Q5_P ~~ 0.75*Q5_P
  Q6_P ~~ 0.75*Q6_P
  Q7_P ~~ 0.75*Q7_P
  Q11_P ~~ 0.75*Q11_P
  Q19_P ~~ 0.75*Q19_P
  Q26_P ~~ 0.75*Q26_P
  Q3_F ~~ 0.75*Q3_F
  Q4_F ~~ 0.75*Q4_F
  Q10_F ~~ 0.75*Q10_F
  Q15_F ~~ 0.75*Q15_F
  Q16_F ~~ 0.75*Q16_F
  Q17_F ~~ 0.75*Q17_F
  Q18_F ~~ 0.75*Q18_F
  Q20_S ~~ 0.75*Q20_S
  Q21_S ~~ 0.75*Q21_S
  Q22_S ~~ 0.75*Q22_S
  Q8_A ~~ 0.75*Q8_A
  Q9_A ~~ 0.75*Q9_A
  Q12_A ~~ 0.75*Q12_A
  Q13_A ~~ 0.75*Q13_A
  Q14_A ~~ 0.75*Q14_A
  Q23_A ~~ 0.75*Q23_A
  Q24_A ~~ 0.75*Q24_A
  Q25_A ~~ 0.75*Q25_A
"

# --- Optimistic model — Best-case scenario ------------------------------------
optModel <- "
  # All loadings = 0.7
  psycho =~ 0.7*Q5_P + 0.7*Q6_P + 0.7*Q7_P +
            0.7*Q11_P + 0.7*Q19_P + 0.7*Q26_P
  physical =~ 0.7*Q3_F + 0.7*Q4_F + 0.7*Q10_F +
              0.7*Q15_F + 0.7*Q16_F + 0.7*Q17_F + 0.7*Q18_F
  social =~ 0.7*Q20_S + 0.7*Q21_S + 0.7*Q22_S
  environment =~ 0.7*Q8_A + 0.7*Q9_A + 0.7*Q12_A + 0.7*Q13_A +
                 0.7*Q14_A + 0.7*Q23_A + 0.7*Q24_A + 0.7*Q25_A

  # Correlated residual between Q3 and Q4
  Q4_F ~~ 0.5*Q3_F

  psycho ~~ 1*psycho + 0.5*physical + 0.5*social + 0.5*environment
  physical ~~ 1*physical + 0.5*social + 0.5*environment
  social ~~ 1*social + 0.5*environment
  environment ~~ 1*environment

  # Residual variances = 1 - 0.7^2 = 0.51
  Q5_P ~~ 0.51*Q5_P
  Q6_P ~~ 0.51*Q6_P
  Q7_P ~~ 0.51*Q7_P
  Q11_P ~~ 0.51*Q11_P
  Q19_P ~~ 0.51*Q19_P
  Q26_P ~~ 0.51*Q26_P
  Q3_F ~~ 0.51*Q3_F
  Q4_F ~~ 0.51*Q4_F
  Q10_F ~~ 0.51*Q10_F
  Q15_F ~~ 0.51*Q15_F
  Q16_F ~~ 0.51*Q16_F
  Q17_F ~~ 0.51*Q17_F
  Q18_F ~~ 0.51*Q18_F
  Q20_S ~~ 0.51*Q20_S
  Q21_S ~~ 0.51*Q21_S
  Q22_S ~~ 0.51*Q22_S
  Q8_A ~~ 0.51*Q8_A
  Q9_A ~~ 0.51*Q9_A
  Q12_A ~~ 0.51*Q12_A
  Q13_A ~~ 0.51*Q13_A
  Q14_A ~~ 0.51*Q14_A
  Q23_A ~~ 0.51*Q23_A
  Q24_A ~~ 0.51*Q24_A
  Q25_A ~~ 0.51*Q25_A
"

# --- Analysis model — Free parameters -----------------------------------------
analyzeModel <- "
  # Factor loadings estimated freely
  psycho =~ Q5_P + Q6_P + Q7_P + Q11_P + Q19_P + Q26_P
  physical =~ Q3_F + Q4_F + Q10_F + Q15_F + Q16_F + Q17_F + Q18_F
  social =~ Q20_S + Q21_S + Q22_S
  environment =~ Q8_A + Q9_A + Q12_A + Q13_A + Q14_A + Q23_A + Q24_A + Q25_A
  Q4_F ~~ Q3_F

# Factor variances fixed to 1 and free correlations between factors
  psycho ~~ 1*psycho + physical + social + environment
  physical ~~ 1*physical + social + environment
  social ~~ 1*social + environment
  environment ~~ 1*environment

  # Correlated residual between Q3 and Q4
  Q4_F ~~ Q3_F

  # Residual variances
  Q5_P ~~ Q5_P
  Q6_P ~~ Q6_P
  Q7_P ~~ Q7_P
  Q11_P ~~ Q11_P
  Q19_P ~~ Q19_P
  Q26_P ~~ Q26_P
  Q10_F ~~ Q10_F
  Q15_F ~~ Q15_F
  Q16_F ~~ Q16_F
  Q17_F ~~ Q17_F
  Q18_F ~~ Q18_F
  Q20_S ~~ Q20_S
  Q21_S ~~ Q21_S
  Q22_S ~~ Q22_S
  Q8_A ~~ Q8_A
  Q9_A ~~ Q9_A
  Q12_A ~~ Q12_A
  Q13_A ~~ Q13_A
  Q14_A ~~ Q14_A
  Q23_A ~~ Q23_A
  Q24_A ~~ Q24_A
  Q25_A ~~ Q25_A
"
