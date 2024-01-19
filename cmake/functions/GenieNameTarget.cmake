include_guard()

include(GenieGetDirInfo)

# TODO : remove script, doc references if not needed for GENIE
#
# genie_name_target(baseName NAME var ...) gives a project specific name to the
# target of the given baseName. The computed name is retrieved in the variable
# "var".
#
# * NAME var: will contain the computed name of the target
# * IS_LIB: present to denote the target is a library (this is the default
# *         is IS_EXE and IS_SCRIPT are not given)
# * IS_EXE: present to denote the target is an executable binary
# * IS_SCRIPT: present to denote the target is an (executable) shell script
# * IS_DOC: present to denote the target is a document (pdf, pptx ...)
#
# The name of the target depends also whether the target is a test or an example
# but that is automatically detected depending by the genie_get_dir_info function
#
function(genie_name_target baseTargetName)

  cmake_parse_arguments(PARSE_ARGV
                        1
                        A
                        "IS_LIB;IS_EXE;IS_SCRIPT;IS_DOC"
                        "NAME"
                        "")

  if(A_UNPARSED_ARGUMENTS)
    message(
      FATAL_ERROR "Unexpected unparsed arguments: ${A_UNPARSED_ARGUMENTS}")
  endif()

  set(nflags)
  if(A_IS_LIB)
    MATH(EXPR nflags "${nflags}+1")
  endif()
  if(A_IS_EXE)
    MATH(EXPR nflags "${nflags}+1")
  endif()
  if(A_IS_SCRIPT)
    MATH(EXPR nflags "${nflags}+1")
  endif()
  if(A_IS_DOC)
    MATH(EXPR nflags "${nflags}+1")
  endif()

  if(NOT A_IS_EXE AND NOT A_IS_SCRIPT AND NOT A_IS_DOC)
     set(A_IS_LIB TRUE)
  endif()

  if(NOT ${nflags} EQUAL 1)
    message(FATAL_ERROR "only one of IS_EXE, IS_LIB, IS_SCRIPT or IS_DOC can be given")
  endif()

  if(NOT A_NAME)
    message(FATAL_ERROR "Parameter NAME is mandatory")
  endif()

  genie_get_dir_info(IS_EXAMPLE is_example IS_TEST is_test PACKAGE package)

  set(targetType)

  if(A_IS_EXE)
    set(targetType exe)
  endif()

  if(A_IS_LIB)
    set(targetType lib)
  endif()

  if(A_IS_SCRIPT)
    set(targetType script)
  endif()

  if(A_IS_DOC)
    set(targetType doc)
  endif()

  if(is_test)
    set(targetType test)
  endif()

  if(is_example)
    set(targetType "${targetType}-example")
  endif()

  set(targetName ${PROJECT_NAME}-${targetType}-${package}-${baseTargetName})

  # strip characters that are reserved by CMake
  string(REGEX REPLACE ":" "-" name ${targetName})

  set(${A_NAME} ${name} PARENT_SCOPE)

endfunction()
