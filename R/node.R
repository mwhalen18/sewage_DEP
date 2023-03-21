Node = function(input, call, name) {
  out = init_node()
  attr(out, "class") = "sewage_node"
  return(out)
}

init_node = function(envir = parent.frame()) {
  node = list(
    name = envir$name,
    input = envir$input,
    call = envir$call
  )

  return(node)
}

is_node = function(x) {
  inherits(x, "sewage_node")
}

#' Initialize a splitter objects
#' @param edges number out outputs. Must be greater than 1
#' @export
Splitter = function(edges = 2) {
  if(edges <= 1) {
    stop("edges must be > 1")
  }
  out = init_splitter()
  return(out)
}

init_splitter = function(envir = parent.frame()) {
  splitter = list(
    edges = envir$edges
  )

  attr(splitter, "class") = "sewage_splitter"

  return(splitter)
}

is_splitter = function(x) {
  inherits(x, "sewage_splitter")
}


#' execute a pipeline component
#' @param x component node to be executed
#' @param envir calling environment
#' @export
execute = function(x, envir) {
  UseMethod("execute", x)
}

#' @export
execute.sewage_splitter = function(x, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input  = x[['input']]

  output = list()

  for(i in 1:x$edges) {
    output[[i]] = outputs[[input]]
  }

  names(output) = paste0(x$name, ".output_", 1:x$edges)

  out = c(outputs, output)
  out[[input]] = NULL

  envir$pipeline$outputs = out

  return(envir$pipeline)
}

#' @export
execute.sewage_node = function(x, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input = x[['input']]
  call = x$call
  call[[2]] = outputs[[input]]
  output = eval(call, envir = parent.frame(n = 2))

  output = list(name = output)
  names(output) = x$name

  out = c(outputs, output)
  out[[input]] = NULL


  envir$pipeline$outputs = out

  return(envir$pipeline)
}


