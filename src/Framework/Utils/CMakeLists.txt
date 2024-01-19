#
# Here we have to split the original FwUtl "library" in 3 parts
# to avoid circular dependencies, e.g with Framework/Messenger...
#

genie_add_library(FwUtlStr
  SOURCES
    StringUtils.cxx
  ROOT_DICTIONARY
    StringUtils.h
  LINKDEF
    StringUtilsLinkDef.h)

genie_add_library(FwUtlXml
  SOURCES
    XmlParserUtils.cxx
  ROOT_DICTIONARY
    XmlParserUtils.h
  LINKDEF
    XmlParserUtilsLinkDef.h
  PUBLIC_LINK_LIBRARIES
    GENIE::FwUtlStr)

# genie_add_library(FwUtl
#   SOURCES
#     AppInit.cxx
#     BWFunc.cxx
#     Cache.cxx
#     CacheBranchFx.cxx
#     CacheBranchNtp.cxx
#     CmdLnArgParser.cxx
#     ConfigIsotopeMapUtils.cxx
#     GSimFiles.cxx
#     GUIUtils.cxx
#     HadXSUtils.cxx
#     KineUtils.cxx
#     PREM.cxx
#     PhysUtils.cxx
#     PrintUtils.cxx
#     Range1.cxx
#     RunOpt.cxx
#     Style.cxx
#     SystemUtils.cxx
#     T2KEvGenMetaData.cxx
#     TuneId.cxx
#     UnitUtils.cxx
#     XSecSplineList.cxx
#   PUBLIC_LINK_LIBRARIES
#     ROOT::RIO ROOT::Hist log4cpp::log4cpp)
#
# root_generate_dictionary(G__FwUtl 
#   AppInit.h
#   BWFunc.h
#   Cache.h
#   CacheBranchFx.h
#   CacheBranchI.h
#   CacheBranchNtp.h
#   CmdLnArgParser.h
#   ConfigIsotopeMapUtils.h
#   GSimFiles.h
#   GUIUtils.h
#   HadXSUtils.h
#   KineUtils.h
#   PREM.h
#   PhysUtils.h
#   PrintUtils.h
#   Range1.h
#   RunOpt.h
#   StringUtils.h
#   Style.h
#   SystemUtils.h
#   T2KEvGenMetaData.h
#   TuneId.h
#   UnitUtils.h
#   XSecSplineList.h
#   XmlParserUtils.h
#   nm.h
#   LinkDef.h MODULE FwUtl)
