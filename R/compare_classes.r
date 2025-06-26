globalVariables(c('column', 'class_df1', 'class_df2', 'mark', 'full_join'))
#' Compare Two Data Frames
#' 
#' Compares the classes of two data.frames.
#' 
#' @export
#' @param df1 data.frame
#' @param df2 data.frame
#' @param ... ignored
#' @return used for side effects
#' @family basic
#' @examples
#' library(magrittr)
#' library(dplyr)
#' library(tibble)
#' df1 = example_pkpd_data() %>% as_tibble
#' df2 = df1 %>% mutate(sex=ifelse(sex=="F",1,0), keo=as.character(keo))
#' compare_classes(df1,df2)
#' compare_classes(df1,df2) %>% filter(mark==1)

compare_classes=function (df1, df2, ...) 
{
   udf1=lapply(df1, unclass) %>% data.frame
   ndf1 = sapply(udf1, class) %>% data.frame
   names(ndf1) = "class_df1"
   ndf1$column = names(df1)
   udf2=lapply(df2, unclass) %>% data.frame
   ndf2 = sapply(udf2, class) %>% data.frame
   names(ndf2) = "class_df2"
   ndf2$column = names(df2)
   ndf1 %<>% select(column, class_df1)
   ndf2 %<>% select(column, class_df2)
   result = dplyr::full_join(ndf1, ndf2)
   result %<>% mutate(mark = 0)
   result %<>% mutate_cond(is.na(class_df1) | is.na(class_df2), 
                           mark = 1)
   result %<>% mutate_cond(mark == 0 & class_df1 != class_df2, 
                           mark = 1)
   names(result)[2:3] = c(deparse(substitute(df1)), deparse(substitute(df2)))
   
   fst1=pivot_longer(df1[1,, drop=F],cols=everything(),names_to="column",values_to = "FST1", 
                     values_transform = as.character)
   fst2=pivot_longer(df2[1,, drop=F],cols=everything(),names_to="column",values_to = "FST2", 
                     values_transform = as.character)
   result %<>% full_join(fst1,by="column") %>% full_join(fst2,by="column")
   
   names(result)[5:6] = c(paste0(deparse(substitute(df1)), "_1strec"), 
                          paste0(deparse(substitute(df2)), "_1strec"))
   result %>% as_tibble()
}
