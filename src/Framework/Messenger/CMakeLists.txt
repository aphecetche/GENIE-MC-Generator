genie_add_library(FwMsg 
  SOURCES 
    Messenger.cxx 
  ROOT_DICTIONARY
    Messenger.h
  PUBLIC_LINK_LIBRARIES 
    GENIE::FwUtlStr
    log4cpp::log4cpp)

