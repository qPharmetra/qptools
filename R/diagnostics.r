#' Plot Something Isometrically
#' 
#' Plots something isometrically.
#' Generic, with method \code{\link{isoplot.data.frame}}.
#' @export
#' @keywords internal
#' @family plots
#' @param data object of dispatch
#' @param ... passed
isoplot <- function(data, ...) UseMethod('isoplot')

#' Plot Dataframe Isometrically
#' 
#' Plots 'data.frame' isometrically.
#' Constrains axes to be identical;
#' adds reference and trend lines.
#' Exposes alpha and transformation.

#' @export
#' @importFrom yamlet isometric
#' @import ggplot2
#' @keywords visualization
#' @family plots
#' @param data data.frame
#' @param x bareword for column mapped to x axis
#' @param y bareword for column mapped to y axis
#' @param alpha passed to \code{\link[ggplot2]{geom_point}}
#' @param transform passed to \code{\link[ggplot2]{scale_x_continuous}} and \code{\link[ggplot2]{scale_y_continuous}}
#' @param ... ignored
#' @return ggplot
#' @examples
#' library(magrittr)
#' library(yamlet)
#' x <- 'extdata/modeling/xanomeline-mod.csv.gz' %>% 
#' system.file(package = 'yamlet') %>% io_csv %>% filter(cp > 1) %>% resolve
#' x %>% isoplot(PRED, DV, transform = 'log10')
isoplot.data.frame <- function(
    data, 
    x, y, 
    ..., 
    alpha = 0.5, 
    transform = 'identity'
  ){
  p <- data %>%
    ggplot(aes(x = {{ x }}, y = {{ y }} )) +
    geom_abline(slope = 1, intercept = 0) +
    geom_point(alpha = alpha) + 
    geom_smooth(method = 'lm', formula = 'y ~ x') +
    theme_bw() +
    isometric() +
    scale_x_continuous(transform = transform) +
    scale_y_continuous(transform = transform) 
  p
}

#' Plot Two Isoplots
#' 
#' Plots two isoplots.
#' Generic, with method \code{\link{isopair.data.frame}}.
#' @export
#' @keywords internal
#' @family plots
#' @param data object of dispatch
#' @param ... passed
isopair <- function(data, ...) UseMethod('isopair')

#' Plot Two Isoplots for Data.frame
#' 
#' Plots two isoplots for 'data.frame', typically side-by-side.
#' @export
#' @importFrom metaplot multiplot
#' @importFrom rlang enquo quo_is_null
#' @keywords visualization
#' @family plots
#' @param data data.frame
#' @param x1 bareword for column mapped to x axis 1
#' @param y1 bareword for column mapped to y axis 1
#' @param x2 bareword for column mapped to x axis 2 (defaults to x1 internally)
#' @param y2 bareword for column mapped to y axis 2 (defaults to y1 internally)
#' @param alpha passed to \code{\link{isoplot}}, can be length 2
#' @param transform passed to \code{\link{isoplot}}, chan be length 2
#' @param ncol number of columns (1 or 2):  2 gives side-by-side layout
#' @param ... ignored
#' @return ggplot
#' @examples
#' library(magrittr)
#' library(yamlet)
#' x <- 'extdata/modeling/xanomeline-mod.csv.gz' %>% 
#' system.file(package = 'yamlet') %>% io_csv %>% filter(cp > 1) %>% resolve
#' x %>% isopair(PRED, DV, IPRED, DV)

isopair.data.frame <- function(
    data,
    x1, y1,
    x2 = NULL, y2 = NULL,
    ...,
    alpha = 0.5,
    transform = "identity",
    ncol = 2
){
  stopifnot(length(ncol) == 1, ncol %in% 1:2)
  alpha <- rep(alpha, 2)
  transform <- rep(transform, 2)
  
  x1q <- rlang::enquo(x1)
  y1q <- rlang::enquo(y1)
  
  x2q <- rlang::enquo(x2)
  y2q <- rlang::enquo(y2)
  
  if (rlang::quo_is_null(x2q)) x2q <- x1q
  if (rlang::quo_is_null(y2q)) y2q <- y1q
  
  multiplot(
    ncol = ncol,
    isoplot(data, !!x1q, !!y1q, alpha = alpha[[1]], transform = transform[[1]], ...),
    isoplot(data, !!x2q, !!y2q, alpha = alpha[[2]], transform = transform[[2]], ...)
  )
}

#' Plot a Trend
#' 
#' Plots a trend.
#' Generic, with method \code{\link{trendplot.data.frame}}.
#' @export
#' @keywords internal
#' @family plots
#' @param data object of dispatch
#' @param ... passed
trendplot <- function(data, ...) UseMethod('trendplot')

