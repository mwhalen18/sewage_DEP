
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

Below is an exmaple of a simple pipelime that can be constructed.

``` r
library(sewage)
pipeline = Pipeline()
```

``` r
pipeline = pipeline$add_node(component = read_file, name = 'ingest', input = '[START]')
pipeline = pipeline$add_node(component = clean_data, name = 'clean', input = 'ingest')
pipeline = pipeline$splitter(edges = 2, name = 'Splitter', input = 'clean')
pipeline = pipeline$add_node(component = transform_data, name = 'transform', input = 'Splitter.output_1')
pipeline = pipeline$add_node(component = histogram, name = 'eda', input = 'Splitter.output_2')
pipeline = pipeline$add_node(component = process_data, name = 'processor', input = 'transform')
```

``` r
output = plunge(pipeline, input = mtcars)
```

``` r
output[['processor']]
```

``` r
output[['eda']]
```

# Why sewage?

What is the point of `{sewage}` over more robust ETL pipelining tools
like `{targets}` or Airflow? Honestly, if you feel comfortable using
more heavy-weight tools you should. This package privides a light-weight
interface to visualize and organize complex
cleaning/processing/visualization scripts.
