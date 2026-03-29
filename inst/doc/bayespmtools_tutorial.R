## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(bayespmtools)

## ----set-seed-----------------------------------------------------------------
# Setting the random number seed for reproducibility
set.seed(123)

## ----load-evidence------------------------------------------------------------
evidence <- list(
    prev~beta(mean=0.428, sd=0.030), 
    cstat~beta(mean=0.761, cih=0.773), 
    cal_mean~norm(-0.009, 0.125),  #mean and SD
    cal_slp~norm(0.995, 0.024)     #mean and SD
  )

## ----targets-samp-------------------------------------------------------------
targets_samp <- list(eciw.cstat=0.1,
                eciw.cal_oe=0.22,
                eciw.cal_slp=0.30,
                qciw.cstat=c(0.9, 0.1),
                qciw.cal_oe=c(0.9, 0.22),
                qciw.cal_slp=c(0.9, 0.30),
                oa.nb=0.90)

## ----eval=FALSE---------------------------------------------------------------
# samp <- bpm_valsamp(evidence=evidence, #Evidence as a list
#                    targets=targets_samp, #Targets (as specified above)
#                    n_sim=10000, #Number of Monte Carlo simulations
#                    threshold=0.2) #Risk threshold for NB calculations
# 

## ----include=FALSE------------------------------------------------------------
samp <- readRDS("precomputed/samp_result.rds")

## ----print-samp-results-------------------------------------------------------
#Print results
print(samp$results)

## -----------------------------------------------------------------------------
N_prec <- samp$results  #Sample size components from the main function call.

targets_prec = list(eciw.cstat = T, eciw.cal_oe = T, eciw.cal_slp = T, qciw.cstat = 0.9, qciw.cal_oe = 0.9, qciw.cal_slp = 0.9, oa.nb=T)

## ----eval=FALSE---------------------------------------------------------------
# prec <- bpm_valprec(
#   N = N_prec, #Sample sizes
#   evidence = evidence, #Evidence as a list
#   dist_type="logitnorm", #Distribution type for calibrated risks
#   method="sample", #Sample based or two-level ("2s") method
#   targets = targets_prec, #Targets specified above
#   n_sim = 10000, #Number of Monte Carlo simulations
#   threshold=0.2) #Risk threshold for NB VoI calculations

## ----include=FALSE------------------------------------------------------------
prec <- readRDS("precomputed/prec_result.rds")

## ----compare_results----------------------------------------------------------

res <- prec$results[cbind(samp$results, names(samp$results))]
names(res) <- names(samp$results)

print(res)

## ----eval=FALSE---------------------------------------------------------------
# voi <- bpm_valprec(
#   N = N_prec, #Sample sizes at each calculations are to be conducted.
#   evidence = samp$sample, #Evidence as a list
#   targets = list(voi.nb=T), #Only requesting EVSI and EVPI
#   threshold=0.2) #Risk threshold for NB VoI calculations

## ----include=FALSE------------------------------------------------------------
voi <- readRDS("precomputed/voi_result.rds")

## ----fig.fullwidth, fig.width = 8, fig.height = 5, out.width = "100%"---------
library(ggplot2)

graph_shapes <- c("oa.nb"=18,
                  "eciw.cstat"=15,
                  "qciw.cstat"=15,
                  "eciw.cal_oe"=16,
                  "qciw.cal_oe"=16,
                  "eciw.cal_slp"=17,
                  "qciw.cal_slp"=17)

graph_names <- c("oa.nb"="Optimality assurance",
                  "eciw.cstat"="c-statistic (expected value)",
                  "qciw.cstat"="c-statistic (assurance)",
                  "eciw.cal_oe"="O/E ratio (expected value)",
                  "qciw.cal_oe"="O/E ratio (assurance)",
                  "eciw.cal_slp"="Calibration slope (expected value)",
                  "qciw.cal_slp"="Calibration slope (assurance)")

graph_colors <- c("oa.nb"="black",
                  "eciw.cstat"="#1f77b4", 
                  "qciw.cstat"="orange",
                  "eciw.cal_oe"="#1f77b4",
                  "qciw.cal_oe"="orange",
                  "eciw.cal_slp"="#1f77b4",
                  "qciw.cal_slp"="orange")

df <- data.frame(N=voi$N, EVPI=voi$results[,'voi.evpi'], EVSI=voi$results[,'voi.evsi'])
o <- order(df$N)
df <- df[o, ]

df$shapes <- graph_shapes[rownames(df)]
df$graph_names <- graph_names[rownames(df)]
df$colors <- graph_colors[rownames(df)]
df$names <- rownames(df)

df$names <- factor(df$names, levels = unique(df$names))


df$EVSI_EVPI_ratio <- df$EVSI / df$EVPI
scale_factor <- max(df$EVSI) / max(df$EVSI_EVPI_ratio)
df$EVSI_EVPI_ratio_scaled <- df$EVSI_EVPI_ratio * scale_factor


# EVSI plot
plt <- ggplot(df, aes(x=N)) +
  geom_line(aes(y=EVSI), color="black") +  # Add the EVSI/EVPI ratio line
  geom_point(aes(y=EVSI, shape=names, color=names), size=2) +  
  labs(x = "Sample size (N)", y = "Expected gain in NB (EVSI)", title = "") +
  scale_shape_manual(
    name = "Sample size targets and rules",  
    values = df$shapes,  # Unique shapes
    labels = df$graph_names  # Use levels of N for labels
  ) +
  scale_color_manual(
    name = "Sample size targets and rules",  
    values = df$colors,  # Unique shapes
    labels = df$graph_names  # Use levels of N for labels
  ) +
  # Primary Y-axis limits
  scale_y_continuous(
    limits = c(0, max(df$EVSI, df$EVPI)),
    sec.axis = sec_axis(~ . / scale_factor, name = "EVSI/EVPI Ratio")  # Secondary Y-axis
  ) +
  # Horizontal lines
  geom_hline(yintercept = df$EVPI, color = "gray") +
  theme_minimal()
print(plt)


