cmake_minimum_required(VERSION 3.0)
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

# For compat.
if(${ANGLE_BACKEND} STREQUAL DirectX)
    set(ANGLE_BACKEND_N DirectX11)
else()
    set(ANGLE_BACKEND_N ${ANGLE_BACKEND})
endif()

set(ANGLE_ROOT ${root}/angle)
set(CHROMIUM_ZLIB_ROOT ${root}/chromium-zlib)
set(ANGLE_WORKAROUND_FAKEOBJCSOURCE ON)
yfrm_add_subproject(ANGLE-${ANGLE_BACKEND_N} ${root}/angle-static-cmake angle
    angle_static)
