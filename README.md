
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sewage

<!-- badges: start -->

[![R-CMD-check](https://github.com/mwhalen18/sewage/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mwhalen18/sewage/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
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

Below is an example of how to construct a simple pipeline.

``` r
library(sewage)
```

You can use any function as a component in the pipeline, including
custom functions you define or import from an external source.

``` r
subset_data = function(x) {
  subset(x, cyl == 6)
}

summarizer = function(x) {
  return(summary(x[['disp']]))
}
```

Currently, there are 3 components ready for use. Basic `Nodes`,
`Splitters`, and `Joiners`. Nodes take one object as input and return
exactly one object. Splitters take in exactly one object and may return
any number of outputs greater than 1. `Joiners` take in exactly 2
objects and return 1 object according to the method you pass to the
`Joiner` (More on Joiners below).

The first node in your pipeline should specify the argument that will be
passed into the pipeline when we execute it (More on this below).

Note outputs of a Splitter are accessible by specifying the name of the
splitter component (In this case `Splitter`) suffixed with the outgoing
edge in the format `.output_{i}`.

``` r
pipeline = Pipeline()

pipeline = pipeline |>
  add_node(component = read.csv, name = "Reader", input = "file") |>
  add_node(component = Splitter(), name = "Splitter", input = "Reader") |>
  add_node(component = subset_data, name = "Subsetter", input = "Splitter.output_2") |>
  add_node(component = summarizer, name = "Summarizer", input = "Splitter.output_1")
```

We can easily visualize our pipeline using the `draw` method.

``` r
draw(pipeline)
```

![](man/figures/pipeline-vis.png)

Here we execute the pipeline with the `run` command. It is important to
note that the argument you pass to run should match the `input` argument
of your first node in your pipeline. In this case we are passing a
`file` argument in `run` and similarly our first node is set to receive
a `file` argument as input.

You may choose any argument name you like, as long as these two
arguments match!

``` r
result = run(pipeline, file = 'temp.csv')
```

We can now access the results of our terminating nodes. A terminating
node is any node that is not specified as input. By default when the
pipeline is run, each node will overwrite the output of its input node.
Therefore any node that is not fed forward to a new node will return
output. In the case of this pipeline, the `Subsetter` and `Summarizer`
edges are our terminating nodes. Therefore, we can access their results
in the `outputs` object of the pipeline

``` r
result$outputs$Subsetter
#>                 X  mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> 1       Mazda RX4 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> 2   Mazda RX4 Wag 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> 4  Hornet 4 Drive 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> 6         Valiant 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> 10       Merc 280 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
#> 11      Merc 280C 17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
#> 30   Ferrari Dino 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
```

``` r
result$outputs$Summarizer
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    71.1   120.8   196.3   230.7   326.0   472.0
```

## Multiple Entrypoints

It is also possible to pass in multiple entrypoints by specifying the
inputs in your arguments. This allows you to process multiple documents
and bring them together using a `Joiner`. The `Joiner` will take 2
inputs and convert them to a single output in the pipeline according to
the function specified. This component works nicely for `dplyr`-like
joins, but is not restricted to these methods.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following object is masked from 'package:testthat':
#> 
#>     matches
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
pipeline = Pipeline()
pipeline = pipeline |>
  add_node(read.csv, name = "Reader", input = "file") |>
  add_node(subset_data, name = "Subsetter", input = "data") |>
  add_node(Joiner(method = "bind_rows"), name = "Joiner", input = c("Reader", "Subsetter"))

output = run(pipeline, file = "temp.csv", data = mtcars)
output$outputs$Joiner
#>                                  X  mpg cyl  disp  hp drat    wt  qsec vs am
#> ...1                     Mazda RX4 21.0   6 160.0 110 3.90 2.620 16.46  0  1
#> ...2                 Mazda RX4 Wag 21.0   6 160.0 110 3.90 2.875 17.02  0  1
#> ...3                    Datsun 710 22.8   4 108.0  93 3.85 2.320 18.61  1  1
#> ...4                Hornet 4 Drive 21.4   6 258.0 110 3.08 3.215 19.44  1  0
#> ...5             Hornet Sportabout 18.7   8 360.0 175 3.15 3.440 17.02  0  0
#> ...6                       Valiant 18.1   6 225.0 105 2.76 3.460 20.22  1  0
#> ...7                    Duster 360 14.3   8 360.0 245 3.21 3.570 15.84  0  0
#> ...8                     Merc 240D 24.4   4 146.7  62 3.69 3.190 20.00  1  0
#> ...9                      Merc 230 22.8   4 140.8  95 3.92 3.150 22.90  1  0
#> ...10                     Merc 280 19.2   6 167.6 123 3.92 3.440 18.30  1  0
#> ...11                    Merc 280C 17.8   6 167.6 123 3.92 3.440 18.90  1  0
#> ...12                   Merc 450SE 16.4   8 275.8 180 3.07 4.070 17.40  0  0
#> ...13                   Merc 450SL 17.3   8 275.8 180 3.07 3.730 17.60  0  0
#> ...14                  Merc 450SLC 15.2   8 275.8 180 3.07 3.780 18.00  0  0
#> ...15           Cadillac Fleetwood 10.4   8 472.0 205 2.93 5.250 17.98  0  0
#> ...16          Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0
#> ...17            Chrysler Imperial 14.7   8 440.0 230 3.23 5.345 17.42  0  0
#> ...18                     Fiat 128 32.4   4  78.7  66 4.08 2.200 19.47  1  1
#> ...19                  Honda Civic 30.4   4  75.7  52 4.93 1.615 18.52  1  1
#> ...20               Toyota Corolla 33.9   4  71.1  65 4.22 1.835 19.90  1  1
#> ...21                Toyota Corona 21.5   4 120.1  97 3.70 2.465 20.01  1  0
#> ...22             Dodge Challenger 15.5   8 318.0 150 2.76 3.520 16.87  0  0
#> ...23                  AMC Javelin 15.2   8 304.0 150 3.15 3.435 17.30  0  0
#> ...24                   Camaro Z28 13.3   8 350.0 245 3.73 3.840 15.41  0  0
#> ...25             Pontiac Firebird 19.2   8 400.0 175 3.08 3.845 17.05  0  0
#> ...26                    Fiat X1-9 27.3   4  79.0  66 4.08 1.935 18.90  1  1
#> ...27                Porsche 914-2 26.0   4 120.3  91 4.43 2.140 16.70  0  1
#> ...28                 Lotus Europa 30.4   4  95.1 113 3.77 1.513 16.90  1  1
#> ...29               Ford Pantera L 15.8   8 351.0 264 4.22 3.170 14.50  0  1
#> ...30                 Ferrari Dino 19.7   6 145.0 175 3.62 2.770 15.50  0  1
#> ...31                Maserati Bora 15.0   8 301.0 335 3.54 3.570 14.60  0  1
#> ...32                   Volvo 142E 21.4   4 121.0 109 4.11 2.780 18.60  1  1
#> Mazda RX4                     <NA> 21.0   6 160.0 110 3.90 2.620 16.46  0  1
#> Mazda RX4 Wag                 <NA> 21.0   6 160.0 110 3.90 2.875 17.02  0  1
#> Hornet 4 Drive                <NA> 21.4   6 258.0 110 3.08 3.215 19.44  1  0
#> Valiant                       <NA> 18.1   6 225.0 105 2.76 3.460 20.22  1  0
#> Merc 280                      <NA> 19.2   6 167.6 123 3.92 3.440 18.30  1  0
#> Merc 280C                     <NA> 17.8   6 167.6 123 3.92 3.440 18.90  1  0
#> Ferrari Dino                  <NA> 19.7   6 145.0 175 3.62 2.770 15.50  0  1
#>                gear carb
#> ...1              4    4
#> ...2              4    4
#> ...3              4    1
#> ...4              3    1
#> ...5              3    2
#> ...6              3    1
#> ...7              3    4
#> ...8              4    2
#> ...9              4    2
#> ...10             4    4
#> ...11             4    4
#> ...12             3    3
#> ...13             3    3
#> ...14             3    3
#> ...15             3    4
#> ...16             3    4
#> ...17             3    4
#> ...18             4    1
#> ...19             4    2
#> ...20             4    1
#> ...21             3    1
#> ...22             3    2
#> ...23             3    2
#> ...24             3    4
#> ...25             3    2
#> ...26             4    1
#> ...27             5    2
#> ...28             5    2
#> ...29             5    4
#> ...30             5    6
#> ...31             5    8
#> ...32             4    2
#> Mazda RX4         4    4
#> Mazda RX4 Wag     4    4
#> Hornet 4 Drive    3    1
#> Valiant           3    1
#> Merc 280          4    4
#> Merc 280C         4    4
#> Ferrari Dino      5    6
```

Using these three components (`Nodes`, `Splitters` and `Joiners`) you
can construct very complex data pipelines and run them in a single call.

# Why sewage?

What is the point of `{sewage}` over more robust orchestrations tools
like `{targets}` or Airflow? First, `sewage` is not an orchestration
tool. Its primary purpose is to help modularize and organize complex
data analysis scripts. If you feel comfortable using packages like
{targets} or {airflow} you probably should.
