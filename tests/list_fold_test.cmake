function(test)


   set(mylist 1 2 3 4 5)
  function(foldr a b)
    return_math("${a} + ${b}")
  endfunction()
  list_fold(mylist "foldr")
  ans(res)
  assert("${res}" EQUAL 15)

endfunction()