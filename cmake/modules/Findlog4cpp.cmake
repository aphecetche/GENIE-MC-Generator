find_package(PkgConfig REQUIRED)

pkg_search_module(log4cpp REQUIRED IMPORTED_TARGET GLOBAL log4cpp)

if(TARGET PkgConfig::log4cpp)
  add_library(log4cpp::log4cpp ALIAS PkgConfig::log4cpp)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(log4cpp
                                  REQUIRED_VARS log4cpp_LIBRARIES)

                          # get_property(TOTO TARGET PkgConfig::log4cpp PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
                          # get_property(TITI TARGET log4cpp::log4cpp PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
                          # message(WARNING "TOTO=${TOTO}")
                          # message(FATAL_ERROR "TITI=${TITI}")
