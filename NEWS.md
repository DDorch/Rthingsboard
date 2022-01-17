# Rthingsboard 0.2.6 (2022-01-17)

New features:

* Added a `NEWS.md` file to track changes to the package.
* Documentation improvement

Bug fixes:

* Infinite loop on getTelemetry with several keys (#5)
* TS output '1970-01-01 01:00:00' and no value (#7)

Internal changes:

* error on CRAN check when server is down (#8)


# Rthingsboard 0.2.4 (2021-01-20)

Internal changes:

* error on CRAN check when server is down (#4)


# Rthingsboard 0.2.2 (2021-01-13)

Version submitted to CRAN


# Rthingsboard 0.2.1 (2020-12-06)

Internal changes:

* Put package names, software names and API (application programming interface) names in single quotes
* Remove <<- assignments


# Rthingsboard 0.2.0 (2020-11-30)

New features:

* Overcome limitation of fetching 100 records by keys (#1)
* Add error handler in thingsboardApi
* Improve documentation

Bug fixes:

* Time zone issues (4db37394ad5f55382b243070a8dd003b4b3bc2da)

Internal changes:

* add Github action for automatic checks


# Rthingsboard 0.1.0 (2020-11-26)

New features:

* Initial version with getKeys and getValues methods
