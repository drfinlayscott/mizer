#' Set fishing parameters
#' 
#' @section Setting fishing:
#' 
#' \strong{Gears}
#' 
#' In `mizer`, fishing mortality is imposed on species by fishing gears. The
#' total per-capita fishing mortality (1/year) is obtained by summing over the
#' mortality from all gears,
#' \deqn{\mu_{f.i}(w) = \sum_g F_{g,i}(w),}
#' where the fishing mortality \eqn{F_{g,i}(w)} imposed by gear \eqn{g} on
#' species \eqn{i} at size \eqn{w} is calculated as:
#' \deqn{F_{g,i}(w) = S_{g,i}(w) Q_{g,i} E_{g},}
#' where \eqn{S} is the selectivity by species, gear and size, \eqn{Q} is the 
#' catchability by species and gear and \eqn{E} is the fishing effort by gear.
#' 
#' \strong{Selectivity}
#' 
#' The selectivity at size of each gear for each species is saved as a three
#' dimensional array (gear x species x size). Each entry has a range between 0 
#' (that gear is not selecting that species at that size) to 1 (that gear is
#' selecting all individuals of that species of that size). This three
#' dimensional array can be specified explicitly via the `selectivity`
#' argument, but usually mizer calculates it from the `gear_params` slot of
#' the MizerParams object.
#' 
#' To allow the calculation of the `selectivity` array, the `gear_params` slot
#' must be a data frame with one row for each gear-species combination. So if
#' for example a gear can select three species, then that gear contributes three
#' rows to the `gear_params` data frame, one for each species it can select. The
#' data frame must have columns `gear`, holding the name of the gear, `species`,
#' holding the name of the species, and `sel_func`, holding the name of the
#' function that calculates the selectivity curve. Some selectivity functions
#' are included in the package: `knife_edge()`, `sigmoid_length()`,
#' `double_sigmoid_length()`, and `sigmoid_weight()`. 
#' Users are able to write their own size-based selectivity function. The first
#' argument to the function must be `w` and the function must return a vector of
#' the selectivity (between 0 and 1) at size.
#' 
#' Each selectivity function may have parameters. Values for these
#' parameters must be included as columns in the gear parameters data.frame.
#' The names of the columns must exactly match the names of the corresponding
#' arguments of the selectivity function. For example, the default selectivity
#' function is `knife_edge()` that a has sudden change of selectivity from 0 to 1
#' at a certain size. In its help page you can see that the `knife_edge()`
#' function has arguments `w` and `knife_edge_size`. The first argument, `w`, is
#' size (the function calculates selectivity at size). All selectivity functions
#' must have `w` as the first argument. The values for the other arguments must
#' be found in the gear parameters data.frame. So for the `knife_edge()`
#' function there should be a `knife_edge_size` column. Because `knife_edge()`
#' is the default selectivity function, the `knife_edge_size` argument has a
#' default value = `w_mat`.
#' 
#' In case each species is only selected by one gear, the columns of the
#' `gear_params` data frame can alternatively be provided as columns of the
#' `species_params` data frame, if this is more convenient for the user to set
#' up. Mizer will then copy these columns over to create the `gear_params` data
#' frame when it creates the MizerParams object. However changing these columns
#' in the species parameter data frame later will not update the `gear_params`
#' data frame.
#'
#' \strong{Catchability}
#' 
#' Catchability is used as an additional factor to make the link between gear
#' selectivity, fishing effort and fishing mortality. For example, it can be set
#' so that an effort of 1 gives a desired fishing mortality. In this way effort
#' can then be specified relative to a 'base effort', e.g. the effort in a
#' particular year. 
#' 
#' Catchability is stored as a two dimensional array (gear x species). This can
#' either be provided explicitly via the `catchability` argument, or the
#' information can be provided via a `catchability` column in the `gear_params`
#' data frame. 
#' 
#' In the case where each species is selected by only a single gear, the
#' `catchability` column can also be provided in the `species_params` data
#' frame. Mizer will then copy this over to the `gear_params` data frame when
#' the MizerParams object is created.
#' 
#' \strong{Effort}
#' 
#' The initial fishing effort is stored in the `MizerParams` object. If it is
#' not supplied, it is set to zero. The initial effort can be overruled when
#' the simulation is run with `project()`, where it is also possible to specify
#' an effort that varies through time.
#' 
#' @param params A MizerParams object
#' @param selectivity Optional. An array (gear x species x size) that holds the
#'   selectivity of each gear for species and size, \eqn{S_{g,i,w}}.
#' @param catchability Optional. An array (gear x species) that holds the catchability of
#'   each species by each gear, \eqn{Q_{g,i}}.
#' @param initial_effort Optional. A number or a named numeric vector specifying
#'   the fishing effort. If a number, the same effort is used for all gears. If
#'   a vector, must be named by gear.
#' @param comment_selectivity `r lifecycle::badge("experimental")`
#'   A string describing how the value for 'selectivity' was obtained. This is
#'   ignored if 'selectivity' is not supplied or already has a comment
#'   attribute.
#' @param comment_catchability `r lifecycle::badge("experimental")`
#'   A string describing how the value for 'catchability' was obtained. This is
#'   ignored if 'catchability' is not supplied or already has a comment
#'   attribute.
#' @param ... Unused
#'   
#' @return MizerParams object with updated catchability and selectivity. Because
#'   of the way the R language works, `setFishing()` does not make the changes
#'   to the params object that you pass to it but instead returns a new params
#'   object. So to affect the change you call the function in the form
#'   `params <- setFishing(params, ...)`.
#' @export
#' @seealso [gear_params()]
#' @family functions for setting parameters
setFishing <- function(params, selectivity = NULL, catchability = NULL, 
                       comment_selectivity = "set manually", 
                       comment_catchability = "set manually", 
                       initial_effort = NULL, ...) {
    assert_that(is(params, "MizerParams"))
    species_params <- params@species_params
    gear_params <- params@gear_params
    sp_names <- as.character(species_params$species)
    no_sp <- length(sp_names)
    w_names <- dimnames(params@selectivity)[[3]]
    no_w <- length(params@w)
    gear_names <- as.character(unique(gear_params$gear))
    no_gears <- length(gear_names)
    # The number of gears could be set by the catchability array
    if (!is.null(catchability) && (dim(catchability)[[1]] != no_gears)) {
        if (is.null(selectivity)) {
            stop("The catchability array has changed the number of gears. ",
                 "Therefore you also need to supply a selectivity array.")
        }
        if (is.null(dimnames(catchability))) {
            stop("The catchability array needs to set the names of the ",
                 " gears via its dimnames.")
        }
        # change gear number and names
        gear_names <- unique(dimnames(catchability)[[1]])
        no_gears <- length(gear_names)
        if (no_gears != dim(catchability)[[1]]) {
            stop("The gear names provided via the dimnames of the ",
                 "catchability array need to be all different.")
        }
    }
    
    if (!is.null(selectivity)) {
        if (is.null(comment(selectivity))) {
            comment(selectivity) <- comment_selectivity
        }
        assert_that(length(dim(selectivity)) == 3,
                    dim(selectivity)[[1]] == no_gears,
                    dim(selectivity)[[2]] == no_sp,
                    dim(selectivity)[[3]] == no_w)
        dnames <- dimnames(selectivity)
        if (!is.null(dnames)) {
            if (!identical(dnames[[1]], gear_names)) {
                stop("The gear dimnames in the selectivity array do ",
                     "not match the gear names.")
            }
            if (!identical(dnames[[2]],sp_names)) {
                stop("The species dimnames in the selectivity array do ",
                     "not match the species names.")
            }
            if (!identical(dnames[[3]], w_names)) {
                warning("I have changed the size dimnames in the ",
                        "selectivity array to agree with mizer conventions.")
            }
        }
        dimnames(selectivity) <- list(gear = gear_names, 
                                      sp = sp_names,
                                      w = w_names)
        params@selectivity <- selectivity
    } else {
        selectivity <- 
            array(0, dim = c(no_gears, no_sp, no_w),
                  dimnames = list(gear = gear_names, 
                                  sp = sp_names,
                                  w = w_names
                  )
            )
        for (g in seq_len(nrow(gear_params))) {
            # These as.characters are annoying - but factors everywhere
            species <- as.character(gear_params[g, 'species'])
            gear <- as.character(gear_params[g, 'gear'])
            sel_func <- as.character(gear_params[g, 'sel_func'])
            # get args
            arg <- names(formals(sel_func))
            # lop off the arguments that we will supply
            arg <- arg[!(arg %in% c("w", "species_params", "..."))]
            if (!all(arg %in% colnames(gear_params))) {
                stop("Some arguments needed for the selectivity function are ",
                     "missing in the gear_params dataframe.")
            }
            # Check that there are no missing values for selectivity parameters
            if (any(is.na(as.list(gear_params[g, arg])))) {
                stop("Some selectivity parameters are NA.")
            }
            # Call selectivity function with selectivity parameters
            par <- c(list(w = params@w, 
                          species_params = as.list(species_params[species, ])),
                     as.list(gear_params[g, arg]))
            sel <- do.call(sel_func, args = par)
            selectivity[gear, species, ] <- sel
        }
        if (!is.null(comment(params@selectivity)) &&
            !identical(selectivity, params@selectivity)) {
            message("The selectivity has been commented and therefore will ",
                    "not be recalculated from the species parameters.")
        } else {
            params@selectivity <- selectivity
        }
    }
    
    if (!is.null(catchability)) {
        if (is.null(comment(catchability))) {
            comment(catchability) <- comment_catchability
        }
        assert_that(length(dim(catchability)) == 2,
                    dim(catchability)[[2]] == no_sp)
        # Check dimnames if they were provided, otherwise set them
        dnames <- dimnames(catchability)
        if (!is.null(dnames)) {
            if (!identical(dnames[[1]], gear_names)) {
                stop("The gear dimnames in the catchability array do ",
                     "not match the gear names.")
            }
            if (!identical(dnames[[2]], sp_names)) {
                stop("The species dimnames in the catchability array do ",
                     "not match the species names.")
            }
        } else {
            dimnames(catchability) <- list(gear = gear_names,
                                           sp = sp_names)
        }
        params@catchability <- catchability
    } else {
        catchability <- 
            array(0, dim = c(no_gears, no_sp),
                  dimnames = list(gear = gear_names, 
                                  sp = sp_names
                  )
            )
        for (g in seq_len(nrow(gear_params))) {
            catchability[[as.character(gear_params$gear[[g]]), 
                          as.character(gear_params$species[[g]])]] <-
                gear_params$catchability[[g]]
        }
        if (!is.null(comment(params@catchability)) &&
            !identical(catchability, params@catchability)) {
            message("The catchability has been commented and therefore will ",
                    "not be updated from the species parameters.")
        } else {
            params@catchability <- catchability
        }
    }
    
    if (!is.null(initial_effort)) {
        params@initial_effort[] <- validEffortVector(initial_effort, params)
        comment(params@initial_effort) <- comment(initial_effort)
    }
    
    # Get rid of any efforts for gears that no longer exist and set effort
    # for new gears to zero (done by `validEffortVector()`).
    existing <- names(params@initial_effort) %in% gear_names
    params@initial_effort <- validEffortVector(params@initial_effort[existing], 
                                               params)
    
    return(params)
}

