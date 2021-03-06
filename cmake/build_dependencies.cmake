include (ExternalProject)
include(CheckFunctionExists)

if(NOT GRPC_VERSION)
    set(GRPC_VERSION v1.30.1)
endif()

if(ANDROID)
    set(GRPC_ANDROID_ARGS
        -DRUN_HAVE_STD_REGEX=0
        -DRUN_HAVE_POSIX_REGEX=0
        -DRUN_HAVE_STEADY_CLOCK=0
        -DCMAKE_EXE_LINKER_FLAGS=-llog
    )
endif()


set(GRPC_SRC_PATH ${CMAKE_CURRENT_BINARY_DIR}/grpc_ext-prefix/src/grpc_ext)

if(NOT MSVC)
    set(gRPC_ZLIB_PROVIDER package)
else()
    set(gRPC_ZLIB_PROVIDER module)
endif()

ExternalProject_Add(grpc_ext
    GIT_REPOSITORY "https://github.com/grpc/grpc"
    GIT_TAG ${GRPC_VERSION}
    GIT_SHALLOW 1
    PATCH_COMMAND ""
    UPDATE_COMMAND ""
    BUILD_IN_SOURCE 0
    CMAKE_ARGS
     -DANDROID_PLATFORM=${ANDROID_PLATFORM}
     -DANDROID_ABI=${ANDROID_ABI}
     -DANDROID_STL=${ANDROID_STL}
     -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
     -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
     -DCMAKE_STAGING_PREFIX=${CMAKE_STAGING_PREFIX}
     -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
     -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
     -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
     -DCMAKE_ASM_NASM_COMPILER=${CMAKE_ASM_NASM_COMPILER}
     -DgRPC_INSTALL=ON
     -DgRPC_BUILD_CODEGEN=ON
     -DgRPC_BUILD_CSHARP_EXT=ON
     -DgRPC_ZLIB_PROVIDER=${gRPC_ZLIB_PROVIDER}
     ${GRPC_ANDROID_ARGS}
)
set(_GRPC_SRC_PATH ${CMAKE_BINARY_DIR}/grpc_ext-prefix/src/grpc_ext)

set(_GRPC_LIBRARIES_DIR ${_GRPC_SRC_PATH}-build)

set(_ABSL_LIBRARIES
    absl_bad_optional_access
    absl_str_format_internal
    absl_time
    absl_time_zone
    absl_civil_time
    absl_strings
    absl_strings_internal
    absl_throw_delegate
    absl_int128
    absl_base
    absl_spinlock_wait
    absl_raw_logging_internal
    absl_log_severity
    absl_dynamic_annotations
)

set(_SSL_LIBRARIES_DIRS
    ${_GRPC_SRC_PATH}-build/third_party/boringssl/crypto
    ${_GRPC_SRC_PATH}-build/third_party/boringssl/ssl
)
set(_SSL_LIBRARIES ssl crypto)

if(NOT MSVC)
    set(_ZLIB_LIBRARIES z)
else()
	if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		set(_ZLIB_LIBRARIES zlibstaticd)
	else()
		set(_ZLIB_LIBRARIES zlibstatic)
	endif()
endif()

if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    set(PROTOBUF_LIB protobufd)
else()
    set(PROTOBUF_LIB protobuf)
endif()
if(MSVC)
    set(PROTOBUF_LIB lib${PROTOBUF_LIB})
endif()
set(_PROTOBUF_LIBRARIES ${PROTOBUF_LIB})


if(MSVC)
    if(${TARGET_ARCH} STREQUAL "x86_64")
        set(_PORTAUDIO_LIB portaudio_x64)
	else()
        set(_PORTAUDIO_LIB portaudio_${TARGET_ARCH})
	endif()
else()
    set(_PORTAUDIO_LIB portaudio)
endif()

if(NOT ANDROID)
    ExternalProject_Add(portaudio_ext
        GIT_REPOSITORY https://git.assembla.com/portaudio.git
        GIT_TAG master
        GIT_SHALLOW 1
        UPDATE_COMMAND ""
        BUILD_IN_SOURCE 0
        CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_STAGING_PREFIX=${CMAKE_STAGING_PREFIX}
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DPA_ENABLE_DEBUG_OUTPUT=OFF
        -DPA_BUILD_EXAMPLES=ON
        -DPA_BUILD_TESTS=ON
        -DPA_DISABLE_INSTALL=OFF
    )
else()
    ExternalProject_Add(portaudio_ext
        GIT_REPOSITORY https://github.com/Gundersanne/portaudio_opensles.git
        GIT_TAG master
        GIT_SHALLOW 1
        UPDATE_COMMAND ""
        BUILD_IN_SOURCE 0
        CMAKE_ARGS
        -DANDROID_PLATFORM=${ANDROID_PLATFORM}
        -DANDROID_ABI=${ANDROID_ABI}
        -DANDROID_STL=${ANDROID_STL}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_STAGING_PREFIX=${CMAKE_STAGING_PREFIX}
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DPA_ENABLE_DEBUG_OUTPUT=OFF
        -DPA_BUILD_EXAMPLES=OFF
        -DPA_BUILD_TESTS=OFF
        -DPA_DISABLE_INSTALL=OFF
    )
endif()


check_function_exists(getopt HAVE_GETOPT_C)
if(NOT HAVE_GETOPT_C)

    SET(GPERF_RELEASE 3.1)
    ExternalProject_Add(gperf_ext
        URL https://github.com/jwinarske/gperf/archive/cmake.zip
        URL_HASH "SHA256=2c3ff3ce41f4a97b6bbc432372d3cb738afcf7535705e7c2977c4f6af1c7ff19"
        UPDATE_COMMAND ""
        BUILD_IN_SOURCE 0
        CMAKE_ARGS
            -DANDROID_PLATFORM=${ANDROID_PLATFORM}
            -DANDROID_ABI=${ANDROID_ABI}
            -DANDROID_STL=${ANDROID_STL}
            -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
            -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
            -DCMAKE_STAGING_PREFIX=${CMAKE_STAGING_PREFIX}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
    )
    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
        set(_GPERF_LIBRARY gpd)
    else()
        set(_GPERF_LIBRARY gp)
    endif()
endif()


include_directories(
    ${CMAKE_STAGING_PREFIX}/include
    ${_GRPC_SRC_PATH}
)

link_directories(
    ${CMAKE_STAGING_PREFIX}/lib
    ${CMAKE_STAGING_PREFIX}/lib/static
    ${_GRPC_LIBRARIES_DIR}
    ${_SSL_LIBRARIES_DIRS}
)

set(Protobuf_PROTOC_EXECUTABLE ${CMAKE_STAGING_PREFIX}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX})

set(PROTO_BASE_PATH ${CMAKE_CURRENT_BINARY_DIR}/grpc_ext-prefix/src/grpc_ext/third_party/googleapis)
