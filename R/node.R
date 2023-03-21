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

execute.sewage_node = function(node, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input = node[['input']]
  call = node$call
  call[[2]] = outputs[[input]]
  output = eval(call, envir = parent.frame(n = 2))

  output = list(name = output)
  names(output) = node$name

  out = c(outputs, output)
  out[[input]] = NULL

  # name = node$name

  envir$pipeline$outputs = out
  #names(envir$pipeline$outputs) = c(name)

  return(envir$pipeline)
}

execute.sewage_splitter = function(splitter, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input  = splitter[['input']]

  output = list()

  for(i in 1:splitter$edges) {
    output[[i]] = outputs[[input]]
  }

  names(output) = paste0(splitter$name, ".output_", 1:splitter$edges)

  out = c(outputs, output)
  out[[input]] = NULL

  envir$pipeline$outputs = out

  return(envir$pipeline)
}


execute = function(x, ...) {
  UseMethod("execute", x)
}
