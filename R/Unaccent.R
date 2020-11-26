#' Remove accents from a string
#'
#' [Unaccent] remove accent from a string with a given charset, [UnaccentSmart]
#' do the same thing with an alternate charset in case of a string with
#' multiple mixed charsets.
#'
#' @param text the input string
#' @param from the initial charset (default: "UTF-8")
#' @param alterfrom the alternate charset (default: "Latin1")
#'
#' @return the string without accents
#' @references From https://data.hypotheses.org/564
#'
#' @rdname Unaccent
#' @export
#' @examples
#' Unaccent("éàù")
#' UnaccentSmart("éàù")
#'
Unaccent <- function(text, from="UTF-8") {
    text <- gsub("['`^~\"]", " ", text)
    text <- iconv(text, from=from, to="ASCII//TRANSLIT//IGNORE")
    text <- gsub("['`^~\"]", "", text)
    return(text)
}


#' @rdname Unaccent
#' @export
UnaccentSmart <- function(text, from="UTF-8", alterfrom="latin1") {
    tOut = Unaccent(text, from)
    if(nchar(text) != nchar(tOut)) {
        # Des caractères ont visiblement été oubliés dans la conversion, on essaie un autre charset
        tOut = Unaccent(text, from=alterfrom)
    }
    return(tOut)
}
