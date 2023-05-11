#START OF AUTO-GENERATED PREAMBLE, WILL BE OVERWRITTEN WHEN THIS FILE IS USED AS A TEMPLATE
#Created 2022-10-06 at 18:39

rplots.level <- 1
xpose.runno <- '1298'
toolname <- 'execute'
pdf.filename <- paste0('PsN_',toolname,'_plots.pdf')
pdf.title <- 'execute diagnostic plots run 1298'
working.directory<-'/home/klaas.prins@qpharmetra.com/HumanPK/run1298/'
model.directory<-'/home/klaas.prins@qpharmetra.com/HumanPK/'
results.directory <- '/home/klaas.prins@qpharmetra.com/HumanPK/'
model.filename<-'run1298.mod'
subset.variable<-NULL
mod.suffix <- '.mod'
mod.prefix <- 'run'
tab.suffix <- ''
rscripts.directory <- '/usr/local/share/perl/5.26.1/PsN_4_8_1/R-scripts'
raw.results.file <- 'raw_results_run1298.csv'
theta.labels <- c('V1','CL','V2','Q','KAEXP','MDTEXP','F1EXP','BEXP','RBAEXP','KABUP','MDTBUP','F1BUP','BBUP','RBABUP','AERR','PERR','V allometry - weight','CL allometry - weight','KA_NB','MDT_NB','F1_NB','B_NB','RBA_NB','KA_FEM','MDT_FEM','F1_FEM','B_FEM','RBA_FEM','MDTEXP_ANKNB','MDTEXP_SPNB','MDTEXP_SPFB','MDTEXP_HERFB','MDTEXP_ANUS','MDTEXP_ANKFB','RBAEXP_ANKNB','RBAEXP_SPNB','RBAEXP_KNFB','RBAEXP_HERFB','RBABUP_HERFB','KABUP_HERFB','F1EXP_ANUS','F1EXP_SPFB','F1EXP_ANKFB','F1EXP_INNB','KAEXP_ANKFB','KAEXP_SPNB','KAEXP_ANUS','BEXP_SPNB','RBAEXP_CAR','MDTEXP_BR','F1EXP_BR','BEXP_BR','RBAEXP_BR','F1EXP_DOSE','MDTEXP_DOSE','F1BUP_KNFB','MDTBUP_KNFB','F1BUP_SPNB','ST2_ANKNB_F1BUP','ST2_ANKNB_RBABUP','MDTBUP_ANKNB','F1BUP_SPFB','MDTBUP_SPNB','KABUP_SPNB','MDTBUP_SPFB','RBABUP_SPNB','MDTEXP_TAP','RBAEXP_ST2','RBAEXP_ST118','RBAEXP_ST120','F1EXP_ST2','MDTEXP_ST118','RBABUP_TAP','F1EXP_TAP','IIV_RBAEXP_FB','IIV_RBAEXP_NB','ST203_F1BUP','ST203_F1EXP','F1EXP_CAR','BEXP_SHNB','MDTEXP_SHNB','IIV_RBA_KNEE_SCALAR','BEXP_SPFB','BEXP_ANUS','BEXP_CAR','MDTEXP_CAR','BBUP_KNFB','EARLY_PERR','MDTBUP_BR','ST122_MDTEXP_ANKNB','KAEXP_SHNB','ST122_F1EXP_ANKNB','ST122_BEXP_ANKNB','ST323_F1EXP_KNNB','BEXP_TAP','F1BUP_BR')
theta.fixed <- c(TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)
omega.labels <- c('IIV_V1','IIV_CL','IIV_V2','IIV_Q','IIV_KAEXP','IIV_MDTEXP','IIV_F1EXP','IIV_BEXP','IIV_RBAEXP','IIV_KABUP','IIV_MDTBUP','IIV_F1BUP','IIV_BBUP','IIV_RBABUP')
omega.fixed <- c(TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)
sigma.labels <- c('SIGMA_RES')
sigma.fixed <- c(TRUE)
n.eta <- 14
n.eps <- 1

res.table <- 'patab1298'

setwd(working.directory)

############################################################################
#END OF AUTO-GENERATED PREAMBLE
#WHEN THIS FILE IS USED AS A TEMPLATE THIS LINE MUST LOOK EXACTLY LIKE THIS


