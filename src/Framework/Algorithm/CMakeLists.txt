add_library(FwAlg)
target_sources(FwAlg PRIVATE 
  AlgConfigPool.cxx
  AlgFactory.cxx
  AlgId.cxx
  Algorithm.cxx)
target_include_directories(FwAlg PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>)
