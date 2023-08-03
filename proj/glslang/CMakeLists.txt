cmake_minimum_required(VERSION 3.0)
project(yfrm-glslang C CXX)

set(root ${CMAKE_CURRENT_LIST_DIR}/../../ext/cwgl)

set(SPIRV_WERROR OFF CACHE BOOL "" FORCE)
set(SPIRV-Headers_SOURCE_DIR ${root}/SPIRV-Headers)
set(SKIP_GLSLANG_INSTALL OFF CACHE BOOL "" FORCE)
set(ENABLE_GLSLANG_BINARIES OFF CACHE BOOL "" FORCE)

yfrm_add_subproject(GLSLANG ${root}/glslang glslang
    # Exported library
    glslang)

# Workaround for glslang-default-resource-limits
set(glslang-resource-limits-srcs
    ${root}/glslang/StandAlone/ResourceLimits.cpp
    ${root}/glslang/StandAlone/resource_limits_c.cpp)
include_directories(${root}/glslang)
add_library(my-glslang-default-resource-limits STATIC
    ${glslang-resource-limits-srcs})

set(SKIP_SPIRV_TOOLS_INSTALL OFF CACHE BOOL "" FORCE)
set(SPIRV_SKIP_EXECUTABLES ON CACHE BOOL "" FORCE)
if(APPLE) # FIXME: Should be a host os check..
    message(STATUS "Enforcing python executable at /usr/bin")
    set(PYTHON_EXECUTABLE "/usr/bin/python3" CACHE STRING "" FORCE)
endif()

if(APPLE)
    set(CMAKE_MACOSX_RPATH ON)
endif()

yfrm_add_subproject(GLSLANG ${root}/SPIRV-Tools SPIRV-Tools
    # Exported libraries
    SPIRV-Tools-static
    SPIRV-Tools-opt
    SPIRV
    )


if(YFRM_SUBPROJECT_BUILD OR 
        YFRM_CWGL_USE_METAL OR YFRM_CWGL_EXPERIMENTAL_TRACKER)
    # Also integrate SPIRV-Cross
    set(SPIRV_CROSS_CLI OFF CACHE BOOL "" FORCE)
    set(SPIRV_CROSS_SKIP_INSTALL ON CACHE BOOL "" FORCE)
    yfrm_add_subproject(GLSLANG ${root}/SPIRV-Cross SPIRV-Cross
        # Exported libraries
        spirv-cross-c
        )
endif()

# FIXME: ????
list(APPEND backend_libs
    my-glslang-default-resource-limits
    )
