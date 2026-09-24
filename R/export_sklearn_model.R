#' @title Export a spectral_model as an sklearn/chemotools Pipeline (JSON)
#' @name export_sklearn_model
#'
#' @description
#'
#' \loadmathjax
#'
#' Serializes a \code{\link[=calibrate]{spectral_model}} object into openmodels-shaped JSON
#' whose \code{estimator_class} values are real scikit-learn/chemotools class
#' names, so it can be loaded directly in Python as a working
#' \code{sklearn.pipeline.Pipeline} via
#' \href{https://github.com/Gnpd/openmodels}{openmodels}, with
#' \href{https://github.com/paucablop/chemotools}{chemotools} and
#' \href{https://github.com/Gnpd/proximetricsr-estimators}{proximetricsr-estimators}
#' registered as custom estimator providers:
#'
#' \preformatted{
#' from openmodels import SerializationManager, SklearnSerializer
#' from chemotools.utils.discovery import all_estimators as chemotools_estimators
#' from proximetricsr_estimators.utils.discovery import all_estimators as pr_estimators
#'
#' manager = SerializationManager(
#'     SklearnSerializer(custom_estimators=[chemotools_estimators, pr_estimators])
#' )
#' model = manager.load("exported_from_R.json")
#' predictions = model.predict(X)
#' }
#'
#' @usage
#' export_sklearn_model(object, file = NULL)
#'
#' @param object an object of class \code{spectral_model}, as returned by
#' \code{\link{calibrate}}.
#' @param file an optional character string with the path (including file name)
#' where the JSON output should be written. If \code{NULL} (default), no file is
#' written and the JSON string is returned.
#'
#' @return If \code{file = NULL} (default), the JSON string is returned visibly
#' so it can be inspected or assigned to a variable. If \code{file} is specified,
#' the JSON is written to that file and returned invisibly.
#'
#' @details
#' This export is restricted to
#' preprocessing/method combinations that have a working chemotools/scikit-learn
#' equivalent reconstructible via a plain \code{Pipeline.predict(X)} call. A
#' clear, named error is raised for:
#' \itemize{
#'   \item \code{prep_derivative()}/\code{prep_smooth()} steps using
#'     \code{algorithm = "nwp"} (BUCHI NIRWise PLUS exact-match preprocessing
#'     math has no chemotools equivalent) -- note this restriction does *not*
#'     apply to \code{fit_plsr()}/\code{fit_xlsr()}'s own \code{type = "nwp"}:
#'     predictions from an \code{"nwp"}-type model are numerically identical to
#'     a \code{"modified"}-type model fitted on the same data (the two only
#'     differ in the internal score-space representation, not in
#'     \code{coefficients}/\code{intercept}), so \code{type = "nwp"} models
#'     export the same as \code{"modified"} ones;
#'   \item \code{prep_derivative(algorithm = "gap-segment")} (its chemotools
#'     equivalent, \code{NorrisWilliams}, precomputes an internal kernel that
#'     has not yet been verified to reproduce correctly from R);
#'   \item \code{prep_transform(to = "reflectance")} (mirrors
#'     \code{\link{proxiscout_write_model}}'s existing behaviour of only
#'     supporting the reflectance-to-absorbance direction);
#'   \item \code{prep_wav_trim(trim_constant_edges = TRUE)} (data-dependent, no
#'     chemotools equivalent);
#'   \item \code{prep_resample()} (its chemotools equivalent,
#'     \code{XAxisInterpolator}, requires scikit-learn metadata routing --
#'     the incoming spectra's x-axis must be passed explicitly to every
#'     \code{predict()} call -- unlike every other step here, so it cannot be
#'     used in a plain \code{Pipeline.predict(X)} workflow).
#' }
#' These restrictions apply only to this export; they say nothing about which
#' models proximetricsR itself supports.
#'
#' The PLS/XLS regression step is exported as a
#' \code{proximetricsr_estimators.regression.NIRWiseLinearModel}: prediction from
#' an already-fitted proximetricsR model is always affine
#' (\code{(X - x_means) \%*\% t(coefficients) + intercept}), regardless of fitting
#' algorithm, so this single class covers every supported
#' \code{fit_plsr()}/\code{fit_xlsr()} combination -- \code{fit_method}/\code{type}/
#' \code{min_w}/\code{max_w} are kept as constructor parameters purely for
#' provenance, matching \code{\link{fit_plsr}}/\code{\link{fit_xlsr}}.
#'
#' \code{prep_transform(to = "absorbance")} is exported as
#' \code{chemotools.physics.IntensityConversion(input_unit = "reflectance",
#' output_unit = "pseudoabsorbance")}, not \code{output_unit = "absorbance"}:
#' proximetricsR's \code{to = "absorbance"} computes \mjeqn{A = -\log_{10}(R)}{A =
#' -log10(R)} directly from reflectance, which is what chemotools calls
#' "pseudoabsorbance" (its "absorbance"/"transmittance" pair instead follows the
#' Beer-Lambert transmittance convention, a different physical quantity).
#'
#' @seealso \code{\link{calibrate}}, \code{\link{proxiscout_write_model}}
#'
#' @examples
#' \donttest{
#' data("proximateCannabis")
#' recipe <- preprocess_recipe(
#'   prep_wav_trim(band = c(1100, 1600)),
#'   prep_snv(),
#'   device = "unspecified"
#' )
#' model <- calibrate(CBDA ~ spc,
#'   data = proximateCannabis, preprocess = recipe,
#'   method = fit_plsr(5, type = "standard"),
#'   control = calibration_control("none"), verbose = FALSE
#' )
#' json <- export_sklearn_model(model)
#' }
#' @author Leonardo Ramirez-Lopez
#' @export
export_sklearn_model <- function(object, file = NULL) {
  if (!inherits(object, "spectral_model")) {
    stop("'object' must be of class 'spectral_model'.")
  }
  model <- object$final_model$model
  if (is.null(model)) {
    stop("'object' does not contain a fitted model (object$final_model$model is NULL).")
  }
  if (!is.null(file) && (!is.character(file) || length(file) != 1)) {
    stop("'file' must be a single character string, if provided.")
  }

  steps <- object$preprocess$steps
  # Every step is translated against the grid entering it, and the model step
  # against the grid leaving the last one, so "step_0" .. "step_N" must all be
  # present. predict() does not need them, so a model reloaded from a
  # predict() recomputes them, so an object that has lost them still predicts
  # correctly; without this check the export silently produced a structurally
  # valid file whose coefficients were all null.
  needed <- paste0("step_", seq_len(length(steps) + 1L) - 1L)
  if (!all(needed %in% names(object$processed_wavs))) {
    stop(
      "'object' does not carry the processed wavelength grid its preprocessing ",
      "steps were applied on (object$processed_wavs is missing ",
      sum(!needed %in% names(object$processed_wavs)), " of ", length(needed),
      " entries), so the x-axis of each exported step cannot be determined. ",
      "Export from the object calibrate() returned."
    )
  }
  step_docs <- list()
  # prep_snv() standardises with the sample SD (denominator n - 1, R's sd());
  # chemotools' StandardNormalVariate uses numpy's population SD (denominator
  # n). The two therefore differ by a constant factor, tracked here and folded
  # exactly into the final affine model step below rather than left as a silent
  # ~0.2% scale error in every prediction.
  snv_scale <- 1
  for (i in seq_along(steps)) {
    x_axis_in <- as.numeric(object$processed_wavs[[paste0("step_", i - 1)]])
    x_axis_out <- as.numeric(object$processed_wavs[[paste0("step_", i)]])
    translated <- .translate_prep_step(steps[[i]], x_axis_in, x_axis_out)
    step_name <- paste0("step", i, "_", gsub("^prep_", "", steps[[i]]$method))
    step_docs[[length(step_docs) + 1L]] <- list(step_name, translated)

    if (identical(translated$estimator_class, "StandardNormalVariate")) {
      # SNV is scale-invariant, so any factor carried in here is absorbed.
      snv_scale <- sqrt((length(x_axis_in) - 1) / length(x_axis_in))
    } else if (!isTRUE(all.equal(snv_scale, 1))) {
      # Only steps that commute with a scalar multiple can carry the factor
      # forward to the model.
      if (!translated$estimator_class %in% c(
        "SavitzkyGolay", "SavitzkyGolayFilter", "MeanFilter",
        "RangeCut", "PolynomialCorrection"
      )) {
        stop(
          "export_sklearn_model() cannot reproduce prep_snv() exactly when it is ",
          "followed by a non-linear step (here '", steps[[i]]$method, "'): ",
          "prep_snv() uses the sample standard deviation while chemotools' ",
          "StandardNormalVariate uses the population one, and the resulting ",
          "constant factor cannot be carried through that step. Reorder the ",
          "recipe so prep_snv() is not followed by prep_transform()."
        )
      }
    }

    # proximetricsR's moving-window filters drop the (w - 1) / 2 edge points the
    # window cannot cover, so the step narrows the x-axis. Their chemotools
    # counterparts pad instead and are length-preserving, which leaves the
    # Python pipeline handing the next step more features than it was fitted on.
    # Emit an explicit RangeCut reproducing R's own recorded output grid.
    if (translated$estimator_class %in%
      c("SavitzkyGolay", "SavitzkyGolayFilter", "MeanFilter") &&
      length(x_axis_out) != length(x_axis_in)) {
      step_docs[[length(step_docs) + 1L]] <- list(
        paste0(step_name, "_trim"),
        .make_range_cut(x_axis_in, x_axis_out)
      )
    }
  }

  model_step <- list(
    "model",
    list(
      estimator_class = "NIRWiseLinearModel",
      params = list(
        fit_method = model$method$fit_method,
        type = model$method$type,
        ncomp = as.integer(object$final_ncomp),
        min_w = if (is.null(model$method$min_w)) NULL else as.integer(model$method$min_w),
        max_w = if (is.null(model$method$max_w)) NULL else as.integer(model$method$max_w)
      ),
      # NIRWiseLinearModel constrains min_w/max_w to Interval(Integral, ...), so
      # they must not arrive as floats.
      param_types = list(
        fit_method = "str",
        type = "str",
        ncomp = "int",
        min_w = if (is.null(model$method$min_w)) "NoneType" else "int",
        max_w = if (is.null(model$method$max_w)) "NoneType" else "int"
      ),
      attributes = list(
        # x_means_ / coef_ absorb the prep_snv() sample-vs-population SD factor
        # (snv_scale; 1 when the recipe has no prep_snv step): R predicts on
        # X_R = snv_scale * X_python, and
        # (snv_scale * X_py - x_means) %*% coef == (X_py - x_means / snv_scale)
        # %*% (snv_scale * coef), leaving the intercept untouched.
        x_means_ = unname(model$x_means) / snv_scale,
        coef_ = unname(model$coefficients[object$final_ncomp, ]) * snv_scale,
        intercept_ = unname(model$intercept)[1],
        n_features_in_ = length(model$x_means),
        # The coefficient axis is provenance, deliberately NOT emitted as
        # scikit-learn's feature_names_in_: the model step always receives a
        # plain array from the preceding chemotools transformer, so that
        # attribute can never be satisfied -- it warns on every predict() with
        # array input, and raises ValueError under set_output("pandas"), where
        # the upstream transformer relabels the columns "x0", "x1", ...
        wavenumbers_ = as.numeric(object$processed_wavs[[paste0("step_", length(steps))]])
      ),
      attribute_types = list(
        x_means_ = "ndarray",
        coef_ = "ndarray",
        intercept_ = "float",
        n_features_in_ = "int",
        wavenumbers_ = "ndarray"
      ),
      attribute_dtypes = list(
        x_means_ = "float64",
        coef_ = "float64",
        wavenumbers_ = "float64"
      )
    )
  )

  all_steps <- c(step_docs, list(model_step))

  step_classes <- vapply(all_steps, function(s) s[[2]]$estimator_class, character(1))
  package_names <- sort(unique(c(
    "sklearn", # the root Pipeline itself
    ifelse(
      step_classes %in% c("NIRWiseLinearModel", "ProximetricsPLS", "ProximetricsXLS"),
      "proximetricsr_estimators", "chemotools"
    )
  )))
  # openmodels' generic deserializer only recurses into a nested (name, estimator)
  # pair when its type is tagged as a *list* of ("str", <EstimatorClass>) pairs in
  # param_types -- this must be supplied explicitly here since these dicts are
  # hand-authored in R rather than produced by openmodels' own Python-side
  # introspection (which derives it automatically from Pipeline.get_params()).
  step_types <- lapply(all_steps, function(s) list("str", s[[2]]$estimator_class))

  doc <- list(
    estimator_class = "Pipeline",
    params = list(
      steps = all_steps,
      memory = NULL,
      verbose = FALSE
    ),
    param_types = list(
      steps = step_types,
      memory = "NoneType",
      verbose = "bool"
    ),
    # openmodels format v3 (see its docs/format.md, "Files written by other
    # tools"): producer_* names the tool that wrote the file (ONNX convention);
    # domain_version/packages name the Python versions whose attribute layouts
    # this file follows, which openmodels compares against the loading
    # environment (warning only); dependency_versions is this R session's own
    # runtime. openmodels_version is left out -- openmodels didn't write this.
    metadata = list(
      producer_name = "proximetricsR",
      producer_version = as.character(utils::packageVersion("proximetricsR")),
      domain = "sklearn",
      domain_version = .sklearn_export_targets[["sklearn"]],
      # One entry per package contributing an estimator class anywhere in the tree.
      packages = as.list(.sklearn_export_targets[package_names]),
      openmodels_format_version = 3L,
      created_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      dependency_versions = list(
        R = as.character(getRversion()),
        jsonlite = as.character(utils::packageVersion("jsonlite"))
      )
    )
  )

  # `doc` is written as-is: every value above is already built in the shape
  # openmodels expects (plain scalars and unnamed numeric vectors), and
  # attribute_types/param_types carry the typing. Nothing here is re-encoded
  # into an R-specific wire form -- a named vector or matrix reaching the JSON
  # would be a bug in the translation above, not something to wrap.
  #
  # digits = I(17): jsonlite's digits = NA is 15 significant digits, which is
  # NOT round-trip safe for a float64 (up to ~22 ULP of error). 17 is the
  # shortest width that always reads back the identical double.
  json <- toJSON(doc, auto_unbox = TRUE, null = "null", na = "null", digits = I(17))

  if (!is.null(file)) {
    writeLines(json, con = file)
    return(invisible(json))
  }
  json
}

