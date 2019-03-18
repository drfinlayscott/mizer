
# mizer 1.1

* Users can now replace the lognormal function in the predation kernel by a
  function of their choice
* `project()` can now continue projection from last time step of a previous
  simulation provided in an optional `sim` argument
* Added function to get diet of predators
* Removed discrepancies between FFT method and old method for calculating integrals
* Values for minimum plankton size, and minimum and maximum consumer sizes set
  automatically
* Allowing feeding kernel to be kept even when using FFT methods
* Function setPredKernel() for changing predation kernel
* Set names on arrays returned by getEncounter and getPredRate
* Replaced `getPhiPrey()` by `getEncounter()` which includes the search volume
  factor.
* Added numerical unit tests
* Allow user-defined plankton dynamics
* Introduced a new parameter slot `interact_p` that sets the strength of
  interaction of species with plankton.
* Avoid duplicate graphs in rmarkdown documents by setting the default for
  the `print_it` argument in plot functions to `FALSE`.
* Introduce unstructured resources into mizer model
* Use a more general expression for the maturity ogive `psi` with two
  additional species parameters `m` and `w25`.
* Correctly deal with NAs in species parameters.
* Consistently cutting off predation kernel at 0 and beta + 3 sigma.
* `cc_pp` is calculated in a way that reduces rounding errors.
* `set_scaling_model()` now produces perfectly scale-invariant model when
  called with `perfect = TRUE`.
* Using Singular Value Decomposition to retune background species to keep
  community close to power law.
* Background species with very low abundances are automatically removed.
* Converted all S4 methods to functions to decrease the learning curve for
  new developers.
* Changed naming convention: function names are now in camelCase.
* Renamed some functions for consistency and to make them easier to understand,
  but kept old names as aliases for backwards compatibility:
  + `getmM2` -> `getPredMort`
  + `getM2background` -> `getPlanktonMort`
  + `getZ` -> `getMort`
  + `getESpawning` -> `getERepro`
  + `MizerParams` -> `emptyParams` or `set_multispecies_model`
* Improvement to MizerParams class:
  + Merged `std_metab` and `activity` slots into a single `metab` slot.
  + Moved `w_min_idx` out of `species_params` into its own slot.
* Started work on two new vignettes:
  + `developer_vignette.Rmd`
  + `mathematical_details.Rmd`
* Code improvements:
  + Starting to use assert_that to check arguments to functions.
  + Added more unit tests.


# mizer 1.0

* Fixed bugs in how the start time of a simulation was handled. This leads to
  small corrections, so that the output of this version is slightly different 
  from previous versions.
* Introduced a scale-invariant trait-based model, set up with 
  `set_scaling_model()`, see section 12 in the vignette.
* Added a function that adds news species to a scale-invariant background, 
  and computes an approximately steady state close to the power law, see
  section 13 in the vignette.
* Created an example shiny app to allow people to use mizer through a web 
  browser without having to install mizer. The app explores the effect of more 
  selective fishing gear in a case study.
* `project()` now shows a progress bar while simulation is running.
* Improvements to plots:
  + Added units to axes
  + Added method for plotting growth curves
  + `PlotYield()` no longer fails when species names are numbers or when a 
     species abundance is zero
  + Added a `total` parameter to several plot methods to add the curve for the 
     total community (sum over all species and plankton)
  + Added a `species` parameter to all plot methods to allow for only a 
      selection of species to be plotted
  + Allow the number of ticks on y-axis in biomass plot to be controlled
* Allow for size- and species-dependent background death.
* Add initial_n and initial_n_pp slots to mizer params.
* Now checking that effort times are increasing.
* Corrections in the documentation.
* Improvements to the vignette.
* Fix potential problems with negative numbers due to numerical errors.
* Fix a bug in the divisibility checks.
* Add a test of the numeric solution against an analytic solution.


# mizer 0.4

* Improvements made to the speed by evaluating convolution sums via fft,
  removing the bottlenecks in `getPhiPrey()` and `getPredRate()`.
* Using C++ for the inner loop in the project method for extra speed.
* Minor corrections to vignette and documentation to bring them into alignment
  and to document the new home on github and new maintainers.


# mizer 0.3

* Improvements made to the speed of the simulations. Remaining bottle necks 
  are the sweep statements in `getPhiPrey()` and `getPredRate()`.
* Moved tests to new suggested folder.
* Minor changes to documentation to pass new check requirements.


# mizer 0.2

* Release to coincide with the submission of the MEE paper. No major changes. 
  Just minor bug fixes.


# mizer 0.1

* Beta release - just about works but still some gremlins to sort out.
  There are a number of features I'd like to add in the coming relases.
