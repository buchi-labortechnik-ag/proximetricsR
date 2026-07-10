#include <RcppArmadillo.h> 
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;

//' @title Computes the weights for pls regressions
//' @description
//' This is an internal function that computes the wights required for obtaining
//' each vector of pls weights. Implementation is done in C++ for improved performance.
//' @param X a numeric matrix of spectral data.
//' @param Y a matrix of one column with the response variable.
//' @param algorithm a string indicating what method to use. All available options
//' are: \code{'pls_modified'} (default), \code{'pls_standard'}, \code{'pls_nwp'},
//' \code{'xls_modified'}, \code{'xls_standard'}, and \code{'xls_nwp'}.
//' In particular, you can either select partial least squares (pls) or extended
//' partial least squares, with either modified weights (using correlation),
//' standard weights (using covariance) or nwp (i.e. as implemented in NIRWise PLUS software).
//' The NIRWise PLUS implementation calculates the weights also via correlation,
//' but also adjusts the weights and scores according to a slope correction.
//' @param xls_min_w an integer indicating the minimum window size for the "xls"
//' method. Only used if \code{algorithm} contains \code{'xls'}. Default is 3.
//' @param xls_max_w an integer indicating the maximum window size for the "xls"
//' method. Only used if \code{algorithm} contains \code{'xls'}. Default is 15.
//' @author Leonardo Ramirez-Lopez and Claudio Orellano
//' @return a `matrix` of one column containing the weights.
//' @useDynLib proximetricsR
//' @noRd
//' @keywords internal
// [[Rcpp::export]]
arma::mat get_pls_weights(arma::mat X, arma::mat Y, String algorithm = "pls_modified", const int xls_min_w = 3, const int xls_max_w = 15) {
  int n_cols_x = X.n_cols;
  arma::mat w = arma::zeros<arma::mat>(1, n_cols_x);
  if ((algorithm == "pls_modified") || (algorithm == "pls_nwp")) {
    for (int i = 0; i < n_cols_x; i++) {
      w(0,i) = arma::as_scalar(arma::cor(Y, X.col(i)));
    }
  }
  if (algorithm == "pls_standard") {
    w = arma::normalise(trans(Y) * X, 2, 1);
    //w /= arma::norm(w, 2);//arma::conv_to<double>::from(arma::sqrt(w * trans(w)));
  }
  
  if ((algorithm == "xls_modified") || (algorithm == "xls_nwp")) {
    for (int i = 0; i < n_cols_x; i++) {
      for (int j = i + xls_min_w; j <= std::min(i + xls_max_w, n_cols_x - 1); j++) {
        double corr_val = arma::as_scalar(arma::cor(Y, X.col(i) - X.col(j)));
        w(0, i) += corr_val;
        w(0, j) -= corr_val;
      }
    }
  }
  if (algorithm == "xls_standard") {
    for (int i = 0; i < n_cols_x; i++) {
      for (int j = i + xls_min_w; j <= std::min(i + xls_max_w, n_cols_x - 1); j++) {
        double corr_val = arma::as_scalar(arma::cov(Y, X.col(i) - X.col(j)));
        w(0,i) += corr_val;
        w(0,j) -= corr_val;
      }
    }
    w = arma::normalise(w, 2, 1);
  }
  
  return (w);
}

