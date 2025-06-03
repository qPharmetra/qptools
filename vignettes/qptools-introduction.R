## ----setup, include=FALSE-----------------------------------------------
knitr::opts_chunk$set(echo = TRUE, eval = TRUE)

## -----------------------------------------------------------------------
library(qptools) 
library(nonmemica)
library(pmxTools)
library(dplyr)
library(magrittr)
library(yamlet)
library(wrangle)

options(qpExampleDir = system.file(package="qptools") %>% file.path(., "extdata/NONMEM")) 

getOption("qpExampleDir")
getOption("qpExampleDir") %>% dir


## -----------------------------------------------------------------------
LIBRARY("qptools")

## -----------------------------------------------------------------------

example(fxs)
example(aadp)
example(repeat_nth)
example("asNumeric")
example("isNumeric")


## -----------------------------------------------------------------------
getOption("qpExampleDir") %>% file.path(., "run105") %>% dir() ## no xml file, only zipped file
getOption("qpExampleDir") %>% file.path(.) %>% nm_unzip("run105", rundir=., extension = "xml")
getOption("qpExampleDir") %>% file.path(., "run105") %>% dir() ## there it is

## -----------------------------------------------------------------------
options(nmDir = getOption("qpExampleDir"))

## -----------------------------------------------------------------------

"run105" %>% read_lst()
"run105" %>% read_lst() %>% writeLines()

"run105" %>% read_mod()
"run105" %>% read_mod() %>% writeLines()

"run105" %>% read_ext() 
"run105" %>% read_ext() %>% as.list
"run105" %>% read_ext() %>% as.list %>% names
"run105" %>% read_ext() %>% as.matrix
"run105" %>% get_ext() 


## ----lol----------------------------------------------------------------

"run105" %>% get_ext() %>% lol
"run105" %>% get_ext() %>% lol(n=2)


## ----shrinkage and diagonals--------------------------------------------

## functions underneath that may be of interest
"run103" %>% nm_shrinkage()
"run103" %>% nm_shrinkage(eta.shrinkage.clue = "ETASHRINKVR") # check eps.shrinkage.clue = "EPSSHRINKVR"
"run105" %>% find_diag()


## ----simple parameter tables--------------------------------------------

"run103" %>% nm_params_table()
"run103" %>% nm_params_table() %>% names
"run103" %>% nm_params_table() %>% lol

"run103" %>% nm_params_table_short() %>% lol
"run103" %>% nm_params_table() %>% format 
"run103" %>% nm_params_table() %>% format()


## ----format nm_param_table----------------------------------------------

"run103" %>% nm_params_table %>% 
  lol %>% 
  format(paste_label_unit='label')

## doing lol either before or after works
"run103" %>% nm_params_table %>% 
  format(paste_label_unit='label') %>% 
  lol

## rename columns as you desire - super-easy
"run103" %>% nm_params_table %>% 
   lol %>% 
   format(paste_label_unit='symbol') %>%
  select(-Parameter) %>%
  rename(Parameter = Description)

## formatting, AND preserve all intermediate material created using argument 'pretty=FALSE'
"run103" %>% nm_params_table %>% 
   lol %>% 
   format(paste_label_unit='label', pretty = FALSE)

## use the 4th labeling element instead of the 1st 
"run103" %>% nm_params_table %>% 
   format(paste_label_unit='symbol') %>%
  lol # does not matter when you select the estimation method. Before, after none (defaulting to last). all good


## -----------------------------------------------------------------------

"run103" %>% nm_params_table %>% 
  lol %>% 
  format(paste_label_unit='symbol', pretty=FALSE) %>%
  filter(on==0)
  

## -----------------------------------------------------------------------

"run105" %>% nm_parse_dollar_data
"run105" %>% load_modeled_dataset() %>% as_tibble()
"run105" %>% load_modeled_dataset(visibility = TRUE) %>% as_tibble()

"run105" %>% load_modeled_dataset(visibility = TRUE) %>% decorations
## VISIBLE shows original dataset marked for included (VISIBLE=1) or excluded (VISIBLE=0) in the NONMEM model.


1001 %>% get_xpose_tables(x=.,directory=system.file('project/model',package='nonmemica'))
try(1001 %>% superset(project=system.file('project/model',package='nonmemica'))) # no
1001 %>% superset(project=system.file('project/model',package='nonmemica'),ext="ctl") %>% as_tibble # yes


## ----get_xpose_table----------------------------------------------------

"run103" %>% get_xpose_tables

paste0("run", c(100,103,105)) %>% lapply(., function(x) get_xpose_tables(x))

library(ggplot2)
library(tidyr)

paste0("run", c(100,103,105)) %>% lapply(., function(x) get_xpose_tables(x) %>% mutate(model=x)) -> tmp
do.call("rbind", tmp) %>%
  pivot_longer(cols = c(IPRED,PRED)) %>%
  ggplot(aes(y=DV,x=value)) +
  geom_point(col = "darkslategrey") +
  stat_smooth(method='loess', alpha=0.33) +
  facet_grid(name~model)


## -----------------------------------------------------------------------

paste0("run", 100:105) %>% nm_runrecord()
paste0("run", 100:105) %>% nm_runrecord(. ,index = c(1,3,3))
paste0("run", 100:105) %>% nm_runrecord(. ,index = c(1,3,3,2,1))

paste0("run", c(100,103,105)) %>% nm_runrecord_graph()


## -----------------------------------------------------------------------

getOption("qpExampleDir") %>% dir

## full SCM forward backward and final
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% as_tibble()

#now play with chosen, direction to get what you want.

## forward steps
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(chosen==0&direction==1)
## backward steps
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(direction==-1)
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(chosen==0&direction==-1)

## final model
nm_process_scm(directory = file.path(getOption("nmDir"),"scm_example2")) %>% filter(chosen==1)


