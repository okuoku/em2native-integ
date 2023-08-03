# FIXME: ?????????????
set(YFRM_PREBUILT_PCFG_Debug DEBUG)
set(YFRM_PREBUILT_PCFG_RelWithDebInfo RELWITHDEBINFO)

function(yfrm_add_subproject sym path dir)
    # ARGN = export/import library list
    set(libs ${ARGN})
    if(YFRM_WITH_PREBUILT_LIBS)
        set(importlibs)
        # Generate library target
        foreach(lib ${libs})
            add_library(${lib} UNKNOWN IMPORTED GLOBAL)
            if(DEFINED YFRM_PREBUILT_DEPS_${lib})
                target_link_libraries(${lib}
                    INTERFACE ${YFRM_PREBUILT_DEPS_${lib}})
            endif()
            if(CMAKE_CONFIGURATION_TYPES)
                # Multi configuration
                foreach(cfg ${CMAKE_CONFIGURATION_TYPES})
                    file(READ "${YFRM_BINARY_ROOT}/yfrm_lib_${sym}_${lib}_${cfg}.txt"
                        f)
                    string(STRIP "${f}" lin)
                    if("${lin}" MATCHES "([^\t]*)\t(.*)")
                        set(bogus ${CMAKE_MATCH_1})
                        set(pth "${CMAKE_MATCH_2}")
                        set(pcfg "${YFRM_PREBUILT_PCFG_${cfg}}")
                        set_target_properties(
                            ${lib}
                            PROPERTIES
                            IMPORTED_LOCATION_${pcfg}
                            "${pth}")
                        message(STATUS "IMPORTED: ${sym} ${lib} ${cfg}: ${pth}")
                    else()
                        message(FATAL_ERROR "Unknown content(${lin}) in ${sym}")
                    endif()
                endforeach()
            else()
                # Single configuration generator(Not tested)
                file(READ "${YFRM_BINARY_ROOT}/yfrm_lib_${sym}_${lib}.txt"
                    f)
                string(STRIP lin "${f}")
                if("${lin}" MATCHES "([^\t]*)\t(.*)")
                    set(bogus ${CMAKE_MATCH_1})
                    set(pth "${CMAKE_MATCH_2}")
                    set_target_properties(
                        ${lib}
                        PROPERTIES
                        IMPORTED_LOCATION
                        "${pth}")
                else()
                    message(FATAL_ERROR "Unknown content(${lin}) in ${sym}")
                endif()
            endif()
        endforeach()
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
            # FIXME: It seems we need CONTENT => TARGET order.. Why?
            #        J: https://zenn.dev/link/comments/4cd4e95ebee3b5
            file(GENERATE OUTPUT 
                ${YFRM_BINARY_ROOT}/yfrm_lib_${sym}_${e}${postfix}.txt
                CONTENT "${e}\t$<TARGET_FILE:${e}>"
                TARGET ${e})
        endforeach()
    endif()
endfunction()
