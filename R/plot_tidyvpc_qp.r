globalVariables(c('xbin','md','qname','y','bininfo','xleft','xright','lo','hi','.'))
#' Convert to qP style VPC
#' 
#' Converts to qP-style VPC.
#' Generic, with method \code{\link{as_qpvpc.tidyvpcobj}}.
#' 
#' @export
#' @keywords internal
#' @family tidyvpc
#' @param x object of dispatch
#' @param ... passed
as_qpvpc <- function(x, ...)UseMethod('as_qpvpc')

#' Convert 'tidyvpcobj' to 'qpvpc'
#' 
#' Converts 'tidyvpcobj' to 'qpvpc'.
#' Simply supplies a new class (used for invoking custom print method).
#' 
#' @export
#' @family tidyvpc
#' @param x object of dispatch
#' @param ... passed
as_qpvpc.tidyvpcobj <- function(x, ...){
   class(x) <- union('qpvpc', class(x))
   x
}

#' Plot 'qpvpc'
#' 
#' Plots a tidy vpc using qP defaults.
#' 
#' @export
#' @family tidyvpc
#' @return ggplot
#' @param x 'qpvpc' (inherits 'tidyvpcobj')
#' @param point.col passed to geom_point()
#' @param point.shape passed to geom_point()
#' @param point.size passed to geom_point()
#' @param point.alpha passed to geom_point()
#' @param medPI.col passed to scale_fill_manual()
#' @param PI.alpha passed to geom_ribbon()
#' @param lsize passed to geom_line() for quantiles
#' @param scales  passed to facet_wrap()
#' @param add.rug passed to geom_rug()
#' @param rug.size passed to geom_rug()
#' @param rug.sides passed to geom_rug()
#' @param yaml passed to \code{\link[yamlet]{redecorate}} as 'meta'
#' @param xLabel passed to xlab()
#' @param yLabel passed to ylab()
#' @param plot.bin.method if "xpose", suppresses PI.alpha
#' @param facet_ncol passed to facet_wrap()
#' @param ... ignored
#' @import ggplot2
#' @import yamlet
#' @examples
#' \dontrun{
#' library(magrittr)
#' library(ggplot2)
#' x %>% as_qpvpc %>% plot
#' }
#' 

plot.qpvpc <- function(
   x
, point.col=1
, point.shape=1
, point.size=0.75
, point.alpha=0.3
, medPI.col="#4CB54F"
, PI.alpha = 0.25
, lsize=0.5
, scales = "free_y"
, add.rug = TRUE
, rug.size = 0.5
, rug.sides = "t"
, yaml = NULL
, xLabel = NULL
, yLabel = NULL
, plot.bin.method = "xpose"
, facet_ncol = NULL
, ...) {
  ggplot(x$stats %>% 
           redecorate(yaml) %>% 
           ggready(parse=FALSE)
         , aes(x = xbin)) +
    xlab(xLabel) + 
    ylab(yLabel) +
    facet_wrap(x$strat.formula, scales=scales, ncol=facet_ncol) +
    geom_line(aes(y = md, col = qname, group = qname)) +     #median
    geom_line(aes(y = y, linetype = qname), size = lsize) +  #quantiles
    
    geom_rug(data = bininfo(x)[, .(x = sort(unique(c(xleft, xright)))),
                                 by = names(x$strat)] %>% 
               redecorate(yaml) %>% 
               ggready(parse=FALSE)
             , aes(x = x), sides = rug.sides, size = rug.size, alpha = add.rug*1) +
    scale_colour_manual(name = "Simulated Percentiles",
                        breaks = c("q0.05", "q0.5", "q0.95"),
                        values = c("darkgrey", medPI.col, "darkgrey"),
                        labels = c("5%", "50%", "95%")) +
    scale_fill_manual(name = "Simulated Percentiles",
                      breaks = c("q0.05", "q0.5", "q0.95"),
                      values = c("gray60", medPI.col, "gray60"),
                      labels = c("5%", "50%", "95%")) +
    scale_linetype_manual(name = "Observed Percentiles",
                          breaks = c("q0.05", "q0.5", "q0.95"),
                          values = c("dashed", "solid", "dashed"),
                          labels = c("5%", "50%", "95%")) +
    geom_point(data = x$obs %>% 
                 redecorate(yaml) %>% 
                 ggready(parse=FALSE), aes(x = x, y = y)
               , shape=point.shape
               , color=point.col
               , size = point.size
               , alpha=point.alpha) + # observations
    guides(fill=guide_legend(order=2),
           colour=guide_legend(order=2),
           linetype=guide_legend(order=1)) +
    theme_bw() +
    theme(legend.position = "top") +
    geom_ribbon(aes(ymin = lo, ymax = hi, fill = qname, col = qname, group = qname)
                , alpha = PI.alpha*(plot.bin.method!="xpose"), col = NA) +
   geom_rect(data = x$stats %>% left_join(bininfo(x)) %>% 
               redecorate(yaml) %>% ggready(parse=FALSE)
              , aes(xmin = xleft, xmax = xright, ymin = lo, ymax = hi
                    , fill = qname, col = qname, group = qname)
              , alpha = PI.alpha*(plot.bin.method=="xpose"), col = NA) 
}
