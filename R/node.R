Node = function(input, call, name) {
  out = init_node()
  return(out)
}

init_node = function(envir = parent.frame()) {
  node = list(
    name = envir$name,
    input = envir$input,
    call = envir$call
  )

  structure(node, class = "sewage_node")

  return(node)
}

execute_node = function(node, envir = parent.frame()) {
  outputs = envir$pipeline$outputs
  input = node[['input']]
  call = node$call
  call[[2]] = outputs[[input]]
  output = eval(call)

  name = node$name

  envir$pipeline$outputs = list(name = output)
  names(envir$pipeline$outputs) = c(name)

  return(envir$pipeline)
}

is_node = function(x) {
  inherits(x, "sewage_node")
}



