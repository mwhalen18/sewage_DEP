test_that("pipeline creates pipeline object", {
  pipeline = Pipeline()
  expect_s3_class(pipeline, "sewage_pipeline")
})


test_that("run fails for non-pipelines", {
  stop("Not Implemented")
})
