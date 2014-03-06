function(json_serialize result value)
	# indent
	if(ARGN)
		set(args ${ARGN})
		list(FIND args "INDENTED" idx)
		if(NOT ${idx} LESS 0)
			json_serialize(json "${value}")
			json_tokenize(tokens "${json}")
			json_format_tokens(indented "${tokens}")
			set(${result} "${indented}" PARENT_SCOPE)
			return()
		endif()	
	endif()


	# if value is empty return an empty string
	if(NOT value)
		set(${result} PARENT_SCOPE)
		return()
	endif()
	# if value is a not ref return a simple string value
	ref_isvalid("${value}" is_ref)
	if(NOT is_ref)
		json_escape(value "${value}")
		set(${result} "\"${value}\"" PARENT_SCOPE)
		return()
	endif()

	# get ref type
	# here map, list and * will be differantited
	# resulting object, array and string respectively
	set(ref_type)
	ref_gettype(${value} ref_type)
	if("${ref_type}" STREQUAL map)
		set(res)
		map_keys(${value} keys)
		foreach(key ${keys})
			map_get(${value} val ${key})	
			json_serialize(serialized_value "${val}" ${indent})				
			set(res "${res},\"${key}\":${serialized_value}")
		endforeach()
		string(LENGTH "${res}" len)
		if(${len} GREATER 0)
			string(SUBSTRING "${res}" 1 -1 res)
		endif()
		
			set(res "{${res}}")
	
		set(${result} "${res}" PARENT_SCOPE )
		return()
	elseif("${ref_type}" STREQUAL list)
		ref_get( ${value} lst)
		set(res "")
		foreach(val ${lst})
			json_serialize(serialized_value "${val}" ${indent})
			set(res "${res},${serialized_value}")				
		endforeach()	

		string(LENGTH "${res}" len)
		if(${len} GREATER 0)				
			string(SUBSTRING "${res}" 1 -1  res)
		endif()
		set(res "[${res}]")
		set(${result} ${res} PARENT_SCOPE)
		return()
	else()			
		ref_get( ${value} ref_value)

		json_escape(ref_value "${ref_value}")
		set(${result} "\"${ref_value}\"" PARENT_SCOPE)
		return()
	endif()
endfunction()