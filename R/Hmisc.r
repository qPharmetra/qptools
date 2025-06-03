# When Hmisc is imported by qptools, the Hmisc namespace
# gets loaded but not attached.
# This makes Hmisc::print.latex available unintentionally.
# as a workaround, we define the two used functions here.
# from Hmisc_5.1-0.

unPaste <- 
function (str, sep = "/") 
{
   w <- strsplit(str, sep)
   w <- matrix(unlist(w), ncol = length(str))
   nr <- nrow(w)
   ans <- vector("list", nr)
   for (j in 1:nr) ans[[j]] <- w[j, ]
   ans
}

# similar to whichClosest.  See find_diag_template.r
# return index of minimum value
whichClosestToZero <- 
function (x) 
{
   stopifnot(all(x >= 0))
   match(min(x), x)
}