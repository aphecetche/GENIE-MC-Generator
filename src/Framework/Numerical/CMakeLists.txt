genie_add_library(FwNum
  SOURCES 
    BLI2D.cxx
    GSLUtils.cxx
    IntegrationTools.cxx
    Interpolator2D.cxx
    MathUtils.cxx
    RandomGen.cxx
    Spline.cxx
    PUBLIC_LINK_LIBRARIES ROOT::MathMore ROOT::Core GENIE::FwConventions)

