
#' add node to a sewage pipeline
#'
#' `add_node()` will place a new node in the specified pipeline. This will be executed sequentially when the pipeline is executed using `run()`
#' @param pipeline an initialized  sewage pipeline
#' @param component a function to be executed. Must be a valid function specification
#' @param input the node to use as input into `component`. Input must already be specified in the pipeline. Inputs that create circular dependencies will throw an error.
#' @returns a `sewage_pipeline` object
#' @export
add_node = function(pipeline, component, name, input, ...) {
  if (!is_pipeline(pipeline)) {
    stop("'pipeline' must be of class 'sewage_pipeline'")
  }

  if (!is.function(component)) {
    if (is.character(component)) {
      stop("component cannot be a character. You should convert your function to a symbol (see as.symbol())")
    } else {
      stop("component must be function")
    }
  }

  if (!is.character("name")) {
    stop("name must be a character string")
  }

  dots = list(...)
  captured_component = substitute(component)
  call = construct_caller()

  node = Node(
    name = name,
    input = input,
    call = call
  )

  pipeline = add_node_to_pipeline(pipeline, name, node)

  return(pipeline)
}

add_node_to_pipeline = function(pipeline, name, node, ...) {
  pipeline[['nodes']][[name]] = node
  return(pipeline)
}

construct_caller = function(envir = parent.frame()) {
  .FUN = envir$captured_component
  input = envir$input
  dots = envir$dots

  args = c(as.list(.FUN), input, dots)

  as.call(args)
}
