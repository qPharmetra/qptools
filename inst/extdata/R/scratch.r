library(tidyverse)
library(pmxTools)
library(qptools)
library(nonmemica)

nonmem <- system.file(package = 'qptools', 'extdata','NONMEM')
fields <- c('symbol','number','transform','unit') # as in run1298, revised

# harmonization of nonmemica and qptools depends on project == nmDir
psn_options(project = nonmem, fields = fields)
options(nmDir = nonmem)

mod1298 = read_nm_qp("run1298",path = getOption("nmDir"))
#mod1298 = read_nm_qp("run1298",path = getOption("nmDir"), quiet = TRUE, clear_zip=FALSE)
mod1298 %>% get_theta()
mod1298 %>% get_omega()
mod1298 %>% get_sigma()
mod1298 %>% get_est_table %>% head
mod1298 %>% get_est_table() %>% slice(5:12,99:107,197:202)
# 'run1298' %>% definitions




#greek=paste0(toupper(paste0(substring(item, 1,5)))
nm_definitions_conversion = function(
  run, 
  path = getOption("nmDir"), 
  extension="mod"
){
  nonmemica::definitions(paste0(run,fxs(extension,".   "))
                         , project = file.path(path)
  ) %>%
  mutate(greek=toupper(item)) %>%
  mutate(class="other", first=NA, second=NA) %>%
  mutate_cond(substring(item,1,5)=="theta",class="theta") %>%
  mutate_cond(substring(item,1,5)=="omega",class="omega") %>%
  mutate_cond(substring(item,1,5)=="sigma",class="sigma") %>%
  mutate_cond(class %in% c("theta","omega", "sigma")
              , first = as.numeric(
                lapply(stringr::str_split(item,pattern="_"), function(x) x[2]))
  ) %>%
  mutate_cond(class %in% c("omega", "sigma")
            , second = as.numeric(
              lapply(stringr::str_split(item,pattern="_"), function(x) x[3]))
  ) %>%
  mutate_cond(class %in% c("omega", "sigma") & first != second
              , greek=paste0(substring(toupper(class),1,2),paste(first,second,sep=","))
  ) %>%
  mutate_cond(class %in% c("omega", "sigma") & first == second
              , greek=paste0(substring(toupper(class),1,5),first)
  ) %>%
  mutate_cond(class %in% c("theta")
              , greek=paste0(substring(toupper(class),1,5),first)
  )
}

nm_definitions_conversion(run="1001", path = )


#mutate_cond

x = data.frame(a=c(1,1,1,1,1,2,2,2,2,2),b=c(1,NA,4,5,6,10,NA,14,15,16), c=c(1,2,3,4,5,0,1,1,2,3))

x %>% mutate(A2=0,A3=0) %>%
  mutate_cond(condition=c>=2, A2=1, A3=cumsum(A2))

x %>% mutate(A2=0,A3=0) %>%
  group_by(a) %>%
  mutate_cond(c>=2, A2=1, A3=cumsum(A2))

## NAs - how to deal with them
x %>% mutate(newValue=b) %>%
  mutate_cond(is.na(b), newValue=median(b, na.rm = TRUE))


x %>% mutate(newValue=b) %>%
  mutate_cond(is.na(b), newValue=median(.$b, na.rm = TRUE))

x %>% mutate(newValue=b) %>%
  group_by(a) %>%
  mutate_cond(is.na(b), newValue=median(.$b, na.rm = TRUE))

## better: ifelse
x %>% mutate(newValue=b) %>%
  group_by(a) %>%
  mutate(newValue=ifelse(is.na(b), median(b, na.rm = TRUE), b))
