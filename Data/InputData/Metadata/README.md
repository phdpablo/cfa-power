# Metadata Folder

## Overview

This folder documents the data sources, indicator codebooks, and mathematical derivations used to parameterize the population models for this study.

## 1. Data Sources Guide

1. **Meta-Analytic Pooled Parameters**:
   - **Citation**: Lin, C.-Y., & Yao, G. (2022). A meta-analysis of the factor structure of the World Health Organization Quality of Life-BREF. *Evaluation & the Health Professions*, 45(4), 384–398.
   - **Contribution**: Provided pooled exploratory factor analysis (EFA) factor loadings across 16 international studies, interfactor correlation ranges ($\phi \in [0.08, 0.31]$), and evidence for the $Q3 \sim\sim Q4$ residual covariance and candidate cross-loadings.
2. **Reliability Range Benchmarks**:
   - **Citation**: Mosqueira-Taipe, C., et al. (2026). Measurement invariance and psychometric properties of the WHOQOL-BREF: A systematic review.
   - **Contribution**: Provided the empirical minimum and maximum Cronbach's $\alpha$ bounds across the four domains used to specify the naive (pessimistic) and optimistic models.
3. **Empirical Benchmark Dataset**:
   - **Citation**: Rogers, P. (2022). WHOQOL-BREF Data (V2). *Mendeley Data*. DOI: 10.17632/rdky78bk8r.2.
   - **Contribution**: Empirical dataset of $N = 1,047$ observations used for the post hoc power demonstration in notebook `06_posthoc.qmd`.

## 2. WHOQOL-BREF Indicator Codebook

The model comprises 24 items measuring four domains of quality of life:

| Domain | Items | Description of Indicators |
| :--- | :--- | :--- |
| **Physical Health** | Q3, Q4, Q10, Q15, Q16, Q17, Q18 | Pain, energy, sleep, mobility, daily activities, medication, work capacity. |
| **Psychological** | Q5, Q6, Q7, Q11, Q19, Q26 | Positive feelings, spirituality, concentration, bodily appearance, self-esteem, negative feelings. |
| **Social Relationships** | Q20, Q21, Q22 | Personal relationships, sex life, social support. |
| **Environment** | Q8, Q9, Q12, Q13, Q14, Q23, Q24, Q25 | Safety, home environment, finances, information, leisure, physical environment, transport. |

*Note: General health items Q1 and Q2 are excluded from the four-factor CFA structure, in line with standard WHOQOL scoring guidelines.*

## 3. Parameter Derivations

- **Spearman-Brown Derivation (Naive and Optimistic Models)**:
  For domain with $k$ items and reliability $\alpha$, assuming equal loadings:
  $$\lambda = \sqrt{\frac{\alpha}{k - \alpha(k - 1)}}, \quad \theta = 1 - \lambda^2$$
- **Residual Variances for Cross-Loaded Items ($H_1$ Model)**:
  To maintain standard total item variances ($\text{Var}(y_i) = 1$):
  $$\theta_i = 1 - \lambda_{\text{primary}}^2 - \lambda_{\text{secondary}}^2 - 2\,\lambda_{\text{primary}}\,\lambda_{\text{secondary}}\,\phi$$
  where $\phi = 0.20$ is the latent factor correlation.
