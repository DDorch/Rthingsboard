% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/thingsboard_api.R
\name{ThingsboardApi_getKeys}
\alias{ThingsboardApi_getKeys}
\title{Fetch data keys for an entity}
\arguments{
\item{entityId}{\link{character} entity ID}

\item{entityType}{\link{character} (default "DEVICE")}
}
\value{
A vector of \link{character} with the keys available for the requested device.
}
\description{
Fetch data keys for an entity
}
\details{
The description of this operation in API documentation is here: \url{https://thingsboard.io/docs/user-guide/telemetry/#get-telemetry-keys}
}