#' @title Python package versions targeted by export_sklearn_model()
#' @description internal constant. The scikit-learn/chemotools/
#' proximetricsr-estimators versions whose fitted-attribute layouts
#' \code{\link{export_sklearn_model}} writes, as verified by the parity tests in
#' proximetricsr-estimators (\code{tests/test_r_export_parity.py}). Recorded in
#' the exported file's \code{domain_version}/\code{packages} so openmodels warns
#' when the loading environment differs. Update together with those tests.
#' @keywords internal
.sklearn_export_targets <- c(
  sklearn = "1.9.1",
  chemotools = "0.4.4",
  proximetricsr_estimators = "0.1.0"
)

#' @title Translate one proximetricsR preprocessing step to a chemotools estimator dict
#' @description internal function used by \code{\link{export_sklearn_model}}
#' @param step an object of class \code{preprocessing}, one entry of
#' \code{object$preprocess$steps}.
#' @param x_axis_in numeric vector of the wavelength/wavenumber grid entering this
#' step (\code{object$processed_wavs[[paste0("step_", i - 1)]]}), used only by
#' steps whose chemotools equivalent needs an explicit x-axis (currently
#' \code{prep_wav_trim}).
#' @param x_axis_out numeric vector of the grid R recorded *leaving* this step
#' (\code{object$processed_wavs[[paste0("step_", i)]]}), used by
#' \code{prep_wav_trim} to reproduce R's own cut exactly.
#' @return A list with \code{estimator_class} and \code{params} (and, where
#' relevant, \code{param_types}/\code{param_dtypes}) describing the equivalent
#' chemotools transformer.
#' @note Any branch that sets \code{attributes} must also set
#' \code{attribute_types}: openmodels indexes \code{data["attribute_types"]}
#' directly (not via \code{.get()}) once \code{attributes} is present, so a
#' missing one is a \code{KeyError} at load time. Every other block is optional
#' -- the deserializer defaults it to an empty dict -- so blocks that would be
#' empty are simply left out.
#' @keywords internal
.translate_prep_step <- function(step, x_axis_in, x_axis_out) {
  n_features_in <- length(x_axis_in)

  switch(step$method,
    prep_snv = list(
      estimator_class = "StandardNormalVariate",
      params = .empty_obj(),
      # StandardNormalVariate.fit() sets no fitted state beyond n_features_in_
      # (mean/std are computed per-row at transform time, not stored).
      attributes = list(n_features_in_ = n_features_in),
      attribute_types = list(n_features_in_ = "int")
    ),
    prep_derivative = {
      if (identical(step$algorithm, "nwp")) {
        stop(
          "export_sklearn_model() does not support prep_derivative(algorithm = \"nwp\") ",
          "(no chemotools equivalent)."
        )
      } else if (identical(step$algorithm, "savitzky-golay")) {
        # SavitzkyGolay.fit() only mirrors window_length/polyorder/deriv into
        # window_length_/polyorder_/deriv_ (no other computed state) + n_features_in_.
        list(
          estimator_class = "SavitzkyGolay",
          # `mode` is pinned to chemotools' own default rather than left implicit,
          # so the export keeps reproducing R if that default ever changes. R
          # trims the edge points this padding produces (see the RangeCut that
          # export_sklearn_model() appends), so the mode never affects results.
          params = list(
            window_length = as.integer(step$w), polyorder = as.integer(step$p),
            deriv = as.integer(step$m), mode = "nearest"
          ),
          param_types = list(
            window_length = "int", polyorder = "int", deriv = "int", mode = "str"
          ),
          attributes = list(
            window_length_ = step$w, polyorder_ = step$p, deriv_ = step$m,
            n_features_in_ = n_features_in
          ),
          attribute_types = list(
            window_length_ = "int", polyorder_ = "int", deriv_ = "int",
            n_features_in_ = "int"
          )
        )
      } else if (identical(step$algorithm, "gap-segment")) {
        # Not yet supported: chemotools.derivative.NorrisWilliams precomputes a
        # kernel_ (a convolution of an internal smoothing kernel and a derivative
        # kernel, see NorrisWilliams.fit()) that isn't just its constructor params
        # mirrored with a trailing underscore -- unlike every other step mapped
        # here, replicating it correctly needs verification against chemotools'
        # exact internal kernel formulas that hasn't been done yet.
        stop(
          "export_sklearn_model() does not yet support ",
          "prep_derivative(algorithm = \"gap-segment\") (its chemotools equivalent, ",
          "NorrisWilliams, precomputes an internal kernel not yet replicated here)."
        )
      } else {
        stop("Unsupported prep_derivative algorithm '", step$algorithm, "'.")
      }
    },
    prep_smooth = {
      if (identical(step$algorithm, "savitzky-golay")) {
        # chemotools.smooth.SavitzkyGolayFilter precomputes a convolution kernel via
        # scipy.signal.savgol_coeffs(window_length, polyorder, deriv=0, use="conv"),
        # rather than calling scipy's savgol_filter at transform time. We reuse the
        # existing sgf() helper (see proxiscout_write_model.R, which already emits
        # Savitzky-Golay coefficients for the ProxiScout device JSON format), which
        # implements the same standard pseudo-inverse-of-Vandermonde-matrix formula.
        # Cross-checked numerically (transliterating sgf() to Python/numpy and
        # comparing against scipy.signal.savgol_coeffs(..., use="conv") for several
        # (window, polyorder) pairs): the m=0 (smoothing) coefficient vector is
        # symmetric, so it is identical to its own reversal and matches scipy's
        # "conv" kernel exactly -- unlike derivative orders (m>0), there is no
        # conv-vs-dot ordering ambiguity to get wrong for this particular mapping.
        # The rev() call below is therefore a no-op for m=0, kept only so this
        # matches the general pattern (and would be needed if this were ever
        # extended to export a nonzero-derivative smoothing kernel).
        kernel <- rev(as.vector(sgf(p = step$p, n = step$w, m = 0)))
        list(
          estimator_class = "SavitzkyGolayFilter",
          params = list(
            window_length = as.integer(step$w), polyorder = as.integer(step$p)
          ),
          param_types = list(window_length = "int", polyorder = "int"),
          attributes = list(
            window_length_ = step$w,
            polyorder_ = step$p,
            kernel_ = kernel,
            # _half_ = (window_length_-1)%/%2 is a *private* attribute
            # chemotools._BaseFIRFilter.transform() reads directly at transform
            # time (chemotools/smooth/_base.py::_apply_filter_1d). openmodels'
            # own attribute extraction skips leading-underscore attributes, so a
            # plain Python-native round trip of a real SavitzkyGolayFilter would
            # actually drop this too -- it only works here because we set it
            # directly, bypassing that extraction step.
            `_half_` = (step$w - 1L) %/% 2L,
            n_features_in_ = n_features_in
          ),
          attribute_types = list(
            window_length_ = "int", polyorder_ = "int",
            kernel_ = "ndarray", `_half_` = "int", n_features_in_ = "int"
          ),
          attribute_dtypes = list(kernel_ = "float64")
        )
      } else if (identical(step$algorithm, "moving-average")) {
        # MeanFilter.fit() only mirrors window_length into window_length_ (the mean
        # is computed at transform time via scipy's uniform_filter1d) + n_features_in_.
        list(
          estimator_class = "MeanFilter",
          params = list(window_length = as.integer(step$w)),
          param_types = list(window_length = "int"),
          attributes = list(window_length_ = step$w, n_features_in_ = n_features_in),
          attribute_types = list(window_length_ = "int", n_features_in_ = "int")
        )
      } else {
        stop("Unsupported prep_smooth algorithm '", step$algorithm, "'.")
      }
    },
    prep_detrend = list(
      estimator_class = "PolynomialCorrection",
      params = list(order = as.integer(step$p), indices = NULL),
      param_types = list(order = "int", indices = "NoneType"),
      # indices = NULL fits the polynomial to every point (matching prospectr::
      # detrend's whole-spectrum behaviour), i.e. indices_ = 0:(n_features_in_-1)
      # (0-based, matching PolynomialCorrection.fit()'s own `list(range(0, len(X[0])))`).
      attributes = list(
        indices_ = seq(0L, n_features_in - 1L),
        n_features_in_ = n_features_in
      ),
      attribute_types = list(indices_ = "ndarray", n_features_in_ = "int"),
      attribute_dtypes = list(indices_ = "int32")
    ),
    prep_transform = {
      if (!identical(step$to, "absorbance")) {
        stop(
          "export_sklearn_model() only supports prep_transform(to = \"absorbance\"); ",
          "'to = \"reflectance\"' has no supported chemotools export path (mirrors ",
          "proxiscout_write_model()'s existing behaviour)."
        )
      }
      # proximetricsR's "absorbance" here is A = -log10(R) computed directly from
      # reflectance: chemotools calls this conversion pair "pseudoabsorbance"
      # (reflectance-based), distinct from its "absorbance"/"transmittance" pair
      # (Beer-Lambert, transmittance-based) -- see export_sklearn_model()'s details.
      # IntensityConversion.fit() sets no fitted state beyond n_features_in_.
      list(
        estimator_class = "IntensityConversion",
        params = list(input_unit = "reflectance", output_unit = "pseudoabsorbance"),
        param_types = list(input_unit = "str", output_unit = "str"),
        attributes = list(n_features_in_ = n_features_in),
        attribute_types = list(n_features_in_ = "int")
      )
    },
    prep_wav_trim = {
      if (isTRUE(step$trim_constant_edges)) {
        stop(
          "export_sklearn_model() does not support ",
          "prep_wav_trim(trim_constant_edges = TRUE) (data-dependent, no chemotools ",
          "equivalent)."
        )
      }
      if (length(step$band) == 0) {
        stop("export_sklearn_model() requires a non-empty 'band' in prep_wav_trim().")
      }
      # The cut is derived from R's own recorded output grid rather than from a
      # nearest-value lookup of `band`. proximetricsR keeps the wavelengths that
      # fall *inside* the band, while chemotools' RangeCut resolves start/end to
      # their nearest grid points and slices half-open -- for a band edge lying
      # between two grid points the two rules disagree by one feature, in either
      # direction. Replicating R's indices directly removes that whole class.
      .make_range_cut(x_axis_in, x_axis_out, start = min(step$band), end = max(step$band))
    },
    prep_resample = stop(
      "export_sklearn_model() does not support prep_resample(): its chemotools ",
      "equivalent (XAxisInterpolator) requires scikit-learn metadata routing at ",
      "predict time (the incoming spectra's x-axis must be passed explicitly to ",
      "every predict() call), unlike every other step here, so it is not usable in ",
      "a plain Pipeline.predict(X) workflow."
    ),
    stop("Unsupported preprocessing step '", step$method, "' for export_sklearn_model().")
  )
}

