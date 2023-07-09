cmake_minimum_required(VERSION 3.0)
project(yfrm-sdl2 C CXX)

set(root ${CMAKE_CURRENT_LIST_DIR}/../../ext/platform)

set(SDL_SHARED OFF CACHE BOOL "" FORCE)
set(SDL_STATIC ON CACHE BOOL "" FORCE)
set(LIBC ON CACHE BOOL "" FORCE)
if(APPLE)
    # FIXME: Metal detection do not work on upstream SDL
    #        we don't have to bothered with auto detection anyway, anyhow
    set(HAVE_FRAMEWORK_METAL ON CACHE BOOL "" FORCE)
endif()

add_subdirectory(${root}/SDL sdl)

