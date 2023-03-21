test_that("Draw writes to graphics device", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = read.csv, name = "Reader", input = "file") |>
    add_node(component = Splitter(), name = "Splitter", input = "Reader")
  expect_s3_class(draw(pipeline), "grViz")
})