#' @title Build a RangeCut step reproducing a narrowing preprocessing step
#' @description internal function used by \code{\link{export_sklearn_model}} to
#' re-create, in the exported Pipeline, the edge trimming proximetricsR's
#' moving-window filters apply but their length-preserving chemotools
#' counterparts do not.
#' @param x_axis_in numeric vector, the grid entering the filter step.
#' @param x_axis_out numeric vector, the (narrower, contiguous) grid R recorded
#' leaving that step.
#' @param start,end optional provenance values for the emitted \code{RangeCut}'s
#' constructor parameters (\code{prep_wav_trim()}'s requested band). The cut
#' itself always comes from \code{x_axis_out}; these are not used to resolve it.
#' Default to the endpoints of \code{x_axis_out}.
#' @return A list with \code{estimator_class}, \code{params} and
#' \code{attributes} describing an equivalent \code{chemotools} \code{RangeCut}.
#' @keywords internal
.make_range_cut <- function(x_axis_in, x_axis_out, start = NULL, end = NULL) {
  n_out <- length(x_axis_out)
  if (is.null(start)) start <- x_axis_out[1]
  if (is.null(end)) end <- x_axis_out[n_out]
  # Indices are derived from R's own recorded output grid rather than left to
  # RangeCut.fit()'s nearest-value lookup, so the exported cut is exact.
  start_index <- which.min(abs(x_axis_in - x_axis_out[1])) - 1L
  end_index <- start_index + n_out # Python half-open slice
  selected_axis <- x_axis_in[(start_index + 1L):end_index]
  list(
    estimator_class = "RangeCut",
    params = list(start = start, end = end, x_axis = x_axis_in),
    param_types = list(start = "float", end = "float", x_axis = "ndarray"),
    param_dtypes = list(x_axis = "float64"),
    attributes = list(
      start_index_ = start_index,
      end_index_ = end_index,
      x_axis_ = selected_axis,
      wavenumbers_ = selected_axis,
      n_features_in_ = length(x_axis_in)
    ),
    attribute_types = list(
      start_index_ = "int", end_index_ = "int",
      x_axis_ = "ndarray", wavenumbers_ = "ndarray", n_features_in_ = "int"
    ),
    attribute_dtypes = list(x_axis_ = "float64", wavenumbers_ = "float64")
  )
}

#' @title An empty JSON object
#' @description internal helper. \code{jsonlite::toJSON()} encodes an unnamed
#' \code{list()} as \code{"[]"}, but openmodels' format expects a JSON object
#' (\code{"{}"}) everywhere one of its bookkeeping dicts is empty.
#' @return A zero-length named list.
#' @keywords internal
.empty_obj <- function() stats::setNames(list(), character(0))

