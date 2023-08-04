cmake_minimum_required(VERSION 3.0)
project(yfrm-sdl2 NONE)

set(root ${CMAKE_CURRENT_LIST_DIR}/../../ext/platform)

set(SDL_SHARED OFF CACHE BOOL "" FORCE)
set(SDL_STATIC ON CACHE BOOL "" FORCE)
set(LIBC ON CACHE BOOL "" FORCE)

if(APPLE)
    # FIXME: Metal detection do not work on upstream SDL
    #        we don't have to bothered with auto detection anyway, anyhow
    set(HAVE_FRAMEWORK_METAL ON CACHE BOOL "" FORCE)
    # Tentative.
    add_definitions(-DSDL_USE_BUILTIN_OPENGL_DEFINITIONS)
endif()

# Setup SDL2 headers
set(sdl2_headers
    SDL.h SDL_assert.h SDL_atomic.h SDL_audio.h SDL_bits.h SDL_blendmode.h
    SDL_clipboard.h SDL_copying.h SDL_cpuinfo.h SDL_egl.h SDL_endian.h
    SDL_error.h SDL_events.h SDL_filesystem.h SDL_gamecontroller.h
    SDL_gesture.h SDL_guid.h SDL_haptic.h SDL_hidapi.h SDL_hints.h
    SDL_joystick.h SDL_keyboard.h SDL_keycode.h SDL_loadso.h SDL_locale.h
    SDL_log.h SDL_main.h SDL_messagebox.h SDL_metal.h SDL_misc.h SDL_mouse.h
    SDL_mutex.h SDL_name.h SDL_opengl.h SDL_opengl_glext.h SDL_opengles.h
    SDL_opengles2.h SDL_opengles2_gl2.h SDL_opengles2_gl2ext.h
    SDL_opengles2_gl2platform.h SDL_opengles2_khrplatform.h
    SDL_pixels.h SDL_platform.h SDL_power.h SDL_quit.h SDL_rect.h SDL_render.h
    SDL_revision.h SDL_revision.h.cmake SDL_rwops.h SDL_scancode.h SDL_sensor.h
    SDL_shape.h SDL_stdinc.h SDL_surface.h SDL_system.h SDL_syswm.h SDL_test.h
    SDL_test_assert.h SDL_test_common.h SDL_test_compare.h SDL_test_crc32.h
    SDL_test_font.h SDL_test_fuzzer.h SDL_test_harness.h SDL_test_images.h
    SDL_test_log.h SDL_test_md5.h SDL_test_memory.h SDL_test_random.h
    SDL_thread.h SDL_timer.h SDL_touch.h SDL_types.h SDL_version.h
    SDL_video.h SDL_vulkan.h begin_code.h close_code.h
    )

if(NOT YFRM_SDL2_PREFIX)
    message(STATUS "Skipping header generation(!YFRM_SDL2_PREFIX)")
else()
    set(headertgt)
    foreach(e ${sdl2_headers})
        set(input ${root}/SDL2/include/${e})
        set(output ${YFRM_SDL2_PREFIX}/SDL2/${e})
        add_custom_command(
            OUTPUT ${output}
            COMMAND ${CMAKE_COMMAND} -E copy ${input} ${output}
            DEPENDS ${input})
        list(APPEND headertgt ${output})
    endforeach()
    set(maybe_sdlcfg)
    set(maybe_sdlcfg_in ${YFRM_BINARY_ROOT}/sdl2config/SDL_config.h)
    if(YFRM_BINARY_ROOT AND EXISTS ${maybe_sdlcfg_in})
        # Copy SDL_config.h as well
        set(maybe_sdlcfg ${YFRM_SDL2_PREFIX}/SDL2/SDL_config.h)
        add_custom_command(
            OUTPUT ${maybe_sdlcfg}
            COMMAND ${CMAKE_COMMAND} -E copy ${maybe_sdlcfg_in}
            ${maybe_sdlcfg}
            DEPENDS ${maybe_sdlcfg_in}
            )
    endif()
    add_custom_target(sdl2headers DEPENDS ${headertgt} ${maybe_sdlcfg})
endif()

if(ANDROID)
    set(deps
        OpenSLES
        dl
        android
        GLESv2 
        GLESv1_CM
        log)
elseif(WIN32)
    set(deps
        winmm
        CfgMgr32
        Setupapi
        Version
        )
elseif(APPLE)
    set(deps
        "-framework Foundation"
        "-framework GameController"
        "-framework Metal"
        "-framework CoreAudio"
        "-framework AudioToolbox"
        "-framework CoreHaptics"
        "-framework QuartzCore"
        "-framework CoreGraphics"
        "-framework CoreBluetooth"
        iconv
        )
    if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL tvOS)
        list(APPEND deps 
            "-framework IOKit"
            "-framework CoreMotion"
            )
    endif()
    if(${CMAKE_SYSTEM_NAME} STREQUAL tvOS OR
            ${CMAKE_SYSTEM_NAME} STREQUAL iOS)
        # Mobile
        list(APPEND deps
            "-framework OpenGLES"
            "-framework AVFoundation"
            "-framework UIKit"
            )
    else()
        # Desktop(?)
        list(APPEND deps
            "-framework ForceFeedback"
            "-framework Cocoa"
            "-framework CoreVideo"
            "-framework Carbon"
            )
    endif()
else()
    set(deps)
endif()

set(YFRM_PREBUILT_DEPS_SDL2-static ${deps})

yfrm_add_subproject(SDL2 ${root}/SDL2 sdl2
    # Exported libraries
    SDL2-static
    SDL2main
    )

# Special handling for SDL_config.h
# We assume the file do not contain generator expression at all
if(NOT YFRM_SDL2_PREFIX)
    # Assume we're building prebuilt SDL2
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory
        ${YFRM_BINARY_ROOT}/sdl2config)

    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_BINARY_DIR}/sdl2/SDL_config.h.intermediate
        ${YFRM_BINARY_ROOT}/sdl2config/SDL_config.h)
endif()