//' @title Fast regression method computation
//' @description This function computes the basic elements of a partial least squares (pls)
//' regression model for either the partial least squares or the extended partial
//' least squares methods, where each regression method has three subtypes:
//' \code{"modified"}, \code{"standard"} and \code{"nwp"}. For more details on
//' these types, see \code{\link{fit_constructors}}.
//'
//' The least amount of data is saved to compute predictions, which makes this
//' function optimal to use during cross-validation evalutations.
//' @usage
//' estimate_basic_pls(X, Y, method)
//' @param X a numeric matrix of spectral data.
//' @param Y a matrix of one column with the response variable.
//' @param method a list of class \code{fit_constructor} specifying the fit method,
//' as specified with the \code{\link{fit_constructors}} functions.
//' @return a list with the following elements:
//' \itemize{
//'         \item{\code{coefficients}:} { The matrix of regression coefficients.
//'         Can be used to predict reference values for new spectral observations.}
//'         \item{\code{intercept}:} { The intercept of the models. Note that it
//'         is constant for all components and defined by the mean of input
//'         \code{Y}.}
//'         \item{\code{x_means}:} { The mean of each column of input \code{X}.}
//'         }
//' @details
//' Computes one of "pls" and "xls" regression model for the given \code{method}.
//' @seealso \code{\link{fit_constructors}}, \code{\link{calibrate}}
//' @author Leonardo Ramirez-Lopez and Claudio Orellano
//' @useDynLib proximetricsR
//' @noRd
//' @keywords internal
// [[Rcpp::export]]
List estimate_basic_pls(arma::mat X, arma::mat Y, List method) {
  
  arma::mat y_original = Y;
  double y_mean = arma::mean(arma::mean(Y));
  Y = Y - y_mean;
  arma::mat x_means = arma::mean(X, 0);
  X = X - arma::repmat(x_means, X.n_rows, 1);
  
  int ncomp = method["ncomp"];
  
  arma::mat weights (ncomp, X.n_cols);
  arma::mat x_loadings (ncomp, X.n_cols);
  arma::mat scores (X.n_rows, ncomp);
  arma::vec y_loadings (ncomp);
  arma::mat X_expl;
  std::string fit_m = as<std::string>(method["fit_method"]);
  fit_m = fit_m.substr(0, fit_m.size() - 1);
  String mm = String(fit_m + "_" + as<std::string>(method["type"]));
  int min_w_val = method.containsElementNamed("min_w") ? (int)method["min_w"] : 3;
  int max_w_val = method.containsElementNamed("max_w") ? (int)method["max_w"] : 15;
  for (int i = 0; i < ncomp; i++) {
    weights.row(i) = get_pls_weights(X, Y, mm, min_w_val, max_w_val);
    scores.col(i) = X * trans(weights.row(i));

    double scores_sds = dot(scores.col(i), scores.col(i));

    y_loadings(i) = dot(Y, scores.col(i)) / scores_sds;
    
    // if ((mm == "pls_nwp") | (mm == "xls_nwp")) {
    //   // Slope correction
    //   weights.row(i) *= y_loadings(i);
    //   scores.col(i) *= y_loadings(i);
    //   scores.col(i) -= arma::mean(Y - scores.col(i));
    //   scores_sds = dot(scores.col(i), scores.col(i));
    // }
    x_loadings.row(i) = trans(scores.col(i)) * X / scores_sds;
    X_expl = scores.col(i) * x_loadings.row(i);
    
    X = X - X_expl;
  }
  arma::mat regression_coefs = arma::inv(weights * trans(x_loadings)) * weights;
  // if ((mm == "pls_nwp") | (mm == "xls_nwp")) {
  //   regression_coefs = cumsum(regression_coefs, 1);
  // } else {
  //   
  // }
  regression_coefs = cumsum(regression_coefs.each_col() % y_loadings, 0);
  Rcpp::List return_list;
  return_list = Rcpp::List::create(
    Rcpp::Named("coefficients") = regression_coefs,
    Rcpp::Named("intercept") = y_mean,
    Rcpp::Named("x_means") = x_means
  );
  return return_list;
}


