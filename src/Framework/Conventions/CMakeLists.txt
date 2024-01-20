genie_add_library(FwConventions INTERFACE
        PUBLIC_HEADER
          GBuild.h
        PUBLIC_INCLUDE_DIRECTORIES
          ${PROJECT_BINARY_DIR})


file(GENERATE OUTPUT GBuild.h INPUT GBuild.h.in)

file(STRINGS "${PROJECT_SOURCE_DIR}/VERSION" GENIE_GENERATOR_RELEASE LIMIT_COUNT 1)

string(REGEX MATCHALL "[0-9]+[0-9]*" parts ${GENIE_GENERATOR_RELEASE})

list(GET parts 0 GENIE_GENERATOR_RELEASE_MAJOR)
list(GET parts 1 GENIE_GENERATOR_RELEASE_MINOR)
list(GET parts 2 GENIE_GENERATOR_RELEASE_REVIS)

if(Git_FOUND)
  execute_process(
          COMMAND ${GIT_EXECUTABLE} rev-parse --verify HEAD
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE tmp
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT result)
          set(GENIE_GENERATOR_GIT_REVISION ${tmp})
  endif()
endif()

configure_file(GVersion.h.in GVersion.h)

