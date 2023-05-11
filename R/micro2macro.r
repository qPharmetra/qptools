globalVariables(c(
   'CL','fracA', 'fracB', 'fracC', 'k10', 'k12', 'k13', 'k21', 'k31',
   'V1', 'V2', 'V3','alpha'
))
#' Convert Micro Parameters to Macro Parameters
#'
#' Conditionally converts a list of micro parameters to macro parameters
#' for up to 3 compartments. Recognizes V1, k10, k12, k21, k13, k31.
#' Returns CL, V1, and (conditionally) Q2, V2, Q3, and V3.
#'
#' @param ... named parameters V1, k10, and (conditionally) k12, k21, k13, k31
#' @param drop exclude micro parameters from the result
#' @return a list
#' @importFrom magrittr %<>%
#' @export
#' @examples
#'
#' library(pmxTools)
#' library(magrittr)
#' list(
#'     V1  =  c(2, 3),
#'     k10 = c(1.2, 1.3),
#'     k12 = c(12,   11),
#'     k21 = c(2.3, 2.4),
#'     k13 = c(3.2, 3.0),
#'     k31 = c(0.04, 0.05)
#'   ) %>%
#'   do.call(micro2macro, .) %>%
#'   do.call(calc_derived, .) %>%
#'   subset(lengths(.) != 0) %>%
#'   data.frame
#'
micro2macro <- function( ..., drop = TRUE ){
   args <- list(...)
   scale <- max(sapply(args, length))
   for(arg in names(args)){
      len <- length(arg)
      if(! len %in% c(1, scale))warning(
         'length of ', arg, 'not one of: 1 or ', scale
      )
      args[[arg]] <- rep(args[[arg]], length.out = scale)
   }
   stopifnot('V1' %in% names(args))
   stopifnot('k10' %in% names(args))

   args %<>% within(CL <- V1 * k10)

   if('k12' %in% names(args)){
      if(!'k21' %in% names(args)){
         warning('found k12 but not k21')
      }else{

         args %<>% within(Q2 <- V1 * k12)
         args %<>% within(V2 <- V1 * k12 / k21)
      }
   }
   if('k13' %in% names(args)){
      if(!'k31' %in% names(args)){
         warning('found k13 but not k31')
      }else{

         args %<>% within(Q3 <- V1 * k13)
         args %<>% within(V3 <- V1 * k13 / k31)
      }
   }
   if(drop){
      args$k10 <- NULL
      args$k12 <- NULL
      args$k21 <- NULL
      args$k13 <- NULL
      args$k31 <- NULL
   }
   args
}

#' Transform Micro Parameters
#'
#' Transforms PK micro parameters into compartmental parameters.
#' Designed as a table-friendly wrapper for micro2macro.  Tries to
#' calculate AUC = dose/CL, VSS = V1+V2+V3, and Vz = CL/gamma.
#'
#' @export
#' @param x data.frame with V1, k10, and optionally k12, k21, k13, k31
#' @param FUN a list-based function to transform micro parameters, e.g., pmxTools::calc_derived()
#' @param digits places of significance for numerics, or NULL for raw results
#' @param ... passed to FUN
#' @importFrom magrittr %<>%
#' @return data.frame
#'
#' @examples
#' set.seed(0)
#' x = data.frame(
#'  dose = 10,
#'  V1 = sample(4:10, size = 3, replace = TRUE),
#'  k10 = exp(rnorm(3, mean=log(0.79), sd=log(2))),
#'  k12 = exp(rnorm(3, mean=log(0.95), sd=log(2))),
#'  k13 = exp(rnorm(3, mean=log(0.005), sd=log(2))),
#'  k21 = exp(rnorm(3, mean=log(1.24), sd=log(2))),
#'  k31 = exp(rnorm(3, mean=log(0.036), sd=log(2)))
#' )
#'
#' library(pmxTools)
#' library(magrittr)
#' # 3 CMT
#' x %>%  transform_micro( calc_derived )
#' # 2 CMT
#' x %>% dplyr::select(-k13) %>% transform_micro( calc_derived )
#' # 1 CMT
#' x %>% dplyr::select(-k13, -k12) %>% transform_micro( calc_derived )
#'
transform_micro <- function(x, FUN, digits = 3, ...){
   x <- as.list(x)
   x <- do.call(micro2macro, x)
   args <- c(x, list(...))
   dose <- args$dose
   args$dose <- NULL
   # hotfix for pmxTools 1.0 bug
   names(args)[names(args) == 'Q2'] <- 'Q'
   y <- do.call(match.fun(FUN), args)
   y <- subset(y, lengths(y) != 0)
   y$dose <- dose
   y <- data.frame(y)
   if(! 'V1' %in% names(y)){
      warning('could not find V1')
   }else{
      y %<>%                        within(VSS <- V1)
      if('V2' %in% names(y)) y %<>% within(VSS <- VSS + V2)
      if('V3' %in% names(y)) y %<>% within(VSS <- VSS + V3)
   }
   if(! 'alpha' %in% names(y)){
      warning('could not find alpha')
   }else{
      y %<>%                           within(Vz <- CL/alpha)
      if('beta' %in% names(y)) y %<>%  within(Vz <- CL/beta)
      if('gamma' %in% names(y)) y %<>% within(Vz <- CL/gamma)
   }
   if('dose' %in% names(y)){
      y %<>% within(AUC <- dose/CL)
      if('fracA' %in% names(y))    y %<>% within(AUCalpha <- AUC * fracA)
      if('fracB' %in% names(y))    y %<>% within(AUCbeta  <- AUC * fracB)
      if('fracC' %in% names(y))    y %<>% within(AUCgamma <- AUC * fracC)
   }

   for(col in names(y)){
      if(is.numeric(y[[col]])){
         if(!is.null(digits)){
            y[[col]] <- signif(y[[col]], digits = digits)
         }
      }
   }
   y
}


