#' add node to a sewage pipeline
#'
#' `add_node()` will place a new node in the specified pipeline. This will be executed sequentially when the pipeline is executed using `run()`
#' @param pipeline an initialized  sewage pipeline
#' @param component a function to be executed. Must be a valid function specification
#' @param name a name to give to the given component. This will be used as the `input` parameter for downstream nodes
#' @param input the node to use as input into `component`. Input must already be specified in the pipeline. Inputs that create circular dependencies will throw an error.
#' @param ... additional arguments to be passed to the `component` argument
#' @returns a `sewage_pipeline` object
#' @export
add_node = function(pipeline, component, name, input, ...) {
  if (!is_pipeline(pipeline)) {
    stop("'pipeline' must be of class 'sewage_pipeline'")
  }


  if (is.character(component)) {
    stop("component cannot be a character. You should convert your function to a symbol (see as.symbol())")
  }

  if (!is.character("name")) {
    stop("name must be a character string")
  }

  dots = list(...)
  captured_component = substitute(component)

  pipeline = add_component_to_pipeline(component)
  return(pipeline)
}

# -----------------------------------------------------

#' add a base component to a specified pipeline
#' @param component an object o either `Node` or `Splitter`
#' @param envir calling environment. Used for construction of calls from the pipeline entry
#' @export
add_component_to_pipeline = function(component, envir) {
  UseMethod("add_component_to_pipeline", component)
}


#' @export
add_component_to_pipeline.function = function(component, envir = parent.frame()) {
  call = construct_caller(envir = envir)
  node = Node(
    name = envir$name,
    input = envir$input,
    call = call
  )

  envir$pipeline[['nodes']][[envir$name]] = node
  return(envir$pipeline)
}

#' @export
add_component_to_pipeline.sewage_splitter = function(component, envir = parent.frame()) {
  component$input = envir$input
  component$name = envir$name

  envir$pipeline[['nodes']][[envir$name]] = component
  return(envir$pipeline)
}

#' @export
add_component_to_pipeline.sewage_joiner = function(component, envir = parent.frame()) {
  component$input = envir$input
  component$name = envir$name

  .FUN = as.name(component$method)
  args = c(list(.FUN), envir$input[1], envir$input[2], envir$dots)

  component$call = as.call(args)

  envir$pipeline[['nodes']][[envir$name]] = component

  return(envir$pipeline)
}

# -----------------------------------------------------

construct_caller = function(envir = parent.frame()) {
  .FUN = envir$captured_component
  input = envir$input
  dots = envir$dots

  args = c(list(.FUN), input, dots)

  as.call(args)
}
