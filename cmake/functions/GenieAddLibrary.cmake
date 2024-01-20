include_guard()

include(GenieNameTarget)

#
# genie_add_library(baseTargetName SOURCES c1.cxx c2.cxx .....) defines a new
# target of type "library" composed of the given sources. It also defines an
# alias named GENIE::baseTargetName. The generated library will be called
# lib[baseTargetName].(dylib|so|.a) (for exact naming see the genie_name_target
# function).
#
# The library will be static or shared depending on the BUILD_SHARED_LIBS option
# (which is normally ON for the Genie project)
#
# Parameters:
#
# * SOURCES (required) : the list of source files to compile into this library
#
# * PUBLIC_LINK_LIBRARIES (needed in most cases) : the list of targets this
#   library depends on (e.g. ROOT::Hist, Genie::FwConventions). It is mandatory
#   to use the fully qualified target name (i.e. including the namespace part)
#   even for internal (Genie) targets.
#
# * PUBLIC_HEADER (needed if some includes should be installed) : the list
#   of header file that should be installed
#
# * ROOT_DICTIONARY (needed if there's a Root dictionary to be added to
#   the library) : specify the list of relative filepaths
#   needed for the dictionary definition
#
# * LINKDEF (not needed in most cases) is a single relative filepath
#   to the LinkDef file needed by rootcling.
#   If the LINKDEF parameter is not present but there is a LinkDef.h
#   file in the current directory it is used as LINKDEF.
#
#   LINKDEF and ROOT_DICTIONARY must contain relative paths only
#   (relative to the CMakeLists.txt that calls this genie_add_library function)
#
# * PRIVATE_LINK_LIBRARIES (not needed in most cases) : the list of targets this
#   library needs at compile time (i.e. those dependencies won't be propagated
#   to the targets depending on this one). It is mandatory to use the fully
#   qualified target name (i.e. including the namespace part) even for internal
#   (O2) targets.
#
# * PUBLIC_INCLUDE_DIRECTORIES (not needed in most cases) : the list of include
#   directories where to find the include files needed to compile this library
#   and that will be needed as well by the consumers of that library. By default
#   the include subdirectory of the current source directory is taken into
#   account, which should cover most of the use cases. Use this parameter only
#   for special cases then. Note that if you do specify this parameter it
#   replaces the default, it does not add to them.
#
# * PRIVATE_INCLUDE_DIRECTORIES (not needed in most cases) : the list of include
#   directories where to find the include files needed to compile this library,
#   but that will _not_ be needed by its consumers. But default we add the
#   ${CMAKE_CURRENT_BINARY_DIR} here to cover use case of generated headers.
#   Note that if you do specify this parameter it replaces
#   the default, it does not add to them.
#
# * COMPILE_DEFINITIONS (not needed in most cases) specifies compile
#   definitions required to compile the sources
#
# * TARGETVARNAME (not needed in most case) : return the actual name of
#   the CMake target that was created for the library (see genie_name_target
#   for details)
#
function(genie_add_library baseTargetName)

  cmake_parse_arguments(
    PARSE_ARGV
    1
    A
    "INTERFACE"
    "TARGETVARNAME;LINKDEF"
    "SOURCES;PUBLIC_LINK_LIBRARIES;PRIVATE_LINK_LIBRARIES;PUBLIC_INCLUDE_DIRECTORIES;PRIVATE_INCLUDE_DIRECTORIES;PUBLIC_HEADER;ROOT_DICTIONARY;COMPILE_DEFINITIONS"
    )

  if(A_UNPARSED_ARGUMENTS)
    message(
      FATAL_ERROR "Unexpected unparsed arguments: ${A_UNPARSED_ARGUMENTS}")
  endif()

  if(A_INTERFACE)
    # few consistency checks
    if(A_SOURCES)
      message(
        FATAL_ERROR "Target ${baseTargetName} cannot be INTERFACE and have SOURCES")
    endif()
    if(A_ROOT_DICTIONARY)
      message(
        FATAL_ERROR "Target ${baseTargetName} cannot be INTERFACE and have ROOT_DICTIONARY")
    endif()
  endif()

  genie_name_target(${baseTargetName} NAME targetName)
  set(target ${targetName})

  # define the target and its GENIE:: alias
  if(NOT A_INTERFACE)
    add_library(${target})
    target_sources(${target} PRIVATE ${A_SOURCES})
  else()
    add_library(${target} INTERFACE)
  endif()
  add_library(GENIE::${baseTargetName} ALIAS ${target})

  # set the export name so that packages using GENIE can reference the target as
  # GENIE::${baseTargetName} as well (assuming the export is installed with
  # namespace GENIE::)
  set_property(TARGET ${target} PROPERTY EXPORT_NAME ${baseTargetName})

  # output name of the lib will be libG[baseTargetName].(so|dylib|a)
  set_property(TARGET ${target} PROPERTY LIBRARY_OUTPUT_NAME G${baseTargetName})

  if(A_TARGETVARNAME)
    set(${A_TARGETVARNAME} ${target} PARENT_SCOPE)
  endif()

  # Start by adding the public dependencies to other targets
  if(A_PUBLIC_LINK_LIBRARIES)
    foreach(L IN LISTS A_PUBLIC_LINK_LIBRARIES)
      string(FIND ${L} "::" NS)
      if(${NS} EQUAL -1 AND NOT ${L} STREQUAL "${CMAKE_DL_LIBS}")
        message(FATAL_ERROR "Trying to use a non-namespaced target ${L}")
      endif()
      if(A_INTERFACE)
        target_link_libraries(${target} INTERFACE ${L})
      else()
        target_link_libraries(${target} PUBLIC ${L})
      endif()
    endforeach()
  endif()

  # Then add the private dependencies to other targets
  if(A_PRIVATE_LINK_LIBRARIES AND NOT A_INTERFACE)
    foreach(L IN LISTS A_PRIVATE_LINK_LIBRARIES)
      string(FIND ${L} "::" NS)
      if(${NS} EQUAL -1)
        message(FATAL_ERROR "Trying to use a non-namespaced target ${L}")
      endif()
      target_link_libraries(${target} PRIVATE ${L})
    endforeach()
  endif()

  # set the public include directories if available
  if(A_PUBLIC_INCLUDE_DIRECTORIES)
    foreach(d IN LISTS A_PUBLIC_INCLUDE_DIRECTORIES)
      get_filename_component(adir ${d} ABSOLUTE)
      if(NOT IS_DIRECTORY ${adir})
        message(
          FATAL_ERROR "Trying to append non existing include directory ${d}")
      endif()
      if (A_INTERFACE)
        target_include_directories(${target} INTERFACE $<BUILD_INTERFACE:${adir}>)
      else()
        target_include_directories(${target} PUBLIC $<BUILD_INTERFACE:${adir}>)
      endif()
    endforeach()
  else()
    # use topdir/src by default
    if(A_INTERFACE)
      target_include_directories(
        ${target}
        INTERFACE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>)
    else()
      target_include_directories(
        ${target}
        PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>)
    endif()
  endif()

  # set the private include directories if available
  if(NOT A_INTERFACE)
    if (A_PRIVATE_INCLUDE_DIRECTORIES)
      foreach(d IN LISTS A_PRIVATE_INCLUDE_DIRECTORIES)
        get_filename_component(adir ${d} ABSOLUTE)
        if(NOT IS_DIRECTORY ${adir})
          message(
            FATAL_ERROR "Trying to append non existing include directory ${d}")
        endif()
        target_include_directories(${target} PRIVATE $<BUILD_INTERFACE:${d}>)
      endforeach()
    else()
      # use sane(?) default, to cover the case of generated files
      target_include_directories(
        ${target}
        PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>/src)
    endif()
  endif()

  set(destination "${baseTargetName}")
  if(destination STREQUAL JJeep)
    # special case to avoid stutter
    set(destination Jeep)
  endif()

  if(A_COMPILE_DEFINITIONS)
    target_compile_definitions(${target} INTERFACE "${A_COMPILE_DEFINITIONS}")
  endif()

  set_target_properties(${target} PROPERTIES
    EXPORT_NAME ${destination}
    OUTPUT_NAME ${destination}
    PUBLIC_HEADER "${A_PUBLIC_HEADER}")

  # Note that the EXPORT must come first in the list of parameters
  # (i.e. before any target option)
  install(TARGETS ${target}
          EXPORT genie-generator
          LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
          PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${destination})

  if (A_ROOT_DICTIONARY)
    # ensure we have a LinkDef, either explicity given by LINKDEF parameter
    # or the default LinkDef.h in current dir
    if(NOT A_LINKDEF)
      if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/LinkDef.h)
        message(
          FATAL_ERROR
            "You did not specify LINKDEF and the default one LinkDef.h does not exist"
          )
      else()
        set(A_LINKDEF LinkDef.h)
      endif()
    endif()
    get_property(libs TARGET ${target} PROPERTY INTERFACE_LINK_LIBRARIES)
    if(NOT ROOT::RIO IN_LIST libs)
      # add ROOT::RIO if not already there because a target that has
      # a Root dictionary does depend on it...
      target_link_libraries(${target} PUBLIC ROOT::RIO)
    endif()
    root_generate_dictionary(G__${baseTargetName}
       "${A_ROOT_DICTIONARY}" ${A_LINKDEF} MODULE ${target})
  endif()
endfunction()
