#' @title Thingboard API Class
#'
#' @field url [character] URL of the 'ThingsBoard' IoT platform.
#' @field publicId [character] the public ID of the device
#' @field token [character] the current token
#' @field tokenTimeOut A [numeric] contains the time out of a token in seconds (default 300)
#' @field tokenEpiration A [numeric] with the Epoch of the expiration date time of current token
#'
#' @export ThingsboardApi
#' @exportClass ThingsboardApi
#' @importFrom methods new
#'
#' @examples
#' \donttest{
#' thinksboard_api = tryCatch(
#'   {
#'     ThingsboardApi(url="http://scada.g-eau.fr",
#'                    publicId="299cedc0-f3e9-11e8-9dbf-cbc1e37c11e3")
#'   },
#'   error = function(e) {
#'     message("An error occured:\n", e)
#'     return(FALSE)
#'   }
#' )
#' }
ThingsboardApi <- setRefClass(
  "ThingsboardApi",

  fields = list(
    url = "character",
    publicId = "character",
    token = "character",
    tokenExpiration = "numeric",
    tokenTimeOut = "numeric"
  ),

  methods = list(
    initialize = function(..., tokenTimeOut = 300) {
      callSuper(..., tokenTimeOut = tokenTimeOut)
      getToken()
    }
  )
)


#' Check if the token is timeouted and refresh it if necessary
#'
#' @name ThingsboardApi_checkToken
#' @return [NULL]
#'
NULL
ThingsboardApi$methods(
  checkToken = function () {
    if (as.numeric(Sys.time()) >= tokenExpiration) {
      getToken()
    }
  }
)


#' Get authorisation token from thingsboard server for a specific device
#'
#' @name ThingsboardApi_getToken
#' @param timeOut [numeric] number of second before token timeout (default field `tokenTimeOut`)
#'
#' @return A [list] with keys 'token' and 'refreshtoken'
#'
NULL
ThingsboardApi$methods(
  getToken = function (timeOut = tokenTimeOut) {
    res <- httr::POST(
      url = file.path(url, "api/auth/login/public"),
      body = list(publicId = publicId),
      encode = "json"
    )
    if (httr::http_error(res) || httr::http_status(res)$reason != "OK") {
      stop("Request failed with status ",
           httr::http_status(res)$message)
    }

    dToken = httr::content(res, as = "parsed", encoding = "Latin1")
    .self$token <- dToken$token
    logger::log_debug("ThingsboardApi$getToken: ", substr(token, 1, 12), "...")
    .self$tokenExpiration <- as.numeric(Sys.time()) + timeOut
    logger::log_debug("ThingsboardApi$getToken: expiration ",
                      as.character(as.POSIXct(tokenExpiration, origin =
                                                "1970-01-01")))
    return (dToken)
  }
)


#' Fetch data keys for an entity
#'
#' @name ThingsboardApi_getKeys
#' @details
#' The description of this operation in API documentation is here: <https://thingsboard.io/docs/user-guide/telemetry/#get-telemetry-keys>
#'
#' @param entityId [character] entity ID
#' @param entityType [character] (default "DEVICE")
#'
#' @return A vector of [character] with the keys available for the requested device.
#'
NULL
ThingsboardApi$methods(
  getKeys = function(entityId, entityType = "DEVICE") {
    checkToken()
    res = httr::GET(
      url = file.path(
        url,
        "api/plugins/telemetry",
        entityType,
        entityId,
        "keys/timeseries"
      ),
      httr::content_type_json(),
      httr::add_headers(`X-Authorization` = paste("Bearer", token))
    )

    if (httr::http_error(res) || httr::http_status(res)$reason != "OK") {
      stop("Request failed with status ",
           httr::http_status(res)$message)
    }

    keys <-
      unlist(httr::content(res, as = "parsed", encoding = "Latin1"))
    logger::log_debug(paste("keys =", paste(keys, collapse = ", ")))
    return (keys)
  }
)


