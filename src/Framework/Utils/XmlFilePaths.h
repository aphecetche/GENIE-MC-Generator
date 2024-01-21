#ifndef _XML_FILEPATHS_H_
#define _XML_FILEPATHS_H_

#include <string>

namespace genie {
namespace utils {
namespace xml   {

  //_________________________________________________________________________
  std::string GetXMLPathList( bool add_tune = true ) ;
  // Get a colon separated list of potential locations for xml files
  // e.g. ".:$MYSITEXML:/path/to/exp/version:$GALGCONF:$GENIE/config"
  // user additions should be in $GXMLPATH

  //_________________________________________________________________________
  std::string GetXMLFilePath(std::string basename) ;
  // return a full path to a real XML file
  // e.g. passing in "GNuMIFlux.xml"
  //   will return   "/blah/GENIE/HEAD/config/GNuMIFlux.xml"
  // allow ::colon:: ::semicolon:: and ::comma:: as path item separators
  //_________________________________________________________________________

}         // xml   namespace
}         // utils namespace
}         // genie namespace

#endif 

