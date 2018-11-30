median_SEM <- function(x){
  median = median(x)
  SEM = 1.253*sd(x)/sqrt(length(x))
  
  return(data.frame(median,SEM))
}

SEMedian <- function(x){
  return(1.253*sd(x, na.rm=TRUE)/sqrt(length(x)))
}

medianPlusSEM <- function(x) {
  ms = median_SEM(x)
  return(ms$median+ms$SEM)
}

medianMinusSEM <- function(x) {
  ms = median_SEM(x)
  return(ms$median-ms$SEM)
}