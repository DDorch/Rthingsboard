#' Convert an epoch in milliseconds into a date
#'
#' @param x A [character] or a [numeric] representing an epoch in milliseconds
#'
#' @return A [POSIXct], the date corresponding to the epoch
#' @export
#'
#' @examples
#' epoch <- Date2EpochMilli(as.numeric(Sys.time()))
#' EpochMilli2Date(epoch)
#'
EpochMilli2Date <- function(x) {
  return(
    as.POSIXct(as.numeric(x)/1000, tz = "GMT", origin = "1970-01-01")
  )
}
