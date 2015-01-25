cmake_minimum_required(VERSION 2.8.8)

# ---[ ConvNet project
project(cuda_convnet2 C CXX)

# ---[ Using cmake scripts and modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(cmake/Utils.cmake)
include(cmake/Misc.cmake)
include(cmake/Summary.cmake)

# ---[ Options
convnet2_option(ADD_profiler  "Add profiler output" OFF)

# ---[ Dependencies
include(cmake/Dependencies.cmake)

# ---[ Flags
if(UNIX OR APLE)
  list(APPEND CMAKE_CXX_FLAGS -fPIC)
  list(APPEND CUDA_NVCC_FLAGS -Xcompiler -fPIC)
endif()

if(ADD_profiler)
  list(APPEND CUDA_NVCC_FLAGS --ptxas-options=-v)
endif()

add_definitions(-DNUMPY_INTERFACE)
#add_definitions(-DNPY_NO_DEPRECATED_API=7) # TODO: can't use this, need to fix code

# ---[ libutilpy
file(GLOB_RECURSE srcs util/*.cpp util/*.h*)
add_library(utilpy SHARED ${srcs})
target_link_libraries(utilpy ${PYTHON_LIBRARIES} ${Atlas_LIBRARIES} -Wl,-no-undefined)
confnet2_add_simlink_postbuild(utilpy util)

# ---[ libnvmatrix
file(GLOB_RECURSE srcs nvmatrix/*.cu nvmatrix/*.cuh)
cuda_add_library(nvmatrix SHARED ${srcs})
target_link_libraries(nvmatrix ${CUDA_LIBRARIES} utilpy)
confnet2_add_simlink_postbuild(nvmatrix nvmatrix)

# ---[ libcudaconv
file(GLOB_RECURSE srcs cudaconv3/*.cu cudaconv3/*.cuh)
cuda_add_library(cudaconv SHARED ${srcs})
target_link_libraries(cudaconv ${CUDA_LIBRARIES} nvmatrix)
confnet2_add_simlink_postbuild(cudaconv cudaconv3)

# ---[ _ConvNet
file(GLOB_RECURSE srcs cudaconvnet/src/*.c* cudaconvnet/*.cuh cudaconvnet/*.h* )
cuda_add_library(_ConvNet SHARED ${srcs})
set_target_properties(_ConvNet PROPERTIES PREFIX "")
target_link_libraries(_ConvNet ${CUDA_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT} ${PYTHON_LIBRARIES} cudaconv -ljpeg)
confnet2_add_simlink_postbuild(_ConvNet cudaconvnet)

# ---[ _MakeDataPyExt
include_directories(SYSTEM ${OpenCV_INCLUDE_DIRS})
file(GLOB_RECURSE srcs make-data/pyext/*.cpp make-data/pyext/*.h)
add_library(_MakeDataPyExt SHARED ${srcs})
set_target_properties(_MakeDataPyExt PROPERTIES PREFIX "")
target_link_libraries(_MakeDataPyExt ${PYTHON_LIBRARIES} ${OpenCV_LIBS} ${CMAKE_THREAD_LIBS_INIT} -Wl,-no-undefined)
confnet2_add_simlink_postbuild(_MakeDataPyExt make-data/pyext)

# ---[ configuration summary
confnet2_print_configuration_summary()
