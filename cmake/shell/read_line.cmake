# reads a line from the console.  
#  uses .bat file on windows else uses shell script file .sh
function(read_line)
  file_tmp("txt" "")
  ans(value_file)

  if(WIN32)
    # thanks to Fraser999 for fixing whis to dissallow variable expansion and whitespace stripping
    # etc. See merge comments
    file_tmp("bat" "@echo off\nsetlocal EnableDelayedExpansion\nset val=\nset /p val=\necho !val!> \"${value_file}\"")
    ans(shell_script)
  else()
    file_tmp("sh" "#!/bin/bash\nread text\necho -n $text>${value_file}")
    ans(shell_script)
    # make script executable
    execute_process(COMMAND "chmod" "+x" "${shell_script}")
  endif()

  # execute shell script which write the keyboard input to the ${value_file}
  execute_process(COMMAND "${shell_script}")

  # read value file
  file(READ "${value_file}" line)

  # strip trailing '\n' which might get added by the shell script. as there is no way to input \n at the end 
  # manually this does not change for any system
  if("${line}" MATCHES "(\n|\r\n)$")
    string(REGEX REPLACE "(\n|\r\n)$" "" line "${line}")
  endif()

  # remove temp files
  file(REMOVE "${shell_script}")
  file(REMOVE "${value_file}")
  return_ref(line)
endfunction()
