#' Identify the Color 'qp_blue'
#' 
#' Identifies the Color 'qp_blue'.
#' 
#' @export
#' @return character
#' @importFrom grDevices rgb
#' @examples 
#' qp_blue()
qp_blue <- function()rgb(20/255,74/255,144/255)

#' Identify the Color 'qp_green'
#' 
#' Identifies the Color 'qp_green'.
#' 
#' @export
#' @return character
#' @importFrom grDevices rgb
#' @examples 
#' qp_green()
qp_green <- function()rgb(76/255,181/255,79/255)

#' Identify qp_colors
#' 
#' Identifies qp_colors.
#' 
#' @export
#' @param n length-one integer for number of colors to return
#' @return character
#' @examples 
#' qp_colors
qp_colors <- function(n = 22L){
   stopifnot(is.numeric(n), length(n) == 1)
   n <- as.integer(n)
   stopifnot(n >= 1, n <= 22)
   x <- c(
      '#144A90', '#4CB54F', '#E51400', '#F0A30A', '#825A2C', '#0050EF', '#008A00',
      '#FA6800', '#6A00FF', '#60A917', '#1BA1E2', '#AA00FF', '#F472D0', '#647687',
      '#A20025', '#E3C800', '#00ABA9', '#6D8764', '#A4C400', '#D80073', '#76608A',
      '#87794E'
   )
   
   names(x) <- c( 
      'qp.blue', 'qp.green', 'ketchup', 'amber', 'brown','cobalt','emerald', 
      'orange',  'indigo',   'apple',   'cyan',  'violet','pink',   'steel',  
      'crimson', 'yellow',   'teal',    'olive', 'lime', 'magenta', 'mauve',  
      'taupe' 
   )
   x <- x[seq_len(n)]
   x
}
#' Identify sorted qp_colors
#' 
#' Identifies sorted qp_colors.
#' 
#' @export
#' @param n length-one integer for number of colors to return
#' @return character
#' @examples 
#' qp_colors
qp_colors_sorted <- function(n = 22L){
   stopifnot(is.numeric(n), length(n) == 1)
   n <- as.integer(n)
   stopifnot(n >= 1, n <= 22)
   x <- qp_colors(n = 22)[c(
      'lime', 'apple', 'qp.green', 'emerald', 'teal', 'cyan', 'cobalt', 
      'qp.blue', 'indigo', 'violet', 'pink', 'magenta', 'ketchup', 'crimson',
      'brown', 'orange', 'amber', 'yellow', 'olive', 'taupe', 'mauve', 
      'steel'
   )]

   x <- x[seq_len(n)]
   x
   
}
