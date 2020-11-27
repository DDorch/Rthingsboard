context("thingsboard_api")

url = "http://scada.g-eau.fr"
publicId = "299cedc0-f3e9-11e8-9dbf-cbc1e37c11e3"
entityId = "18d56d50-f3e9-11e8-9dbf-cbc1e37c11e3"

startDate = as.POSIXct("2020-11-19 9:30:00")
endDate = as.POSIXct("2020-11-19 17:00:00")

tb_api = ThingsboardApi(url = url, publicId = publicId)

test_that("getToken should return appropriate error", {
  skip_on_cran()

  publicId <-  "Fake_publicId"

  expect_error(
    ThingsboardApi(url = "https://no-site.g-eau.fr", publicId = publicId),
    regexp = "Could not resolve host: no-site.g-eau.fr"
  )

  expect_error(
    ThingsboardApi(url = "https://www.google.fr", publicId = publicId),
    regexp = "Not Found"
  )

  url = "http://scada.g-eau.fr"
  expect_error(
    ThingsboardApi(url = url, publicId = publicId),
    regexp = "Unauthorized"
  )
})

test_that("getKeys should return appropriate error", {
  skip_on_cran()

  entityId = "Fake_entityId"
  #tb_api = ThingsboardApi(url = url, publicId = publicId)

  expect_error(object = tb_api$getKeys(entityId),
               regexp = "Internal Server Error")

})

test_that("getValues should return appropriate error", {
  skip_on_cran()

  entityId = "Fake_entityId"

  expect_error(object = tb_api$getValues(entityId, "A0", startDate, endDate),
               regexp = "Internal Server Error")

})

test_that("getValues should returns empty data.frame", {

  expect_empty_getValues <- function(df) {
    expect_equal(class(df), "data.frame")
    expect_equal(nrow(df), 0)
    expect_equal(names(df), c("key", "ts", "value"))
  }

  df <- tb_api$getValues(entityId, "fake key", startDate, endDate)
  expect_empty_getValues(df)

  startDate = as.POSIXct("2010-01-01 0:00:00")
  endDate = as.POSIXct("2010-01-02 0:00:00")
  df <- tb_api$getValues(entityId, "A0", startDate, endDate)
  expect_empty_getValues(df)
})


