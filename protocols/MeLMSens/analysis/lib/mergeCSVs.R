mergeCSVs = function(filepaths) {
  suppressPackageStartupMessages(library(tidyverse, verbose = FALSE, quietly = TRUE))
  filepaths %>%
    lapply(.,function(x) {
      read_csv(x, col_types = cols()) %>%
        add_column(filename=basename(x),.before=1)
    }) %>%
    bind_rows %>%
    return(.)
}

main = function() {
  # Parse arguments
  args = commandArgs(trailingOnly = TRUE)
  
  if (length(args) == 0) { # no arguments, use stdin
    stop("No files specified")
  } else if (args[1] == "--dir") { # DIRPATH specified
    dirpath = args[2]
    filepaths = args[-(1:2)] # extract files specified in other args
    filepaths = lapply(filepaths, function(x) paste0(dirpath,'/',x))
    
  } else { # filepaths specified, no DIRPATH specified
    dirpath = ''
    filepaths = args
  }
  if (length(filepaths) == 0) # if no filepaths specified
    if (length(dirpath) != 0) { # is DIRPATH specified?
      filepaths = list.files(path = dirpath, pattern ="*csv") # find all CSVs in $DIRPATH
      filepaths = lapply(filepaths, function(x) paste0(dirpath,'/',x))
    }

  # Merge        
  CSV = mergeCSVs(filepaths)
  
  # Output to stdout, formatted as CSV  
  cat(format_csv(CSV))
}

main()