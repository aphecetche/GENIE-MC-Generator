cmake_minimum_required(VERSION 3.24)

list(APPEND CMAKE_MESSAGE_CONTEXT genie-generator)

project(GENIE_Generator LANGUAGES CXX)

# general defaults like output paths, optional parts, etc...
include(cmake/defaults/CMakeLists.txt)

if(GENIE_GENERATOR_ENABLE_TESTING)
  include(CTest)
endif()

# usefull functions to ease declaration of libraries
# and executables for this project
#
include(cmake/functions/CMakeLists.txt)

# list of external packages we're depending upon
include(dependencies.cmake)

# report on missing packages
include(FeatureSummary)
feature_summary(
   FATAL_ON_MISSING_REQUIRED_PACKAGES
   WHAT PACKAGES_NOT_FOUND
   QUIET_ON_EMPTY)

# define our targets
add_subdirectory(src)

list(POP_BACK CMAKE_MESSAGE_CONTEXT)
