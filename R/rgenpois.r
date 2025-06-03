
# ROXYGEN Documentation
#' Sample from Generalized Poisson distribution
#' @param lambda lambda of the Generalized Poisson distribution
#' @param disp dispersion of the Generalized Poisson distribution. Takes the value of 0 for a Poisson distribution, and becomes negative for under, and positive for over dispersed data.
#' @param n sample size
#' @param scan.size the upper limit of the distribution. This could be set higher but due to exponentation in the likelihood function shgould not exceed
#' @return n samples from the Generalized Poisson distribution (numeric non-negative integers)
#' @export
#' @importFrom stats runif
#' @family basic
#' @examples
#' genPois.samples = sapply(seq(0.3,-1.1,-0.2), function (DISP)
#' {
#'   rgenpois(n = 10000, lambda = 22, disp = DISP)
#' })
#'
#' # plot across dispersion
#' plot(range(genPois.samples), c(0,.25), type = "n", xlim = c(0,100), ylab = "Frequency")
#' for(i in 1 : ncol(genPois.samples)){
#'   gpDen = density(genPois.samples[,i], bw = 1)
#'   lines(gpDen)
#'   text(mean(genPois.samples[,i])
#'        , max(gpDen$y)+0.015
#'        , round(mean(genPois.samples[,i]),1)
#'        , cex = 0.5
#'   )
#' }
#' lines(density(rpois(10000, 11),bw = 1), col = "green", lwd = 3)
#' text(3, 0.03, round(mean(rpois(10000, 11)), 1), col = "green")


rgenpois <- function(lambda = lambda, disp = disp, n = 1, scan.size = 100)
{
  if(n<1){message("n must be a non-zero positive integer") ;return()}
  if(n>1 & {length(lambda)>1 | length(disp)>1}) {message("if multiple lambda and/or disp values are specified n can be only 1");return()}

  if(length(lambda) != length(disp))
  {
    if(min(c(length(lambda),length(disp)))>1) {message("if different lengths, either lambda or disp must have length 1"); return()}
    if(length(lambda) < length(disp)) lambda = rep(lambda, length(disp)) else disp = rep(disp, length(lambda))
  }
  if(n>1) {lambda = rep(lambda, n); disp = rep(disp,n)}

  ## scan.size should be 2-fold lambda

  ## start fresh
  R = runif(length(lambda))

  nnn = scan.size
  sq  = 0:nnn; SQ = sq[-1]
  LFAC = c(0, SQ*log(SQ)-SQ+log(SQ*(1+4*SQ*(1+2*SQ)))/6+log(3.1415)/2)
  LFAC[LFAC<0]=0
  LFAC = matrix(rep(LFAC,length(lambda)), ncol = length(lambda))
  mymat = matrix(0:nnn, ncol = length(lambda), nrow = nnn+1)
  xxx = matrix(rep(sq, length(lambda)), ncol = length(lambda))
  XXX = sweep(sweep(xxx, 2, disp, "*"), 2, lambda, "+")
  XXX[XXX<=0] = 0
  gp1 = sweep(XXX, 1, sq-1, "^")
  gp2 = sweep(gp1, 2, lambda,  "*")
  interim.disp = sweep(mymat,2,disp,"*")
  GP = gp2 * exp(-matrix(rep(lambda,ea = nnn+1), nrow = nnn+1, byrow = FALSE)-interim.disp)
  GP = GP / exp(LFAC)
  GP = apply(GP, 2, cumsum)
  GP = apply(sweep(GP, 2, R), 2, function(x) max(cumsum(x<0)))
  return(GP)
}