pdf(file=pdf.filename,width=10,height=7)
# get libPaths
source(file.path(rscripts.directory,"common/R_info.R"))
R_info(directory=working.directory,only_libPaths=T)
# Used libraries
library(xpose4)

source(paste0(rscripts.directory,"/common/file_existence_in_directory.R"),echo=TRUE)
source(paste0(rscripts.directory,"/execute/data.obj.obsi.R"),echo=TRUE) 
source(paste0(rscripts.directory,"/execute/plot.obj.obsi.R"),echo=TRUE)
#add R_info to the meta file
R_info(directory=working.directory)
xpdb <- xpose.data(xpose.runno, directory=results.directory, tab.suffix=tab.suffix, mod.prefix=mod.prefix, mod.suffix=mod.suffix)

#uncomment below to change the idv from TIME to something else such as TAD.
#Other xpose preferences could also be changed
#xpdb@Prefs@Xvardef$idv="TAD"
runsum(xpdb, dir=results.directory,
         modfile=paste(model.directory, model.filename, sep=""),
         listfile=paste(results.directory, sub(mod.suffix, ".lst", model.filename), sep=""))
if (is.null(subset.variable)){
    print(basic.gof(xpdb))
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(basic.gof(xpdb,by=subset.variable,max.plots.per.page=1))
}
if (is.null(subset.variable)){
    print(ranpar.hist(xpdb))
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(ranpar.hist(xpdb,by=subset.variable,scales="free",max.plots.per.page=1))
}
if (is.null(subset.variable)){
    print(ranpar.qq(xpdb))
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(ranpar.qq(xpdb,by=subset.variable,max.plots.per.page=1))
}
if (is.null(subset.variable)){
    print(dv.preds.vs.idv(xpdb))
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(dv.preds.vs.idv(xpdb,by=subset.variable))
}
if (is.null(subset.variable)){
    print(dv.vs.idv(xpdb))
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(dv.vs.idv(xpdb,by=subset.variable))
}
if (is.null(subset.variable)){
    print(ipred.vs.idv(xpdb))
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(ipred.vs.idv(xpdb,by=subset.variable))
}
if (is.null(subset.variable)){
    print(pred.vs.idv(xpdb))
    
}else{
    # change the subset variable from categorical to continuous or vice versa.
    # change.cat.cont(xpdb) <- c(subset.variable)
    print(pred.vs.idv(xpdb,by=subset.variable))
}
rplots.gr.1 <- FALSE
if (rplots.level > 1){
  rplots.gr.1 <- TRUE
  #individual plots of ten random IDs
  #find idcolumn
  idvar <- xvardef("id",xpdb)
  ten.random.ids<-sort(sample(unique(xpdb@Data[,idvar]),10,replace=FALSE))
  subset.string <- paste0(idvar,'==',paste(ten.random.ids,collapse=paste0(' | ',idvar,'==')))

  if (is.null(subset.variable)){
    print(ind.plots(xpdb,subset=subset.string))
  }else{
    for (flag in unique(xpdb@Data[,subset.variable])){
      print(ind.plots(xpdb,layout=c(1,1),subset=paste0(subset.variable,'==',flag,' & (',subset.string,')')))
    }
  }
}  
if (rplots.level > 1){
  #check if files exist
  if (res.table != '') {
    file_1_exists <- file_existence_in_directory(directory=results.directory, file_name=paste0(mod.prefix, xpose.runno, ".phi"))
    file_2_exists <- file_existence_in_directory(directory=results.directory, file_name=res.table)
    
    if ((file_1_exists == TRUE) && (file_2_exists == TRUE)) {
      # calculate data
      list_out <- data.obj.obsi(obj.data.dir=paste0(results.directory, mod.prefix, xpose.runno, ".phi"),
                                obsi.data.dir=paste0(results.directory, res.table))
      have_needed_columns <- list_out$have_needed_columns
      if(have_needed_columns) {
        OBJ_data <- list_out$OBJ_data
        OBSi_vector <- list_out$OBSi_vector
        OBJ_vector <- list_out$OBJ_vecto
      
        # plot data
        plot.obj.obsi(OBJ_data,OBSi_vector,OBJ_vector)
      }
    }
  }
}
dev.off()

