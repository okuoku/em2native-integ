function(yfrm_add_subproject sym path dir)
    # ARGN = export/import library list
    set(libs ${ARGN})
    if(YFRM_WITH_PREBUILT_${sym})
        # To do
    else()
        if(NOT YFRM_BINARY_ROOT)
            # For testing
            set(YFRM_BINARY_ROOT ${CMAKE_CURRENT_BINARY_DIR})
        endif()
        add_subdirectory(${path} ${dir})
        # Write path info
        if(CMAKE_CONFIGURATION_TYPES)
            set(postfix "_$<CONFIG>")
        else()
            set(postfix)
        endif()

        foreach(e ${libs})
            message(STATUS "generator expression for ${e}")
            # FIXME: It seems we need CONTENT => TARGET order.. Why?
            #        J: https://zenn.dev/link/comments/4cd4e95ebee3b5
            file(GENERATE OUTPUT 
                ${YFRM_BINARY_ROOT}/yfrm_lib_${sym}_${e}${postfix}.txt
                CONTENT "${e}\t$<TARGET_FILE:${e}>"
                TARGET ${e})
        endforeach()
    endif()
endfunction()
