## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval = FALSE, file='examples/mnl-design.R'-------------------------------
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  #' Specifying a utility function with 3 attributes and a constant for the
#  #' SQ alternative. The design has 20 rows.
#  utility <- list(
#    alt1 = "b_x1[0.1]  * x1[1:5] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1       * x1      + b_x2      * x2          + b_x3       * x3",
#    alt3 = "b_sq[0.15] * sq[1]"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "rsc", draws = "scrambled-sobol",
#                            control = list(
#                              max_iter = 21000,
#                              max_no_improve = 5000
#                            ))
#  
#  # Add a blocking variable to the design with 4 blocks.
#  design <- block(design, 4)
#  
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-with-interactions.R'-------------
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  utility <- list(
#    alt1 = "b_x1[0.1] * x1[1:5] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)] + b_x1x2[-0.1] * I(x1 * x2)",
#    alt2 = "b_x1      * x1      + b_x2      * x2          + b_x3       * x3"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "federov", draws = "scrambled-sobol",
#                            dudx = "b_x3")
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-with-multiway-interactions.R'----
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  utility <- list(
#    alt1 = "b_x1[0.1] * x1[1:5] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)] + b_x1x2[-0.1] * I(x1 * x2)",
#    alt2 = "b_x1      * x1      + b_x2      * x2          + b_x3       * x3 + b_x1x2x3[0.1] * I(x1 * x2 * x3)"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "rsc", draws = "scrambled-sobol",
#                            dudx = "b_x3")
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-dummy-coding.R'------------------
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  #' A design where the first attribute is dummy-coded.
#  utility <- list(
#    alt1 = "b_x1_dummy[c(0.1, 0.2)] * x1[c(1, 2, 3)] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1_dummy              * x1             + b_x2      * x2          + b_x3       * x3"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "rsc", draws = "scrambled-sobol")
#  
#  # Add a blocking variable to the design with 2 blocks.
#  design <- block(design, 2)
#  
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-random-with-specified-level-occurrence.R'----
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  utility <- list(
#    alt1 = "b_x1_dummy[c(0.1, 0.2)] * x1[c(1, 2, 3)](4:14) + b_x2[0.4] * x2[c(0, 1)](9:11) + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1_dummy              * x1                   + b_x2      * x2                + b_x3       * x3"
#  )
#  
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "federov", draws = "scrambled-sobol")
#  
#  design <- block(design, 4)
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-with-alternative-specific-attributres.R'----
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  utility <- list(
#    car   = "                          b_travel_time[-0.1] * travel_time_car[c(10, 15, 20, 25)]   + b_travel_cost[-0.2] * travel_cost_car[c(25, 50, 75, 100)]  + b_comfort_dummy[c(0.1, 0.2)] * comfort[c(1, 2, 3)]",
#    bus   = "b_bus[-0.1]  * bus[1]   + b_travel_time       * travel_time_bus[c(20, 25, 30, 35)]   + b_travel_cost       * travel_cost_bus[c(10, 15, 20, 25)]   + b_comfort_dummy              * comfort",
#    train = "b_train[0.1] * train[1] + b_travel_time       * travel_time_train[c(15, 20, 25, 30)] + b_travel_cost       * travel_cost_train[c(20, 30, 40, 50)] + b_comfort_dummy              * comfort"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "rsc", draws = "scrambled-sobol",
#                            control = list(
#                              max_iter = 21000,
#                              efficiency_threshold = 0.01
#                            ))
#  
#  # Add a blocking variable to the design with 4 blocks.
#  design <- block(design, 4)
#  
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-bayesian-priors.R'---------------
#  #
#  # Example file for creating a simple MNL design with Bayesian priors
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  #' Generating a design with Bayesian priors.
#  utility <- list(
#    alt1 = "b_x1[0.1] * x1[2:5] + b_x2[uniform_p(-1, 1)] * x2[c(0, 1)] + b_x3[normal_p(0, 1)] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1      * x1      + b_x2                   * x2          + b_x3                 * x3"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "rsc", draws = "scrambled-sobol",
#                            control = list(
#                              max_iter = 10000
#                            ))
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-advanced.R'----------------------
#  #
#  # Example file for creating a simple MNL design with Bayesian priors
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  #' Generating a design with Bayesian priors using dummy coding and level occurrences
#  #' NOTE: This design may take a long time. It has to first find a candidate that
#  #' meets the restrictions and then evaluate whether it is better than the
#  #' current best. Little information is provided about the process along the way.
#  utility <- list(
#    alt1 = "b_x1_dummy[c(uniform_p(-1, 1), uniform_p(-1, 1))] * x1[c(1, 2, 3)](6:10, 4:14, 6:10) + b_x2[0.4] * x2[c(0, 1)](9:11) + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1_dummy                                        * x1                               + b_x2      * x2                + b_x3       * x3"
#  )
#  
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "random", draws = "scrambled-sobol",
#                            control = list(
#                              max_iter = 10000
#                            ))
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-with-supplied-candidate-set.R'----
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  utility <- list(
#    alt1 = "b_x1[0.1] * x1[2:5] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1      * x1      + b_x2      * x2          + b_x3       * x3",
#    alt3 = "b_sq[0]   * sq[1]"
#  )
#  
#  # Use the full factorial as the candidate set
#  candidate_set <- full_factorial(
#    list(
#      alt1_x1 = 2:5,
#      alt1_x2 = c(0, 1),
#      alt1_x3 = seq(0, 1, 0.25),
#      alt2_x1 = 2:5,
#      alt2_x2 = c(0, 1),
#      alt2_x3 = seq(0, 1, 0.25),
#      alt3_sq = 1
#    )
#  )
#  
#  candidate_set <- candidate_set[!(candidate_set$alt1_x1 == 2 & candidate_set$alt1_x2 == 0 & candidate_set$alt1_x3 == 0), ]
#  candidate_set <- candidate_set[!(candidate_set$alt2_x2 == 1 & candidate_set$alt2_x3 == 1), ]
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "federov", draws = "scrambled-sobol",
#                            candidate_set = candidate_set)
#  
#  
#  summary(design)

## ----eval = FALSE, file='examples/mnl-design-with-exclusions.R'---------------
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  utility <- list(
#    alt1 = "b_x1[0.1] * x1[2:5] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1      * x1      + b_x2      * x2          + b_x3       * x3"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            model = "mnl", efficiency_criteria = "d-error",
#                            algorithm = "federov", draws = "scrambled-sobol",
#                            exclusions = list(
#                              "alt1_x1 == 2 & alt1_x2 == 0 & alt1_x3 == 0",
#                              "alt2_x2 == 1 & alt2_x3 == 1"
#                            ))

## ----eval = FALSE, file='examples/mnl-c-efficiency.R'-------------------------
#  #
#  # Example file for creating a simple MNL design
#  #
#  rm(list = ls(all = TRUE))
#  # library(spdesign)
#  
#  # Define the list of utility functions ----
#  #' Specifying a utility function with 3 attributes and a constant for the
#  #' SQ alternative. The design has 20 rows.
#  utility <- list(
#    alt1 = "b_x1[0.1]  * x1[1:5] + b_x2[0.4] * x2[c(0, 1)] + b_x3[-0.2] * x3[seq(0, 1, 0.25)]",
#    alt2 = "b_x1       * x1      + b_x2      * x2          + b_x3       * x3",
#    alt3 = "b_sq[0.15] * sq[1]"
#  )
#  
#  # Generate designs ----
#  design <- generate_design(utility, rows = 20,
#                            dudx = "b_x3",
#                            model = "mnl",
#                            efficiency_criteria = "c-error",
#                            algorithm = "rsc",
#                            draws = "scrambled-sobol",
#                            control = list(
#                              max_iter = 21000,
#                              max_no_improve = 5000
#                            ))
#  
#  # Add a blocking variable to the design with 4 blocks.
#  design <- block(design, 4)
#  
#  
#  summary(design)

