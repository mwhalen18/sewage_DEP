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
#' @param ... parameter to pass to first node of the pipeline. This should match the \code{input} parameter of \code{add_node} of the first node.
#' @export
run = function(pipeline, ...) {

  if(!is_pipeline(pipeline)) {
    stop("pipeline object must be of type 'sewage_pipeline'")
  }

  dots = list(...)

  arg = names(dots)[1]
  value = dots[[arg]]

  pipeline[['outputs']] = list(arg = value)
  names(pipeline$outputs) = c(arg)

  nodes = pipeline$nodes

  for(node in nodes) {
    pipeline = execute_node(node)
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

