genie_add_library(FwMsg 
  SOURCES 
    Messenger.cxx 
  ROOT_DICTIONARY
    Messenger.h
  PUBLIC_LINK_LIBRARIES 
    GENIE::FwUtlStr
    GENIE::FwUtlPrint
    LibXml2::LibXml2
    log4cpp::log4cpp)

