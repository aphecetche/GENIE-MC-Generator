include_guard()

# genie_get_dir_info computes some information about the
# directory of the calling CMakeLists.txt
#
# base is relative (to GENIE_GENERATOR_STAGE_DIR in build dir or
# to CMAKE_INSTALL_PREFIX in install dir)
#
function(genie_get_dir_info)
  cmake_parse_arguments(PARSE_ARGV
                        0
                        A
                        ""
                        "IS_EXAMPLE;IS_TEST;IS_DOCUMENT;PACKAGE;BASE"
                        "")

  if(A_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Got trailing arguments ${A_UNPARSED_ARGUMENTS}")
  endif()

  file(RELATIVE_PATH relDir ${PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_LIST_DIR})
  cmake_path(GET relDir FILENAME package)

  set(is_example FALSE)
  set(is_test FALSE)
  set(is_document FALSE)
  set(base ${CMAKE_INSTALL_BINDIR})

  if(relDir MATCHES "^examples/")
    set(is_example TRUE)
    set(base examples/${package})
  endif()

  if(relDir MATCHES "^tests/")
    set(is_test TRUE)
    set(base tests/${package})
  endif()

  if(relDir MATCHES "^documentation/")
    set(is_document TRUE)
    set(base ${CMAKE_INSTALL_DOCDIR})
  endif()

  if(A_IS_DOCUMENT)
    set(${A_IS_DOCUMENT} ${is_document} PARENT_SCOPE)
  endif()

  if(A_IS_EXAMPLE)
    set(${A_IS_EXAMPLE} ${is_example} PARENT_SCOPE)
  endif()

  if(A_IS_TEST)
    set(${A_IS_TEST} ${is_test} PARENT_SCOPE)
  endif()

  if(A_PACKAGE)
    set(${A_PACKAGE} ${package} PARENT_SCOPE)
  endif()

  if(A_BASE)
    set(${A_BASE} ${base} PARENT_SCOPE)
  endif()

endfunction()

