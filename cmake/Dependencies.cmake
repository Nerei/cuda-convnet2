# ---[ Threads
find_package(Threads REQUIRED)

# --[ CUDA
find_package(CUDA 5.5 REQUIRED)
message(STATUS "CUDA detected: " ${CUDA_VERSION})

include_directories(SYSTEM ${CUDA_INCLUDE_DIRS} ${CUDA_SDK_ROOT_DIR}/common/inc)
include_directories(SYSTEM ${CUDA_TOOLKIT_ROOT_DIR}/samples/common/inc)
list(APPEND CUDA_LIBRARIES ${CUDA_CUBLAS_LIBRARIES})

set(convnet2_known_gpu_archs "20 21(20) 30 35 50")
convnet2_select_nvcc_arch_flags(NVCC_FLAGS_EXTRA)
list(APPEND CUDA_NVCC_FLAGS ${NVCC_FLAGS_EXTRA})
message(STATUS "Added CUDA NVCC flags for: ${NVCC_FLAGS_EXTRA_readable}")

# ---[ Python
find_package(PythonInterp 2.7)
find_package(PythonLibs 2.7)
find_package(NumPy 1.7.1)
include_directories(SYSTEM ${PYTHON_INCLUDE_DIRS} ${NUMPY_INCLUDE_DIR}/numpy)

# ---[ OpenCV
find_package(OpenCV QUIET COMPONENTS core highgui imgproc imgcodecs)
if(NOT OpenCV_FOUND) # if not OpenCV 3.x, then imgcodecs are not found
  find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc)
endif()
message(STATUS "OpenCV found (${OpenCV_CONFIG_PATH})")

 # ---[ BLAS
if(NOT APPLE)
  set(BLAS "Atlas" CACHE STRING "Selected BLAS library")
  set_property(CACHE BLAS PROPERTY STRINGS "Atlas;Open;MLK")

  if(BLAS STREQUAL "Atlas" OR BLAS STREQUAL "atlas")
    find_package(Atlas REQUIRED)
    include_directories(SYSTEM ${Atlas_INCLUDE_DIR})
    list(APPEND ConvNet2_LINKER_LIBS ${Atlas_LIBRARIES})
  elseif(BLAS STREQUAL "Open" OR BLAS STREQUAL "open")
    find_package(OpenBLAS REQUIRED)
    include_directories(SYSTEM ${OpenBLAS_INCLUDE_DIR})
    list(APPEND ConvNet2_LINKER_LIBS ${OpenBLAS_LIB})
  elseif(BLAS STREQUAL "MLK" OR BLAS STREQUAL "mkl")
    find_package(MKL REQUIRED)
    include_directories(SYSTEM ${MKL_INCLUDE_DIR})
    list(APPEND ConvNet2_LINKER_LIBS ${MKL_LIBRARIES})
  endif()
elseif(APPLE)
  find_package(vecLib REQUIRED)
  include_directories(SYSTEM ${vecLib_INCLUDE_DIR})
  list(APPEND ConvNet2_LINKER_LIBS ${vecLib_LINKER_LIBS})
endif()
