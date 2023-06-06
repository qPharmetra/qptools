plot_tidyvpc_qp = function(vpc
                           , point.col=1
                           , point.shape=1
                           , point.size=0.75
                           , point.alpha=0.3
                           , medPI.col=qp.green
                           , PI.alpha = 0.25
                           , lsize=0.5
                           , scales = "free_y"
                           , add.rug = T
                           , rug.size = 0.5
                           , rug.sides = "t"
                           , yaml = file.path(nmDir, "../nm_pk_exparel.yaml")
                           , xLabel = "Time (hr)"
                           , yLabel = "Concentration (ng/nL)"
                           , plot.bin.method = "xpose"
                           , facet_ncol = 3
                           , ...) {
  ggplot(vpc$stats %>% 
           redecorate(yaml) %>% 
           ggready(parse=FALSE)
         , aes(x = xbin)) +
    xlab(xLabel) + 
    ylab(yLabel) +
    facet_wrap(vpc$strat.formula, scales=scales, ncol=facet_ncol) +
    geom_line(aes(y = md, col = qname, group = qname)) +     #median
    geom_line(aes(y = y, linetype = qname), size = lsize) +  #quantiles
    
    geom_rug(data = bininfo(vpc)[, .(x = sort(unique(c(xleft, xright)))),
                                 by = names(vpc$strat)] %>% 
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
    geom_point(data = vpc$obs %>% 
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
   geom_rect(data = vpc$stats %>% left_join(bininfo(vpc)) %>% 
               redecorate(yaml) %>% ggready(parse=FALSE)
              , aes(xmin = xleft, xmax = xright, ymin = lo, ymax = hi
                    , fill = qname, col = qname, group = qname)
              , alpha = PI.alpha*(plot.bin.method=="xpose"), col = NA) 
}
