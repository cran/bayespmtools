## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(bayespmtools)
set.seed(123) # Set seed for reproducibility

## -----------------------------------------------------------------------------
evidence <- list(
  prev ~ beta(116, 155),           # Outcome prevalence
  cstat ~ beta(3628, 1139),        # C-statistic
  cal_mean ~ norm(-0.009, 0.125),  # Mean calibration error
  cal_slp ~ norm(0.995, 0.024)     # Calibration slope
)

## -----------------------------------------------------------------------------
targets <- list(
  eciw.cstat = 0.1,             # Expected CI width for c-statistic
  eciw.cal_oe = 0.22,           # Expected CI width for O/E ratio
  eciw.cal_slp = 0.30,          # Expected CI width for calibration slope
  qciw.cal_slp = c(0.9, 0.35),  # 90% assurance that CI width ≤ 0.35
  voi.nb = 0.90
)

## ----eval=FALSE---------------------------------------------------------------
# results <- bpm_valsamp(
#   evidence = evidence,
#   targets = targets,
#   n_sim = 1000,           # Number of Monte Carlo simulations
#   threshold = 0.2         # Risk threshold for net benefit calculations
# )

## ----include=FALSE------------------------------------------------------------
# For vignette building speed, we'll use pre-computed results
# In practice, run the code above
results <- list(results = c(
  eciw.cstat = 347,
  eciw.cal_oe = 430,
  eciw.cal_slp = 1037,
  qciw.cal_slp = 896,
  voi.nb = 717
))

## -----------------------------------------------------------------------------
print(results$results)

## ----eval=FALSE---------------------------------------------------------------
# vignette("bayespmtools_tutorial")

## ----eval=FALSE---------------------------------------------------------------
# ?bpm_valsamp
# ?bpm_valprec

