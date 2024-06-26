#' Generate an efficient experimental design
#'
#' The function generates efficient experimental designs. The function takes
#' a set of indirect utility functions and generates efficient experimental
#' designs assuming that people are maximizing utility.
#'
#' No assumptions are made with respect to default values and it is up to the
#' user to specify optimization criteria, optmization routines, draws to use for
#' Bayesian priors and more.
#'
#' @param utility A named list of utility functions. See the examples and the
#' vignette for examples of how to define these correctly for different types
#' of experimental designs.
#' @param rows An integer giving the number of rows in the final design
#' @param model A character string indicating the model to optimize the design
#' for. Currently the only model programmed is the 'mnl' model and this is also
#' set as the default.
#' @param efficiency_criteria A character string giving the efficiency criteria
#' to optimize for. One of 'a-error', 'c-error', 'd-error' or 's-error'. No
#' default is set and argument must be specified. Optimizing for multiple
#' criteria is not yet implemented and will result in an error.
#' @param algorithm A character string giving the optimization algorithm to use.
#' No default is set and the argument must be specified to be one of 'rsc',
#' 'federov' or 'random'.
#' @param draws The type of draws to use with Bayesian priors. No default is set
#'  and must be specified even if you are not creating a Bayesian design. Can be
#' one of "pseudo-random", "mlhs", "standard-halton", "scrambled-halton",
#' "standard-sobol","scrambled-sobol".
#' @param R An integer giving the number of draws to use. The default is 100.
#' @param dudx A character string giving the name of the prior in the
#' denominator. Must be specified when optimizing for 'c-error'
#' @param candidate_set A matrix or data frame in the "wide" format containing
#' all permitted combinations of attributes. The default is NULL. If no
#' candidate set is provided, then the full factorial subject to specified
#' exclusions will be used. This is passed in as an object and not a character
#' string. The candidate set will be expanded to include zero columns to
#' consider alternative specific attributes.
#' @param exclusions A list of exclusions Often this list will be pulled
#' directly from the list of options or it is a modified list of exclusions
#' @param control A list of control options
#'
#' @return An object of class 'spdesign'
#'
#' @export
generate_design <- function(utility,
                            rows,
                            model = "mnl",
                            efficiency_criteria = c("a-error", "c-error",
                                                    "d-error", "s-error"),
                            algorithm = c("federov", "rsc", "random"),
                            draws = c("pseudo-random", "mlhs", "standard-halton",
                                      "scrambled-halton", "standard-sobol",
                                      "scrambled-sobol"),
                            R = 100,
                            dudx = NULL,
                            candidate_set = NULL,
                            exclusions = NULL,
                            control = list(
                              cores = 1,
                              max_iter = 10000,
                              max_relabel = 10000,
                              max_no_improve = 100000,
                              efficiency_threshold = 0.1,
                              sample_with_replacement = FALSE
                            )) {

  # Match and check model arguments ----
  cli_h2("Checking function arguments")

  ## Create the design object ----
  design_object <- list()
  class(design_object) <- "spdesign"

  design_object[["utility"]] <- utility
  design_object[["time"]] <- list(
    time_start = Sys.time()
  )

  # Make sure that the best design candidate is always return if the loop is
  # stopped prematurely Can on.exit have a function?
  on.exit(
    return(design_object),
    add = TRUE
  )

  ## Match arguments ----
  design_object[["model"]] <- model <- match.arg(model)
  efficiency_criteria <- match.arg(efficiency_criteria, several.ok = TRUE)
  algorithm <- match.arg(algorithm)
  draws <- match.arg(draws)

  ## Check arguments ----
  stopifnot(is.list(utility) && !is.data.frame(utility))
  stopifnot(length(utility) > 1)
  stopifnot(all(do.call(c, lapply(utility, is_balanced, "[", "]"))))
  stopifnot(all(do.call(c, lapply(utility, is_balanced, "(", ")"))))
  # stopifnot(all_priors_and_levels_specified(utility))
  stopifnot(!any_duplicates(utility))
  stopifnot(!too_small(utility, rows))

  # Set the default for control and replace the specified values in control
  default_control <- list(
    cores = 1,
    max_iter = 10000,
    max_relabel = 10000,
    max_swap = 10000,
    max_no_improve = 100000,
    efficiency_threshold = 0.1,
    sample_with_replacement = FALSE
  )

  control <- modifyList(default_control, control)

  if (algorithm == "rsc") {
    cli_alert_info(
      "The cycling part of the algorithm is not used. It only applies to a
      small subset of designs. The algorithm swithes between relabeling of
      attribute levels and swapping of attributes."
    )
  }

  if (length(efficiency_criteria) > 1) {
    stop("Optimizing over multiple criteria is not implemented")
  }

  if (is.null(dudx) && efficiency_criteria == "c-error") {
    stop("The denominator index 'dudx' must be specified for c-error")
  }

  # Consider a core-check if relevant at a later point.
  if (control$cores > 1) {
    warning("Multicore is not implemented yet. Design will be optimized using a single core.")
    control$cores <- 1
  }

  ## Candidate set ----
  # We are only creating the candidate set if we are using a random or modified federov algorithm
  if (!is.null(candidate_set) & algorithm == "rsc") stop("To use your supplied candidate set you must use either the 'random' or 'federov' algorithms.")

  if (algorithm %in% c("random", "federov")) {
    cli_h2("Checking the candidate set and applying exclusions")

    # If no candidate set is supplied generate full factorial if not run simple
    # checks
    if (is.null(candidate_set)) {
      cli_alert_info("No candidate set supplied. The design will use the full factorial subject to supplied constraints.")

      candidate_set <- full_factorial(expand_attribute_levels(utility))

      cli_alert_success("Full factorial created")

    } else {
      stopifnot((is.matrix(candidate_set) || is.data.frame(candidate_set)))

      candidate_names_idx <- names(candidate_set) %in% names(expand_attribute_levels(utility))

      if (!all(candidate_names_idx)) {
        problem <- paste(names(candidate_set)[!candidate_names_idx], collapse = ", ")

        stop(
          paste0("There are more attributes specified in the candidate set than are present in the utility functions. ", problem, " are not specified in the utility function. This could also be caused by a mismatch in the names. The names should be of the form <utility list element name>_<attribute name>. For example, in your case, they should correspond to: '" , paste(names(expand_attribute_levels(utility)), collapse = ", "), "' The candidate set must be supplied in 'wide' format.")
        )
      }

      # Extract only the specified in the utility function to check
      regex <- paste0("\\b", attribute_names(utility))
      utility_attributes <- vector(mode = "list", length = length(utility))
      for (i in seq_along(utility)) {
        idx <- str_detect(utility[[i]], regex)
        utility_attributes[[i]] <- paste(names(utility[i]), attribute_names(utility)[idx], sep = "_")
      }

      utility_attributes <- do.call(c, utility_attributes)

      if (!all(utility_attributes %in% names(candidate_set))) {
        stop(
          paste0("Not all attributes specified in the utility functions are specified in the candidate set. This could be caused by a mismatch in the names. The names should be of the form <utility list element name>_<attribute name>. For example, in your case, they should correspond to: '" , paste(utility_attributes, collapse = ", "), "' The candidate set must be supplied in 'wide' format.")
        )
      }

      candidate_levels <- apply(candidate_set, 2, function(x) unique(sort(x)), simplify = FALSE)
      utility_levels <- lapply(expand_attribute_levels(utility), as.numeric)

      # Subset utility levels to only correspond to the ones specified
      utility_levels <- utility_levels[utility_attributes]

      if (!identical(candidate_levels[sort(names(candidate_levels))], utility_levels[sort(names(utility_levels))])) {
        problem <- paste(names(which(mapply(function(x, y) length(x) - length(y), candidate_levels, utility_levels) != 0)), collapse = ", ")

        stop(
          paste0("The attribute levels determined by the supplied candidate set differs from those supplied in the utility function. Please ensure that all specified levels are present in the candidate set. The error occurs because there are too few/many levels for: ", problem, " in the candidate set")
        )
      }

      # Expand candidate set to be square, i.e., fill in zero columns, for non-specified. This in case of
      # Alternative specific attributes!
      expanded_names <- names(expand_attribute_levels(utility))

      # Skip expansion if no alternative specific attributes are present
      if (any(!(expanded_names %in% utility_attributes))) {
        expr <- paste("cbind(candidate_set, ", paste(paste(expanded_names[!(expanded_names %in% utility_attributes)], 0, sep = " = "), collapse = ", "), ")")
        candidate_set <- eval(parse(text = expr))
      }

      candidate_set <- candidate_set[, expanded_names]

    }

    # Apply the exclusions to the candidate set
    candidate_set <- exclude(candidate_set, exclusions)

    # Transform the candiate set such that attributes that are dummy coded
    # are turned into factors. This ensures that we can use the model.matrix()
    for (i in which(names(candidate_set) %in% dummy_names(utility))) {
      candidate_set[, i] <- as.factor(candidate_set[, i])
    }

    # candidate_set <- as.matrix(candidate_set)

    cli_alert_success("All exclusions successfully applied")
  }

  # Prepare the list of priors ----
  cli_h2("Preparing the list of priors")

  design_object[["prior_values"]] <- prior_values <- prepare_priors(utility, draws, R)

  cli_alert_success("Priors prepared successfully")

  # Set up parallel ----
  if (control$cores > 1) {
    cli_h2("Preparing multicore estimation")

    stop("Multicore not implmented")

    future::plan(
      future::multicore(workers = control$cores)
    )

    cli_alert_success("Multicore estimation prepared successfully")

  }

  # Evaluate designs ----
  cli_h1("Evaluating designs")

  # Optmization function!!!!!!!
  design_object <- switch(
    algorithm,
    random = random(design_object,
                    model,
                    efficiency_criteria,
                    utility,
                    prior_values,
                    dudx,
                    candidate_set,
                    rows,
                    control),
    federov = federov(design_object,
                      model,
                      efficiency_criteria,
                      utility,
                      prior_values,
                      dudx,
                      candidate_set,
                      rows,
                      control),
    rsc = rsc(design_object,
              model,
              efficiency_criteria,
              utility,
              prior_values,
              dudx,
              candidate_set,
              rows,
              control)
  )

  design_object[["time"]][["time_end"]] <- Sys.time()

  # Turn the design object into a tibble to be tidyverse compatible
  design_object[["design"]] <- tibble::as_tibble(design_object[["design"]])

  # Print final closing messages
  cat("\n\n")
  cli_h1("Cleaning up design environment")
  cat("Time spent searching for designs: ", Sys.time() - design_object$time$time_start, "\n")

  return(
    design_object
  )
}