#' Gear parameters
#' 
#' These functions allow you to get or set the gear parameters stored in
#' a MizerParams object. These are used by [setFishing()] to set up the 
#' selectivity and catchability and thus together with the fishing effort
#' determine the fishing mortality.
#' 
#' The `gear_params` data has one row for each gear-species pair and one
#' column for each parameter that determines how that gear interacts with that
#' species. For the details see [setFishing()].
#' 
#' If you change a gear parameter, this will be used to recalculate the
#' `selectivity` and `catchability` arrays by calling [setFishing()],
#' unless you have protected these with comments.
#' @param params A MizerParams object
#' @export
#' @family functions for setting parameters
gear_params <- function(params) {
    params@gear_params
}

#' @rdname gear_params
#' @param value A data frame with the gear parameters.
#' @seealso [validGearParams()]
#' @export
`gear_params<-` <- function(params, value) {
    value <- validGearParams(value, params@species_params)
    params@gear_params <- value
    setFishing(params)
}

#' @rdname setFishing
#' @export
getCatchability <- function(params) {
    params@catchability
}

#' @rdname setFishing
#' @export
getSelectivity <- function(params) {
    params@selectivity
}

#' @rdname setFishing
#' @export
getInitialEffort <- function(params) {
    params@initial_effort
}