//' @title Compute all information of a given regression method.
//' @description This function computes all important information related to a
//' partial least squares (pls) or an extended partial least squares (xls)
//' regression model. Each regression method has three subtypes:
//' \code{"modified"}, \code{"standard"} and \code{"nwp"}. For more details on
//' these types, see \code{\link{fit_constructors}}.
//' @usage
//' estimate_all_pls(X, Y, method)
//' @param X a numeric matrix of spectral data.
//' @param Y a matrix of one column with the response variable.
//' @param method a list of class \code{fit_constructor} specifying the regression method,
//' as specified with the \code{\link{fit_constructors}} functions.
//' @return a list with the following elements:
//' \itemize{
//'         \item{\code{intercept}:} { The intercept of the models. Note that it
//'         is constant for all components and defined by the mean of input
//'         \code{Y}.}
//'         \item{\code{x_means}:} { The mean of columns of input \code{X}.}
//'         \item{\code{projection_m}:} { The projection matrix. Can be used
//'         to project new spectral observations onto the score space.}
//'         \item{\code{coefficients}:} { The matrix of regression coefficients.
//'         These coefficients can be used to predict reference values from new
//'         spectral observations.}
//'         \item{\code{n_observations}:} {The number of observations used for regression.}
//'         \item{\code{x_residuals}:} { The spectral residuals obtained for each component.}
//'         \item{\code{weights}:} { The matrix of weights.}
//'         \item{\code{scores}:} { The matrix of scores.}
//'         \item{\code{sd_scores}:} { The matrix containing the standard deviations
//'         of each column of the scores.}
//'         \item{\code{scaled_scores}:} { The matrix of scaled scores.}
//'         \item{\code{y_loadings}:} { The matrix of loadings for Y.}
//'         \item{\code{x_loadings}:} { The matrix of loadings for X.}
//'         \item{\code{fitted_y}:} { The fitted values for the response variable.}
//'         \item{\code{cal_error}:} { The error statistics estimated for each component.}
//'         \item{\code{y_quantiles}:} { The quantiles of input \code{Y}.}
//'         \item{\code{explained_variance}:} { The variance of input \code{X}.}
//'         }
//' @details
//' Reproduces both, the "pls" and "xls" regression methods in BUCHI NIRWise PLUS.
//' @seealso \code{\link{fit_constructors}}, \code{\link{calibrate}}
//' @author Leonardo Ramirez-Lopez and Claudio Orellano
//' @useDynLib proximetricsR
//' @noRd
//' @keywords internal
// [[Rcpp::export]]
List estimate_all_pls(arma::mat X, arma::mat Y, List method) {
  
  arma::mat y_original = Y;
  double y_mean = arma::mean(arma::mean(Y));
  Y = Y - y_mean;
  arma::mat x_means = arma::mean(X, 0);
  X = X - arma::repmat(x_means, X.n_rows, 1);
  arma::mat x_original = X;
  
  int ncomp = method["ncomp"];
  
  arma::mat weights (ncomp, X.n_cols);
  arma::mat x_loadings (ncomp, X.n_cols);
  arma::mat scores (X.n_rows, ncomp);
  arma::mat x_residuals (X.n_rows, ncomp);
  arma::vec y_loadings (ncomp);
  arma::mat pls_expl_var (1, ncomp);
  arma::mat X_expl;
  std::string fit_m = as<std::string>(method["fit_method"]);
  fit_m = fit_m.substr(0, fit_m.size() - 1);
  String mm = String(fit_m + "_" + as<std::string>(method["type"]));
  int min_w_val = method.containsElementNamed("min_w") ? (int)method["min_w"] : 3;
  int max_w_val = method.containsElementNamed("max_w") ? (int)method["max_w"] : 15;
  for (int i = 0; i < ncomp; i++) {
    weights.row(i) = get_pls_weights(X, Y, mm, min_w_val, max_w_val);
    scores.col(i) = X * trans(weights.row(i));

    double scores_sds = dot(scores.col(i), scores.col(i));

    y_loadings(i) = dot(Y, scores.col(i)) / scores_sds;
    
    // if ((mm == "pls_nwp") | (mm == "xls_nwp")) {
    //   // Slope correction
    //   weights.row(i) *= y_loadings(i);
    //   scores.col(i) *= y_loadings(i);
    //   scores.col(i) -= arma::mean(Y - scores.col(i));
    //   scores_sds = dot(scores.col(i), scores.col(i));
    // }
    x_loadings.row(i) = trans(scores.col(i)) * X / scores_sds;
    X_expl = scores.col(i) * x_loadings.row(i);
    
    X = X - X_expl;
    x_residuals.col(i) = arma::sum(X % X, 1);
    pls_expl_var.col(i) = arma::sum(arma::var(X_expl, 0, 0));
  }
  
  arma::mat projection_m = arma::inv(weights * trans(x_loadings)) * weights;
  arma::mat regression_coefs = cumsum(projection_m.each_col() % y_loadings, 0);
  // if ((mm == "pls_nwp") | (mm == "xls_nwp")) {
  //   regression_coefs = cumsum(projection_m, 1);
  // } else {
  //   regression_coefs = cumsum(projection_m.each_row() % trans(y_loadings), 1);
  // }
  
  Rcpp::List return_list;
  arma::mat fitted_y = x_original * trans(regression_coefs) + y_mean;
  
  arma::mat max_residuals = arma::max(arma::abs(arma::repmat(y_original, 1, ncomp) - fitted_y), 0);
  arma::mat cal_set_error = sqrt(arma::sum(pow(arma::repmat(y_original, 1, ncomp) - fitted_y, 2), 0) / (fitted_y.n_rows - 1));
  arma::mat cal_error = arma::join_rows(arma::linspace(1, ncomp, ncomp), trans(cal_set_error), trans(max_residuals));
  
  arma::mat y_quantiles = trans(arma::quantile(y_original, arma::linspace(0, 1, 5)));
  
  if ((mm == "pls_nwp") || (mm == "xls_nwp")) {
    weights.each_col() %= y_loadings;
    scores.each_row() %= trans(y_loadings);
    x_loadings.each_col() /= y_loadings;
  }
  arma::mat sd_scores = arma::stddev(scores, 0, 0);
  arma::mat scaled_scores = scores.each_row() / sd_scores;
  
  double x_var = sum(arma::var(x_original, 0, 0));
  arma::mat x_variance = arma::join_cols(
    pls_expl_var,
    pls_expl_var / x_var,
    cumsum(pls_expl_var / x_var, 1)
  );
  arma::mat y_variance = pow(arma::cor(Y, fitted_y), 2);
  return_list = Rcpp::List::create(
    Rcpp::Named("intercept") = y_mean,
    Rcpp::Named("x_means") = x_means,
    Rcpp::Named("projection_m") = projection_m,
    Rcpp::Named("coefficients") = regression_coefs,
    Rcpp::Named("n_observations") = x_original.n_rows,
    Rcpp::Named("x_residuals") = x_residuals,
    Rcpp::Named("weights") = weights,
    Rcpp::Named("scores") = scores,
    Rcpp::Named("sd_scores") = sd_scores,
    Rcpp::Named("scaled_scores") = scaled_scores,
    Rcpp::Named("y_loadings") = y_loadings,
    Rcpp::Named("x_loadings") = x_loadings,
    Rcpp::Named("fitted_y") = fitted_y,
    Rcpp::Named("cal_error") = cal_error,
    Rcpp::Named("y_quantiles") = y_quantiles,
    Rcpp::Named("explained_variance") = Rcpp::List::create(
      Rcpp::Named("x_variance") = x_variance,
      Rcpp::Named("y_variance") = y_variance
    )
  );
  return return_list;
}