#' Plot a Trend for Dataframe
#' 
#' Plots a trend for 'data.frame'.
#' By default adds y-axis symmetry.
#' Adds reference and trend lines.
#' Exposes alpha and transformation.
#' @export
#' @importFrom yamlet symmetric
#' @keywords visualization
#' @family plots
#' @param data data.frame
#' @param x bareword for column mapped to x axis
#' @param y bareword for column mapped to y axis
#' @param alpha passed to \code{\link[ggplot2]{geom_point}}
#' @param transform_x passed to \code{\link[ggplot2]{scale_x_continuous}} 
#' @param transform_y passed to \code{\link[ggplot2]{scale_x_continuous}} 
#' @param ref passed to \code{\link[ggplot2]{geom_hline}} as \code{yintercept}
#' @param aspect passed to \code{\link[ggplot2]{theme}} as \code{aspect.ratio}
#' @param symmetric whether to enforce y-axis symmetry around zero, default if \code{transform = 'identity'}
#' @param ... ignored
#' @return ggplot
#' @examples
#' library(magrittr)
#' library(yamlet)
#' x <- 'extdata/modeling/xanomeline-mod.csv.gz' %>% 
#' system.file(package = 'yamlet') %>% io_csv %>% filter(cp > 1) %>% resolve
#' x %>% trendplot(TIME, IWRES, transform_x = 'log10')
#' 

trendplot.data.frame <- function(
    data, x, y,  
    ...,
    alpha = 0.5, 
    transform_x = 'identity',
    transform_y = 'identity',
    ref = 0,
    aspect = 1,
    symmetric = transform_y == 'identity'
){
  p <- data %>%
    ggplot(aes(x = {{ x }}, y = {{ y }} )) +
    geom_hline(yintercept = ref) +
    geom_point(alpha = alpha) + 
    theme_bw() +
    theme(aspect.ratio = aspect) +
    geom_smooth(method = 'lm', formula = 'y ~ x') 
  if(symmetric) p <- p + symmetric()
  p <- p +
    scale_x_continuous(transform = transform_x) +
    scale_y_continuous(transform = transform_y) 
  p
}

#' Plot Two Trendplots
#' 
#' Plots two trendplots.
#' Generic, with method \code{\link{trendpair.data.frame}}.
#' @export
#' @keywords internal
#' @family plots
#' @param data object of dispatch
#' @param ... passed
trendpair <- function(data, ...) UseMethod('trendpair')

#' Plot Two Trendplots for Data.frame
#' 
#' Plots two trendplots for 'data.frame', typically side-by-side.
#' @export
#' @keywords visualization
#' @family plots
#' @param data data.frame
#' @param x1 bareword for column mapped to x axis 1
#' @param y1 bareword for column mapped to y axis 1
#' @param x2 bareword for column mapped to x axis 2 (defaults to x1 internally)
#' @param y2 bareword for column mapped to y axis 2 (defaults to y1 internally)
#' @param alpha passed to \code{\link{isoplot}}, can be length 2
#' @param transform_x passed to \code{\link{trendplot}}, can be length 2
#' @param transform_y passed to \code{\link{trendplot}}, can be length 2
#' @param ref passed to \code{\link{trendplot}}, can be length 2
#' @param aspect passed to \code{\link{trendplot}}, can be length 2
#' @param ncol number of columns (1 or 2):  2 gives side-by-side layout
#' @param ... ignored
#' @return ggplot
#' @examples
#' library(magrittr)
#' library(yamlet)
#' x <- 'extdata/modeling/xanomeline-mod.csv.gz' %>% 
#' system.file(package = 'yamlet') %>% io_csv %>% filter(cp > 1) %>% resolve
#' x %>% trendpair(TIME, IWRES, TIME, IWRES, transform_x = c('identity', 'log10'))
trendpair.data.frame <- function(
    data, x1, y1,
    x2 = NULL, y2 = NULL,
    ...,
    alpha = 0.5, # can be length 2
    transform_x = "identity",
    transform_y = "identity",
    ref = 0,
    aspect = 1,
    ncol = 2
){
  stopifnot(length(ncol) == 1, ncol %in% 1:2)
  
  alpha <- rep(alpha, 2)
  transform_x <- rep(transform_x, 2)
  transform_y <- rep(transform_y, 2)
  ref <- rep(ref, 2)
  aspect <- rep(aspect, 2)
  
  # Capture user inputs
  x1q <- rlang::enquo(x1)
  y1q <- rlang::enquo(y1)
  x2q <- rlang::enquo(x2)
  y2q <- rlang::enquo(y2)
  
  # Default x2/y2 to x1/y1 if not provided
  if (rlang::quo_is_null(x2q)) x2q <- x1q
  if (rlang::quo_is_null(y2q)) y2q <- y1q
  
  multiplot(
    ncol = ncol,
    trendplot(
      data, !!x1q, !!y1q,
      alpha = alpha[[1]],
      transform_x = transform_x[[1]],
      transform_y = transform_y[[1]],
      aspect = aspect[[1]],
      ref = ref[[1]],
      ...
    ),
    trendplot(
      data, !!x2q, !!y2q,
      alpha = alpha[[2]],
      transform_x = transform_x[[2]],
      transform_y = transform_y[[2]],
      aspect = aspect[[2]],
      ref = ref[[2]],
      ...
    )
  )
}

