function(ast_parse_sequence definition stream create_node)
  map_tryget("${definition}" sequence sequence)
  if(NOT sequence)
    return(false)
  endif()
  # deref ref array
  ref_get(${sequence} sequence)
  
  # save current stream
  stream_push(${stream})

  # empty var for sequence
  set(ast_sequence)

  # loop through all definitions in sequence
  # adding all resulting nodes in order to ast_sequence
  foreach(def ${sequence})
    ast_parse(${stream} "${def}")
    ans(res)
    if(NOT res)
      stream_pop(${stream})
      return(false)
    endif()
    map_isvalid(${res} ismap)
    if(ismap)
      list(APPEND ast_sequence ${res})
    endif()
  endforeach()
  # return result
  if(NOT create_node)
    return(true)
  endif()
  map_create(node)
  list_new(lst)
  ref_set(${lst} ${ast_sequence})
  map_set(${node} children ${lst})
  return(${node})
endfunction()