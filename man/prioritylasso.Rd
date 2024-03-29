% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prioritylasso.R
\name{prioritylasso}
\alias{prioritylasso}
\title{Patient outcome prediction based on multi-omics data taking practitioners' preferences into account}
\usage{
prioritylasso(
  X,
  Y,
  weights,
  family = c("gaussian", "binomial", "cox"),
  type.measure,
  blocks,
  max.coef = NULL,
  block1.penalization = TRUE,
  lambda.type = "lambda.min",
  standardize = TRUE,
  nfolds = 10,
  foldid,
  cvoffset = FALSE,
  cvoffsetnfolds = 10,
  mcontrol = missing.control(),
  scale.y = FALSE,
  return.x = TRUE,
  ...
)
}
\arguments{
\item{X}{a (nxp) matrix of predictors with observations in rows and predictors in columns.}

\item{Y}{n-vector giving the value of the response (either continuous, numeric-binary 0/1, or \code{Surv} object).}

\item{weights}{observation weights. Default is 1 for each observation.}

\item{family}{should be "gaussian" for continuous \code{Y}, "binomial" for binary \code{Y}, "cox" for \code{Y} of type \code{Surv}.}

\item{type.measure}{accuracy/error measure computed in cross-validation. It should be "class" (classification error) or "auc" (area under the ROC curve) if \code{family="binomial"}, "mse" (mean squared error) if \code{family="gaussian"} and "deviance" if \code{family="cox"} which uses the partial-likelihood.}

\item{blocks}{list of the format \code{list(bp1=...,bp2=...,)}, where the dots should be replaced by the indices of the predictors included in this block. The blocks should form a partition of 1:p.}

\item{max.coef}{vector with integer values which specify the number of maximal coefficients for each block. The first entry is omitted if \code{block1.penalization = FALSE}. Default is \code{NULL}.}

\item{block1.penalization}{whether the first block should be penalized. Default is TRUE.}

\item{lambda.type}{specifies the value of lambda used for the predictions. \code{lambda.min} gives lambda with minimum cross-validated errors. \code{lambda.1se} gives the largest value of lambda such that the error is within 1 standard error of the minimum. Note that \code{lambda.1se} can only be chosen without restrictions of \code{max.coef}.}

\item{standardize}{logical, whether the predictors should be standardized or not. Default is TRUE.}

\item{nfolds}{the number of CV procedure folds.}

\item{foldid}{an optional vector of values between 1 and nfold identifying what fold each observation is in.}

\item{cvoffset}{logical, whether CV should be used to estimate the offsets. Default is FALSE.}

\item{cvoffsetnfolds}{the number of folds in the CV procedure that is performed to estimate the offsets. Default is 10. Only relevant if \code{cvoffset=TRUE}.}

\item{mcontrol}{controls how to deal with blockwise missing data. For details see below or \code{\link[prioritylasso]{missing.control}}.}

\item{scale.y}{determines if y gets scaled before passed to glmnet. Can only be used for \code{family = 'gaussian'}.}

\item{return.x}{logical, determines if the input data should be returned by \code{prioritylasso}. Default is \code{TRUE}.}

\item{...}{other arguments that can be passed to the function \code{cv.glmnet}.}
}
\value{
object of class \code{prioritylasso} with the following elements. If these elements are lists, they contain the results for each penalized block.
\describe{
\item{\code{lambda.ind}}{list with indices of lambda for \code{lambda.type}.}
\item{\code{lambda.type}}{type of lambda which is used for the predictions.}
\item{\code{lambda.min}}{list with values of lambda for \code{lambda.type}.}
\item{\code{min.cvm}}{list with the mean cross-validated errors for \code{lambda.type}.}
\item{\code{nzero}}{list with numbers of non-zero coefficients for \code{lambda.type}.}
\item{\code{glmnet.fit}}{list of fitted \code{glmnet} objects.}
\item{\code{name}}{a text string indicating type of measure.}
\item{\code{block1unpen}}{if \code{block1.penalization = FALSE}, the results of either the fitted \code{glm} or \code{coxph} object corresponding to \code{best.blocks}.}
\item{\code{coefficients}}{vector of estimated coefficients. If \code{block1.penalization = FALSE} and \code{family = gaussian} or \code{binomial}, the first entry contains an intercept.}
\item{\code{call}}{the function call.}
\item{\code{X}}{the original data used for the calculation or \code{NA} if \code{return.x = FALSE}}
\item{\code{missing.data}}{list with logical entries for every block which observation is missing (\code{TRUE} means missing)}
\item{\code{imputation.models}}{if \code{handle.missingdata = "impute.offsets"}, it contains the used imputation models}
\item{\code{blocks.used.for.imputation}}{if \code{handle.missingdata = "impute.offsets"}, it contains the blocks which were used for the imputation model for every block}
\item{\code{y.scale.param}}{if \code{scale.y = TRUE}, then it contains the mean and sd used for scaling.}
\item{\code{blocks}}{list with the description which variables belong to which block}
\item{\code{mcontrol}}{the missing control settings used}
\item{\code{family}}{the family of the fitted data}
\item{\code{dim.x}}{the dimension of the used training data}
}
}
\description{
Fits successive Lasso models for several ordered blocks of (omics) data and takes the predicted values as an offset for the next block.
}
\details{
For \code{block1.penalization = TRUE}, the function fits a Lasso model for each block. First, a standard Lasso for the first entry of \code{blocks} (block of priority 1) is fitted.
The predictions are then taken as an offset in the Lasso fit of the block of priority 2, etc.
For \code{block1.penalization = FALSE}, the function fits a model without penalty to the block of priority 1 (recommended as a block with clinical predictors where \code{p < n}).
This is either a generalized linear model for family "gaussian" or "binomial", or a Cox model. The predicted values are then taken as an offset in the following Lasso fit of the block with priority 2, etc. \cr

The first entry of \code{blocks} contains the indices of variables of the block with priority 1 (first block included in the model).
Assume that \code{blocks = list(1:100, 101:200, 201:300)} then the block with priority 1 consists of the first 100 variables of the data matrix.
Analogously, the block with priority 2 consists of the variables 101 to 200 and the block with priority 3 of the variables 201 to 300.

\code{standardize = TRUE} leads to a standardisation of the covariables (\code{X}) in \code{glmnet} which is recommend by \code{glmnet}.
In case of an unpenalized first block, the covariables for the first block are not standardized.
Please note that the returned coefficients are rescaled to the original scale of the covariates as provided in \code{X}.
Therefore, new data in \code{predict.prioritylasso} should be on the same scale as \code{X}.

To use the method with blockwise missing data, one can set \code{handle.missingdata = ignore}.
Then, to calculate the coefficients for a given block only the observations with values for this blocks are used.
For the observations with missing values, the result from the previous block is used as the offset for the next block.
Crossvalidated offsets are not supported with \code{handle.missingdata = ignore}.
Please note that dealing with single missing values is not supported.
Normally, every observation gets a unique foldid which stays the same across all blocks for the call to \code{cv.glmnet}.
However when \code{handle.missingdata != none}, the foldid is set new for every block.
}
\note{
The function description and the first example are based on the R package \code{ipflasso}. The second example is inspired by the example of \code{\link[glmnet]{cv.glmnet}} from the \code{glmnet} package.
}
\examples{
# gaussian
  prioritylasso(X = matrix(rnorm(50*500),50,500), Y = rnorm(50), family = "gaussian",
                type.measure = "mse", blocks = list(bp1=1:75, bp2=76:200, bp3=201:500),
                max.coef = c(Inf,8,5), block1.penalization = TRUE,
                lambda.type = "lambda.min", standardize = TRUE, nfolds = 5, cvoffset = FALSE)
\dontrun{
  # cox
  # simulation of survival data:
  n <- 50;p <- 300
  nzc <- trunc(p/10)
  x <- matrix(rnorm(n*p), n, p)
  beta <- rnorm(nzc)
  fx <- x[, seq(nzc)]\%*\%beta/3
  hx <- exp(fx)
  # survival times:
  ty <- rexp(n,hx)
  # censoring indicator:
  tcens <- rbinom(n = n,prob = .3,size = 1)
  library(survival)
  y <- Surv(ty, 1-tcens)
  blocks <- list(bp1=1:20, bp2=21:200, bp3=201:300)
  # run prioritylasso:
  prioritylasso(x, y, family = "cox", type.measure = "deviance", blocks = blocks,
                block1.penalization = TRUE, lambda.type = "lambda.min", standardize = TRUE,
                nfolds = 5)

  # binomial
  # using pl_data:
  prioritylasso(X = pl_data[,1:1028], Y = pl_data[,1029], family = "binomial", type.measure = "auc",
                blocks = list(bp1=1:4, bp2=5:9, bp3=10:28, bp4=29:1028), standardize = FALSE)}

}
\references{
Klau, S., Jurinovic, V., Hornung, R., Herold, T., Boulesteix, A.-L. (2018). Priority-Lasso: a simple hierarchical approach to the prediction of clinical outcome using multi-omics data. BMC Bioinformatics 19, 322
}
\seealso{
\code{\link[prioritylasso]{pl_data}}, \code{\link[prioritylasso]{cvm_prioritylasso}}, \code{\link[ipflasso]{cvr.ipflasso}}, \code{\link[ipflasso]{cvr2.ipflasso}}, \code{\link[prioritylasso]{missing.control}}
}
\author{
Simon Klau, Roman Hornung, Alina Bauer \cr
Maintainer: Roman Hornung (\email{hornung@ibe.med.uni-muenchen.de})
}
