# Startup code

.onLoad <- function(libname, pkgname){
  #check and set default options

  if(is.null(getOption("nmDir"))) options(nmDir = file.path(getwd(),"NONMEM"))
  if(Sys.getenv("UNZIP_CALL") == "" |Sys.getenv("ZIP_CALL") == "" ){
     if(!file.exists('c:/progra~1/7-zip/7z.exe')){
       warning('cannot find zip program c:/progra~1/7-zip/7z.exe; see ?nm.unzip')
     }
   }
   if(Sys.getenv("UNZIP_CALL") == ""){
      options(unzip.call = "c:/progra~1/7-zip/7z e %s.7z")
   } else{
      options(unzip.call = Sys.getenv("UNZIP_CALL"))
   }
   if(Sys.getenv("ZIP_CALL") == ""){
      options(zip.call = "c:/progra~1/7-zip/7z a %s.7z")
   } else{
      options(zip.call = Sys.getenv("ZIP_CALL"))
   }

}

.onAttach <- function(libname, pkgname){
  #packageStartupMessage(qP.welcome(Sys.getenv("USERNAME")))
  #packageStartupMessage(paste("package path = ", path.package("qptools")))
  if(is.null(getOption("qpExampleDir"))) options(qpExampleDir = file.path(path.package("qptools"),"extdata", "NONMEM"))
  if(is.null(getOption("project"))) nonmemica::psn_options(
     project=expr(getOption("nmDir")) #, 
     # fields = c("label","unit","transform","symbol") # commenting at 0.3.2
    )
}