#' Check validity of gear parameters and set defaults
#' 
#' The function returns a valid gear parameter data frame that can be used
#' by `setFishing()` or it gives an error message.
#' 
#' The gear_params data frame is allowed to have zero rows, but if it has
#' rows, then the following requirements apply:
#' * There must be columns `species` and `gear` and any species - gear pair is 
#'   allowed to appear at most once. Any species that appears must also appear
#'   in the `species_params` data frame.
#' * There must be a `sel_func` column. If a selectivity function is not 
#'   supplied, it will be set to "knife_edge".
#' * There must be a `catchability` column. If a catchability is not supplied,
#'   it will be set to 1.
#' * All the parameters required by the selectivity functions must be provided.
#' 
#' If gear_params is empty, then this function tries to find the necessary
#' information in the species_params data frame. This restricts each species
#' to be fished by only one gear. Defaults are used for information that can
#' not be found in the species_params dataframe, as follows:
#' * If there is no `gear` column or it is NA then a new gear named after the
#'   species is introduced.
#' * If there is no `sel_func` column or it is NA then `knife_edge` is used.
#' * If there is no `catchability` column or it is NA then this is set to 1.
#' * If the selectivity function is `knife_edge` and no `knife_edge_size` is
#'   provided, it is set to `w_mat`.
#'   
#' For backwards compatibility, when `gear_params` is `NULL` and there is no
#' gear information in the `species_params`, then a gear called `knife_edge_gear`
#' is set up with a `knife_edge` selectivity for each species and a
#' `knive_edge_size` equal to `w_mat`. Catchability is set to 1 for all species.
#' 
#' @param gear_params Gear parameter data frame
#' @param species_params Species parameter data frame
#' @return A valid gear parameter data frame
#' @concept helper
#' @seealso [gear_params()]
#' @export
validGearParams <- function(gear_params, species_params) {
    
    # This is to agree with old defaults
    if (is.null(gear_params) && 
        !("gear" %in% names(species_params) || 
            "sel_func" %in% names(species_params))) {
        gear_params <- 
            data.frame(species = species_params$species,
                       gear = "knife_edge_gear",
                       sel_func = "knife_edge",
                       knife_edge_size = species_params$w_mat,
                       catchability = 1,
                       stringsAsFactors = FALSE) # for old versions of R
    }
    
    species_params <- validSpeciesParams(species_params)
    no_sp <- nrow(species_params)
    
    # If no gear_params are supplied, but there is either a gear or sel_func
    # column in the species_params data frame, then try to extract information
    # from there.
    if ((is.null(gear_params) || nrow(gear_params) == 0) &&
        ("gear" %in% names(species_params) || 
         "sel_func" %in% names(species_params))) {
        # Try to take parameters from species_params
        gear_params <- 
            data.frame(species = as.character(species_params$species),
                       stringsAsFactors = FALSE)
        if ("gear" %in% names(species_params)) {
            gear_params$gear <- as.character(species_params$gear)
            gear_params$gear[is.na(gear_params$gear)] <- 
                species_params$species[is.na(gear_params$gear)]
        } else {
            gear_params$gear <- species_params$species
        }
        if ("sel_func" %in% names(species_params)) {
            gear_params$sel_func <- as.character(species_params$sel_func)
            gear_params$sel_func[is.na(gear_params$sel_func)] <- "knife_edge"
        } else {
            gear_params$sel_func <- "knife_edge"
        }
        if ("catchability" %in% names(species_params)) {
            gear_params$catchability <- species_params$catchability
            gear_params$catchability[is.na(gear_params$catchability)] <- 1
        } else {
            gear_params$catchability <- 1
        }
        # copy over any selectivity function parameters
        for (g in seq_len(no_sp)) {
            args <- names(formals(as.character(gear_params[g, 'sel_func'])))
            args <- args[!(args %in% c("w", "species_params", "..."))]
            for (arg in args) {
                if (!arg %in% names(gear_params)) {
                    gear_params[[arg]] <- NA
                }
                if (arg %in% names(species_params) && 
                    !is.na(species_params[g, arg])) {
                    gear_params[g, arg] <- species_params[g, arg]
                } else if (arg == "knife_edge_size") {
                    gear_params[g, arg] <- species_params$w_mat[[g]]
                } else {
                    stop("You need to provide an `", arg, "` column in the species parameter data frame.")
                }
            }
        }
    }
    
    # An empty gear_params data frame is valid
    if (nrow(gear_params) == 0) {
        return(gear_params)
    }
    
    if (!all(c("species", "gear") %in% names(gear_params))) {
        stop("`gear_params` must have columns 'species' and 'gear'.")
    }
    
    # Check that every species mentioned in gear_params exists
    if (!all(gear_params$species %in% species_params$species)) {
        stop("The gear_params dataframe contains species that do not exist in the model.")
    }
    
    # Check that there are no duplicate gear-species pairs
    if (anyDuplicated(gear_params[, c("species", "gear")])) {
        stop("Some species - gear pairs appear more than once.")
    }
    
    # Default selectivity function is knife_edge
    if (!("sel_func" %in% names(gear_params))) {
        gear_params$sel_func <- "knife_edge"
    }
    gear_params$sel_func[is.na(gear_params$sel_func)] <- "knife_edge"
    
    # Default gear name is species name
    sel <- is.na(gear_params$gear)
    gear_params$gear[sel] <- gear_params$species[sel]
    
    # Ensure there is knife_edge_size columng if any knife_edge selectivity function
    if (any(gear_params$sel_func == "knife_edge") &&
        !("knife_edge_size" %in% names(gear_params))) {
        gear_params$knife_edge_size <- NA
    }
    
    # Check that every row is complete
    for (g in seq_len(nrow(gear_params))) {
        if ((gear_params$sel_func[[g]] == "knife_edge") &&
            is.na(gear_params$knife_edge_size[[g]])) {
            sel <- species_params$species == gear_params$species[[g]]
            gear_params$knife_edge_size[[g]] <- species_params$w_mat[sel]
        }
        # get args
        # These as.characters are annoying - but factors everywhere
        arg <- names(formals(as.character(gear_params[g, 'sel_func'])))
        arg <- arg[!(arg %in% c("w", "species_params", "..."))]
        if (!all(arg %in% colnames(gear_params))) {
            stop("Some arguments needed for the selectivity function are ",
                 "missing in the gear parameter dataframe.")
        }
        # Check that there are no missing values for selectivity parameters
        if (any(is.na(as.list(gear_params[g, arg])))) {
            stop("Some selectivity parameters are NA.")
        }
    }
    if (!("catchability" %in% names(gear_params))) {
        gear_params$catchability <- 1
    }
    gear_params$catchability[is.na(gear_params$catchability)] <- 1

    gear_params
}

