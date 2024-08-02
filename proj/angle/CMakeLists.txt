cmake_minimum_required(VERSION 3.12)
project(yfrm-angle C CXX)

set(root ${CMAKE_CURRENT_LIST_DIR}/../../ext/cwgl)

set(ANGLE_SPIRV_HEADERS_ROOT ${root}/SPIRV-Headers)
set(ANGLE_VULKAN_HEADERS_ROOT ${root}/Vulkan-Headers)
set(ANGLE_SPIRV_TOOLS_ROOT ${root}/SPIRV-Tools)
set(ANGLE_VOLK_ROOT ${root}/volk) # Vulkan only?
set(ANGLE_VMA_ROOT ${root}/VulkanMemoryAllocator) # Vulkan only?
set(ANGLE_GLSLANG_ROOT ${root}/glslang)
set(ANGLE_SPIRV_CROSS_ROOT ${root}/SPIRV-Cross)

if(YFRM_CWGL_USE_METAL)
    set(ANGLE_BACKEND Metal)
    list(APPEND backend_libs spirv-cross-msl "-framework IOSurface")
elseif(YFRM_CWGL_USE_VULKAN)
    set(ANGLE_BACKEND Vulkan)
elseif(YFRM_CWGL_USE_DX11)
    set(ANGLE_BACKEND DirectX)
else()
    message(FATAL_ERROR "Could not determine ANGLE backend")
endif()

set(deps)

if(${ANGLE_BACKEND} STREQUAL DirectX)
    # For compat.
    set(ANGLE_BACKEND_N DirectX11)
    list(APPEND deps dxgi dxguid)
else()
    set(ANGLE_BACKEND_N ${ANGLE_BACKEND})
endif()

if(${ANGLE_BACKEND} STREQUAL Metal)
    list(APPEND deps SPIRV-Tools-static)
elseif(${ANGLE_BACKEND} STREQUAL Vulkan)
    list(APPEND deps SPIRV-Tools-static)
endif()
if(APPLE)
    list(APPEND deps "-framework IOSurface")
endif()
if(WIN32)
    list(APPEND deps synchronization)
endif()

set(ANGLE_ROOT ${root}/angle)
set(CHROMIUM_ZLIB_ROOT ${root}/chromium-zlib)

set(YFRM_PREBUILT_DEPS_angle_static ${deps})
yfrm_add_subproject(ANGLE-${ANGLE_BACKEND_N} ${root}/angle-static-cmake angle
    angle_static)
