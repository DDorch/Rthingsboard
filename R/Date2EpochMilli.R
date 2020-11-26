#' Convert a date into an epoch in milliseconds
#'
#' This function allows to convert epoch timestamp in seconds to an epoch in milliseconds
#'
#' @param ts a [numeric] representing an epoch in seconds or a [POSIXt] date
#'
#' @return a [character] of the epoch in milliseconds
#' @export
#'
#' @rdname Date2EpochMilli
#' @examples
#' Date2EpochMilli(as.numeric(Sys.time()))
#'
Date2EpochMilli <- function(ts) {
  UseMethod("Date2EpochMilli")
}

#' @rdname Date2EpochMilli
#' @export
Date2EpochMilli.POSIXt <- function(ts) {
  Date2EpochMilli(as.numeric(ts))
}

#' @rdname Date2EpochMilli
#' @export
Date2EpochMilli.numeric <- function(ts) {
  paste0(as.character(floor(ts)), "000")
}
