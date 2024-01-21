genie_add_library(HEPBase INTERFACE
  PUBLIC_HEADER 
    GHEPFlags.h
    GHEPFStatus.h
)

genie_add_library(HEP 
  SOURCES 
    GHepParticle.cxx
    GHepRecord.cxx
    GHepRecordHistory.cxx
    GHepUtils.cxx
    GHepVirtualList.cxx
    GHepVirtualListFolder.cxx
  AUTO_ROOT_DICTIONARY
  PUBLIC_LINK_LIBRARIES
    GENIE::FwMsg
    GENIE::HEPBase
    ROOT::Physics
)