#' Fetch values from an entity
#'
#' @description
#' See: <https://thingsboard.io/docs/user-guide/telemetry/#get-telemetry-values>
#'
#' This method has a strong limitation as the 'ThingsBoard' API only send the
#' 100 last values of each key.
#' Use the method getTelemetry to override this limitation.
#'
#' @name ThingsboardApi_getValues
#' @param entityId A [character] with the entity ID given (See <https://thingsboard.io/docs/user-guide/entity-views/>)
#' @param keys Vector of [character] with the list of keys from which getting the telemetry values
#' @param entityType A [character] (default "DEVICE")
#' @param startTs A [numeric] or a [POSIXct] representing respectively the epoch or the date of the start of data extraction period
#' @param endTs A [numeric] or a [POSIXct] representing respectively the epoch or the date of the end of data extraction period
#'
#' @return A [data.frame] with one row per data and 3 columns:
#'   `key`: A [character] with the key,
#'   `ts`: A [POSIXct] with the timestamp of the data,
#'   `value`: A [numeric] with the value of the data
#'
#'
NULL
ThingsboardApi$methods(
  getValues = function(entityId,
                       keys,
                       startTs,
                       endTs,
                       interval = NULL,
                       agg = "NONE",
                       entityType = "DEVICE") {
    checkToken()
    lQuery = list(
      keys = paste(lapply(keys, curl::curl_escape), collapse = ","),
      startTs = Date2EpochMilli(startTs),
      endTs = Date2EpochMilli(endTs),
      agg = agg
    )
    if (!is.null(interval)) {
      query$interval <- interval
    }
    query <- paste(sapply(names(lQuery),
                          function(x) {
                            paste0(x, "=", lQuery[[x]])
                          }), collapse = "&")

    logger::log_debug("getValues query ", query)

    res = httr::GET(
      url = file.path(
        url,
        "api/plugins/telemetry",
        entityType,
        entityId,
        "values/timeseries"
      ),
      query = query,
      httr::content_type_json(),
      httr::add_headers(`X-Authorization` = paste("Bearer", token))
    )

    if (httr::http_error(res) || httr::http_status(res)$reason != "OK") {
      stop("Request failed with status ",
           httr::http_status(res)$message)
    }

    lV <- httr::content(res, as = "parsed", encoding = "Latin1")
    lV <- lapply(names(lV),
                 function(x) {
                   df <- data.frame(key = x,
                                    v = matrix(unlist(lV[[x]]), ncol = 2, byrow = TRUE),
                                    stringsAsFactors = FALSE)
                   colnames(df) <-
                     c("key", "ts", "value")
                   df
                 })
    if(length(lV) > 0) {
      dfV <- do.call(rbind, lV)
      dfV$ts <- EpochMilli2Date(dfV$ts, timezone = attributes(startTs)$tzone)
      dfV$value <- as.numeric(dfV$value)
    } else {
      dfV <- data.frame(key = character(),
                        ts = as.POSIXct(character()),
                        value = numeric(),
                        stringsAsFactors = FALSE)
    }
    return(dfV)
  }
)


#' Fetch telemetry
#'
#' @description
#'
#' Fetch telemetry data for an entity. See [ThingsboardApi_getValues] for the arguments.
#'
#' See: <https://thingsboard.io/docs/user-guide/telemetry/#get-telemetry-values>
#'
#' @name ThingsboardApi_getTelemetry
#' @param ... Parameters passed through method [ThingsboardApi_getValues]
#' @param endTs A [numeric] or a [POSIXct] representing respectively the epoch or the date of the end of data extraction period
#'
#' @return A [data.frame] with one row per data and 3 columns:
#'
#'  * `key`: a [character] with the key
#'  * `ts`: a [POSIXct] with the timestamp of the data
#'  * `value`: a [numeric] with the value of the data
#'
#' @import dplyr
#'
NULL
ThingsboardApi$methods(
  getTelemetry = function(..., endTs) {
    l <- list()
    i <- 0
    while (TRUE) {
      i <- i + 1
      l[[i]] <- getValues(..., endTs = endTs)
      if (nrow(l[[i]]) == 0) break
      df_minTs <- l[[i]] %>% arrange(ts) %>% group_by(key) %>% slice(1)
      endTs <- max(df_minTs$ts) - 1
    }
    df <- do.call(rbind, l)
    df <- unique(df)
    return(df)
  }
)
