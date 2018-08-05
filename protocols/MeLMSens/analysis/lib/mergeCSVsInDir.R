#mergeCSVinDir = function(dirpath) {
  library(tidyverse)
  list.files(path = dirpath, pattern ="results-.*csv") %>%
    lapply(.,function(x) read_csv(paste0(dirpath,x))) %>%
    bind_rows
# }