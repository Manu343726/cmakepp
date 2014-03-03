message("${CMAKE_CURRENT_LIST_DIR}/oo-cmake.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/oo-cmake.cmake")
file(GLOB tests  "${CMAKE_CURRENT_LIST_DIR}/tests/*")


foreach(test ${tests})
	import_function("${test}" as test_function REDEFINE)
	message(STATUS "running test ${test}... ")
	test_function()
	message(STATUS "success!")
endforeach()