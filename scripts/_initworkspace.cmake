set(repos coal cwgl nccc yuniframe)
set(root ${CMAKE_CURRENT_LIST_DIR}/..)

foreach(r ${repos})
    message(STATUS "Set remote for ${root}/${r}")
    execute_process(COMMAND
        git remote set-url --push origin git@github.com:okuoku/${r}
        WORKING_DIRECTORY ${root}/${r}
        )
endforeach()

execute_process(COMMAND
    git remote set-url --push origin git@github.com:okuoku/angle-static-cmake
    WORKING_DIRECTORY ${root}/ext/cwgl/angle-static-cmake)

execute_process(COMMAND
    git remote set-url --push origin git@github.com:okuoku/em2native-integ
    WORKING_DIRECTORY ${root})
