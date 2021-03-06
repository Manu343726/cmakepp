# calculates and returns the checksum for the specified string
# uses md5 as a default, other algorithms are possible (see string or file for algorithm names)
function(checksum_string str)
  set(args ${ARGN})
  list_extract(args checksum_alg)
  if(NOT checksum_alg)
    set(checksum_alg MD5)
  endif()
 # message("string(\"${checksum_alg}\"  \"${str}\" checksum)")
  string("${checksum_alg}"  checksum "${str}" )
  return_ref(checksum)
endfunction()