#' Return valid effort vector
#' 
#' A valid effort vector is a named vector with one entry for each gear,
#' with the gear names in the same order as in the params object. 
#' 
#' The function also accepts an `effort` that is not yet valid:
#' 
#' * a scalar, which is then replicated for each gear
#' * an unnamed vector, which is then assumed to be in the same order as the
#'   gears in the params object
#' * a named vector in which the gear names have a different order than in the
#'   params object. This is then sorted correctly.
#' * a named vector which only supplies values for some of the gears.
#'   The effort for the other gears is then set to zero.
#'   
#' An `effort` argument will lead to an error if it is either
#' * unnamed and of the wrong length
#' * named but where some names do not match any of the gears
#' * not numeric
#' 
#' @param params A MizerParams object
#' @param effort An vector or scalar.
#' 
#' @return A valid effort vector with one entry for each gear, named by gear,
#'   in the same order as in the params object.
#' @export
#' @concept helper
validEffortVector <- function(effort, params) {
    assert_that(is(params, "MizerParams"),
                (is.null(effort) || is.numeric(effort)))
    gear_names <- dimnames(params@catchability)[[1]]
    no_gears <- length(gear_names)
    
    # If only one effort is given, it is replicated for all gears
    if (length(effort) == 1) {
        effort <- rep(effort, no_gears)
        names(effort) <- gear_names
    }
    
    # If effort is unnamed but of the right length, then set gear names
    if (is.null(names(effort))) {
        if (length(effort) != no_gears) {
            stop("Effort vector must be the same length as the number of fishing gears.")
        }
        names(effort) <- gear_names
    }
    
    # Effort vector should not supply effort for non-existent gears
    if (!all(names(effort) %in% gear_names)) {
        stop("The effort vector is invalid as it has names that are not among the gear names")
    }

    # Set any missing efforts to zero
    missing <- setdiff(gear_names, names(effort))
    new <- rep(0, length(missing))
    names(new) <- missing
    effort <- c(effort, new)
    
    # Sort vector
    effort <- effort[gear_names]
    
    return(effort)
}
