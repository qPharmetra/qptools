globalVariables(c('default.names','struct','struct.loc','bootlist','parlist','myBootDF','myMatch','myStructure'))

# ROXYGEN Documentation
#' Reads NONMEM bootstrap results for processing
#' 
#' @description Reads raw files files of a completed NONMEM bootstrap
#' @param directory Directory where bootstrap summary files reside
#' @param filename default Filename of the bootstrap results summary file created by PsN bootstrap
#' @param structure.filename Filename of structure file created by PsN bootstrap
#' @param parlist character string detailing what components of the bootstrap you want
#' @param quiet suppresses a message on how many bootstrap repliactes were read
#' @return A stuctured and named list with data frames with containing bootstrap results
#' @export
# @importFrom Hmisc unPaste
#' @importFrom utils read.csv
#' @examples
#' \dontrun{
#'   library(magrittr)
#'   boot_dir = getOption("nmDir") %>% file.path(., "bootstrap")
#'   fn_boot = "raw_results_run105bs.csv"
#'   bootstrap = read_bootstrap(boot_dir, filename = fn_boot)
#'   bootstrap$boot_base 
#'   bootstrap$boot_base %>% do.call("cbind",.) %>% hist()
#'   bootstrap$structure
#'   bootstrap$directory
#'   
#'   bootstrap %>% tabulate_bootstrap()
#' }
#'

read_bootstrap <- function(directory = getOption("nmDir"),
                           filename   = "raw_results1.csv",
                           structure.filename = "raw_results_structure",
                           parlist = c("theta", "omega","sigma","ofv"),
                           quiet=F
                           )
{
  default.names = c(
    "model",
    "minimization.successful",
    "covariance.step.successful",
    "covariance.step.warnings",
    "estimate.near.boundary"
  )
  
  ## check and read bootstrap raw results
  if(!file.exists(file.path(directory, filename))){
    message(file.path(directory,filename)," does not exist. Exiting");return()
  }
  bootstrap.data <- read.csv(file.path(directory, filename), header = TRUE)
  ## replace underscores, brackets and commas
  for (i in 1:length(names(bootstrap.data))) {
    names(bootstrap.data)[i] <-
      gsub("\\_", "\\.", names(bootstrap.data)[i])
  }
  
  ## read and process bootstrap structure file
  struct = scan(
    file = file.path(directory, structure.filename),
    what = "character",
    sep =  "\n",
    quiet = TRUE
  )
  struct = struct[2:(which(substring(struct, 1, 3) == "[1]") - 1)]
  struct = struct[substring(struct, 1, 12) != "line_numbers"]
  struct = unPaste(struct, sep = "=")
  struct.names = gsub("\\_", "\\.", struct[[1]])
  struct.loc = lapply(unPaste(struct[[2]], sep = ","), asNumeric)
  struct.loc[[1]] = struct.loc[[1]] + 1

  bootlist = lapply(seq(along = struct.names),
                    function(i, struct.names, struct.loc, bootdf) {
                      #i = 1;i = 31
                      mySequence = struct.loc[[1]][i]:(struct.loc[[1]][i] +
                                                         struct.loc[[2]][i] - 1)
                      theBootComponent = if (length(mySequence) > 1) {
                        as.data.frame(bootdf[, mySequence])
                      } else {
                        data.frame(value = bootdf[, mySequence])
                      }
                      if (length(mySequence) == 1)
                        names(theBootComponent) = struct.names[i]
                      theBootComponent
                    }, struct.names = struct.names,
                    struct.loc = struct.loc,
                    bootdf = bootstrap.data)
  names(bootlist) = struct.names
  if (!quiet)
    cat("read", nrow(bootlist[[1]]) - 1, "bootstrap replicates\n")
  myStructure = data.frame(component = struct.names,
                           start = struct.loc[[1]],
                           end =  struct.loc[[2]])
  
  boot_base = lapply(1:length(parlist),function(x,parlist,bootlist)  
    bootlist[[parlist[[x]]]] %>%tibble, bootlist = bootlist, parlist = parlist)

  boot = list(
    bootstrap = bootlist,
    boot_base = boot_base,
    structure = myStructure,
    directory = directory
  )
  class(boot) = "bootstrap"
  return(boot)
}

