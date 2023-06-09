#' Initialize a sewage Pipeline
#' @export
#' @returns A sewage pipeline object
Pipeline = function() {
  out = init_pipeline()
  return(out)
}

#' Run a pipeline
#'
#' This function is the extry point for executing a pipeline object
#' @param pipeline an initialized pipeline object
#' @param ... parameter(s) to pass to first node of the pipeline. This should match the `input` parameter of `add_node` of the first node. In the case that you have multiple inputs, each argument should match the name of a starting node in your pipeline.
#' @export
run = function(pipeline, ...) {

  if(!is_pipeline(pipeline)) {
    stop("pipeline object must be of type 'sewage_pipeline'")
  }

  dots = list(...)

  pipeline[['outputs']] = dots
  names(pipeline$outputs) = names(dots)

  nodes = pipeline$nodes

  for(node in nodes) {
    pipeline = execute(node)
  }

  return(pipeline)

}

init_pipeline = function() {
  pipeline = list(
    initialized = Sys.time(),
    nodes = list(),
    outputs = list()
  )
  structure(pipeline, class = "sewage_pipeline")
}

is_pipeline = function(x) {
  inherits(x, 'sewage_pipeline')
}

