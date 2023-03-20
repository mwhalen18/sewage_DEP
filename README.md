
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sewage

<!-- badges: start -->
<!-- badges: end -->

The goal of sewage is to provide a light-weight pipelining interface for
data analyses. It acts as a stop-gap solution between chaotic scripting
and a full-fledged ETL tool.

## Installation

You can install the development version of sewage like so:

``` r
devtools::install_github("mwhalen18/sewage")
```

## Example

Below is an example of a simple pipeline that can be constructed.

``` r
library(sewage)
```

You can use any function as a component in the pipeline, including
custon functions you define or import from an external source.

``` r
subset_data = function(x) {
  subset(x, cyl == 6)
}

summarizer = function(x) {
  return(summary(x[['disp']]))
}
```

Currently, there are 2 components ready for use. Basic `Nodes` and
`Splitters`. Nodes take one object as imput and return exactly one
object. Splitters take in exactly one object and may return any number
of outputs greater than 1.

The first node in your pipeline should specify the argument that will be
passed into the pipeline when we execute it (More on this below).

Note outputs of a Splitter are accessible by specifying the name of the
splitter component (In this case `Splitter`) suffixed with the outgoing
edge in the format `.output_{i}`. Currently this suffix cannot be
modified

``` r
pipeline = Pipeline()

pipeline = pipeline |>
  add_node(component = read_csv, name = "Reader", input = "file") |>
  add_node(component = subset_data, name = "Subsetter", input = "Reader") |>
  add_node(component = Splitter(), name = "Splitter", input = "Subsetter") |>
  add_node(component = summarizer, name = "Summarizer", input = "Splitter.output_1")
```

Here we execute the pipeline with the `run` command. It is important to
note that the argument you pass to run should match the `input` argument
of your first node in your pipeline. In this case we are passing a
`file` argument in `run` and similarly our first node is set to receive
a `file` argument as input.

You may choose any argument you like, as long as these two arguments
match!

``` r
result = run(pipeline, file = 'temp.csv')
```

We can now access the results of our terminating nodes. A terminating
node is any node that is not specified as input. By default when the
pipeline is run, each node will overwrite the output of its input node.
Therefore any node that is not fed forward to a new node will return
output. In the case of this pipeline, the `Splitter.output2` and
`Summarizer` edges are our terminating nodes. Therefore, we can access
their results in the `outputs` object of the pipeline

``` r
result$outputs$Splitter.output_2
```

``` r
result$outputs$Summarizer
```

# Why sewage?

What is the point of `{sewage}` over more robust ETL pipelining tools
like `{targets}` or Airflow? Honestly, if you feel comfortable using
more heavy-weight tools you should. This package privides a light-weight
interface to visualize and organize complex
cleaning/processing/visualization scripts.
