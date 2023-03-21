test_that("Node returns a node type", {
  node = Node(input = "foo", call = read.csv, name = "bar")
  expect_s3_class(node, "sewage_node")
})

test_that("Splitter returns a splitter type", {
  splitter = Splitter(edges = 2)
  expect_s3_class(splitter, "sewage_splitter")
})

test_that("Splitter disallows less than 1 edge", {
  expect_error(Splitter(edges = 1))
})

test_that("Splitter results in split", {
  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Splitter(), name = "Splitter", input = "data")

  output = run(pipeline, data = mtcars)

  expect_equal(length(output$outputs), 2)
})

test_that("Splitter results in n splits", {
  n_splits = 4

  pipeline = Pipeline()
  pipeline = pipeline |>
    add_node(component = Splitter(edges = n_splits), name = "Splitter", input = "data")

  output = run(pipeline, data = mtcars)

  expect_equal(length(output$outputs), n_splits)
})
