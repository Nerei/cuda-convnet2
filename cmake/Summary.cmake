################################################################################################
# ConvNet status report function.
# Automatically align right column and selects text based on condition.
# Usage:
#   convnet2_status(<text>)
#   convnet2_status(<heading> <value1> [<value2> ...])
#   convnet2_status(<heading> <condition> THEN <text for TRUE> ELSE <text for FALSE> )
function(convnet2_status text)
  set(status_cond)
  set(status_then)
  set(status_else)

  set(status_current_name "cond")
  foreach(arg ${ARGN})
    if(arg STREQUAL "THEN")
      set(status_current_name "then")
    elseif(arg STREQUAL "ELSE")
      set(status_current_name "else")
    else()
      list(APPEND status_${status_current_name} ${arg})
    endif()
  endforeach()

  if(DEFINED status_cond)
    set(status_placeholder_length 23)
    string(RANDOM LENGTH ${status_placeholder_length} ALPHABET " " status_placeholder)
    string(LENGTH "${text}" status_text_length)
    if(status_text_length LESS status_placeholder_length)
      string(SUBSTRING "${text}${status_placeholder}" 0 ${status_placeholder_length} status_text)
    elseif(DEFINED status_then OR DEFINED status_else)
      message(STATUS "${text}")
      set(status_text "${status_placeholder}")
    else()
      set(status_text "${text}")
    endif()

    if(DEFINED status_then OR DEFINED status_else)
      if(${status_cond})
        string(REPLACE ";" " " status_then "${status_then}")
        string(REGEX REPLACE "^[ \t]+" "" status_then "${status_then}")
        message(STATUS "${status_text} ${status_then}")
      else()
        string(REPLACE ";" " " status_else "${status_else}")
        string(REGEX REPLACE "^[ \t]+" "" status_else "${status_else}")
        message(STATUS "${status_text} ${status_else}")
      endif()
    else()
      string(REPLACE ";" " " status_cond "${status_cond}")
      string(REGEX REPLACE "^[ \t]+" "" status_cond "${status_cond}")
      message(STATUS "${status_text} ${status_cond}")
    endif()
  else()
    message(STATUS "${text}")
  endif()
endfunction()


################################################################################################
# Function for fetching ConvNet version from git and headers
# Usage:
#   convnet2_extract_convnet2_version()
function(convnet2_extract_convnet2_version)
  set(ConvNet_GIT_VERSION "unknown")
  find_package(Git)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
                    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
                    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                    OUTPUT_VARIABLE ConvNet_GIT_VERSION
                    RESULT_VARIABLE __git_result)
    if(NOT ${__git_result} EQUAL 0)
      set(ConvNet_GIT_VERSION "unknown")
    endif()
  endif()

  set(ConvNet_GIT_VERSION ${ConvNet_GIT_VERSION} PARENT_SCOPE)
endfunction()


################################################################################################
# Prints accumulatd caffe configuration summary
# Usage:
#   confnet2_print_configuration_summary()
function(confnet2_print_configuration_summary)
  convnet2_extract_convnet2_version()

  convnet2_merge_flag_lists(__flags_rel CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS)
  convnet2_merge_flag_lists(__flags_deb CMAKE_CXX_FLAGS_DEBUG   CMAKE_CXX_FLAGS)

  convnet2_status("")
  convnet2_status("******************* ConvNet Configuration Summary *******************")
  convnet2_status("General:")
  convnet2_status("  Git               :   ${ConvNet_GIT_VERSION}")
  convnet2_status("  System            :   ${CMAKE_SYSTEM_NAME}")
  convnet2_status("  C++ compiler      :   ${CMAKE_CXX_COMPILER}")
  convnet2_status("  Release CXX flags :   ${__flags_rel}")
  convnet2_status("  Debug CXX flags   :   ${__flags_deb}")
  convnet2_status("  ADD_profiler      :   ${ADD_profiler}")

convnet2_option(USE_numpy_for_util  "Build libutilpy.so with numpy interface" ON)
convnet2_option(ADD_profiler  "Add profiler output" OFF)
  convnet2_status("")
  convnet2_status("Dependencies:")
  convnet2_status("  BLAS              : " APPLE THEN "Yes (vecLib)" ELSE "Yes (${BLAS})")
  convnet2_status("  OpenCV            :   Yes (ver. ${OpenCV_VERSION})")
  convnet2_status("  CUDA              : " CUDA_FOUND THEN "Yes (ver. ${CUDA_VERSION})" ELSE "No" )
  convnet2_status("")

  convnet2_status("NVIDIA CUDA:")
  convnet2_status("  Target GPU(s)     :   ${CUDA_ARCH_NAME}" )
  convnet2_status("  GPU arch(s)       :   ${NVCC_FLAGS_EXTRA_readable}")
  convnet2_status("")

  convnet2_status("Python:")
  convnet2_status("  Interpreter       :" PYTHON_EXECUTABLE THEN "${PYTHON_EXECUTABLE} (ver. ${PYTHON_VERSION_STRING})" ELSE "No")
  convnet2_status("  Libraries         :" PYTHONLIBS_FOUND  THEN "${PYTHON_LIBRARIES} (ver ${PYTHONLIBS_VERSION_STRING})" ELSE "No")
  convnet2_status("  NumPy             :" NUMPY_FOUND  THEN "${NUMPY_INCLUDE_DIR} (ver ${NUMPY_VERSION})" ELSE "No")
  convnet2_status("")
endfunction()

