//____________________________________________________________________________
/*
 Copyright (c) 2003-2023, The GENIE Collaboration
 For the full text of the license visit http://copyright.genie-mc.org

 Costas Andreopoulos <constantinos.andreopoulos \at cern.ch>
 University of Liverpool & STFC Rutherford Appleton Laboratory
*/
//____________________________________________________________________________

#include <sstream>

#include "Framework/Messenger/Messenger.h"
#include "Framework/Utils/RunOpt.h"
#include "Framework/Utils/XmlFilePaths.h"
#include "Framework/Utils/XmlParserUtils.h"

using std::ostringstream;
using std::string;

//_________________________________________________________________________
string genie::utils::xml::GetXMLPathList( bool add_tune )   {

  // Get a colon separated list of potential locations for xml files
  // e.g. ".:$MYSITEXML:/path/to/exp/version:$GALGCONF:$GENIE/config"
  // user additions should be in $GXMLPATH
  // All of the environment variaables have lower priority than the --xml-path command line argument

  string pathlist;
  std::string p0 = RunOpt::Instance()->XMLPath();
  if ( p0.size() ) { pathlist += std::string(p0) + ":" ; }
  const char* p1 = std::getenv( "GXMLPATH" );
  if ( p1 ) { pathlist += std::string(p1) + ":" ; }
  const char* p2 = std::getenv( "GXMLPATHS" );  // handle extra 's'
  if ( p2 ) { pathlist += std::string(p2) + ":" ; }

  // add originally supported alternative path
  const char* p3 = std::getenv( "GALGCONF" );
  if ( p3 ) { pathlist += std::string(p3) + ":" ; }

  if ( add_tune && RunOpt::Instance() -> Tune() ) {

    if ( RunOpt::Instance() -> Tune() -> IsConfigured() ) {

      if ( ! RunOpt::Instance() -> Tune() -> IsValidated() ) {
        LOG( "XmlParser", pFATAL) << "Tune not validated" ;
        exit(0) ;
      }

      if ( ! RunOpt::Instance() -> Tune() -> OnlyConfiguration() )
        pathlist += RunOpt::Instance() -> Tune() -> TuneDirectory() + ":" ;

      pathlist += RunOpt::Instance() -> Tune() -> CMCDirectory()  + ':' ;

    }  //tune not set in run option
  }  // requested tune and there is a tune

  pathlist += GetXMLDefaultPath() ;  // standard path in case no env
  auto GENIE_REWEIGHT = std::getenv("GENIE_REWEIGHT");
  if (GENIE_REWEIGHT)
    pathlist += ":" + (std::string(GENIE_REWEIGHT) + "/config");
  pathlist += ":$GENIE/src/Tools/Flux/GNuMINtuple";  // special case
  return pathlist;
}

//_________________________________________________________________________
string genie::utils::xml::GetXMLFilePath(string basename)  {
  // return a full path to a real XML file
  // e.g. passing in "GNuMIFlux.xml"
  //   will return   "/blah/GENIE/HEAD/config/GNuMIFlux.xml"
  // allow ::colon:: ::semicolon:: and ::comma:: as path item separators

  // empty basename should just be returned
  // otherwise one will end up with a directory rather than a file
  // as  AccessPathName() isn't checking file vs. directory
  if ( basename == "" ) return basename;

  std::string pathlist = genie::utils::xml::GetXMLPathList();
  std::vector<std::string> paths = genie::utils::str::Split(pathlist,":;,");
  // expand any wildcards, etc.
  size_t np = paths.size();
  for ( size_t i=0; i< np; ++i ) {
    const char* tmppath = paths[i].c_str();
    std::string onepath = gSystem->ExpandPathName(tmppath);
    onepath += "/";
    onepath += basename;
    bool noAccess = gSystem->AccessPathName(onepath.c_str());
    if ( ! noAccess ) {
      //    LOG("XmlParserUtils", pDEBUG ) << onepath ;
      return onepath;  // found one
    }
  }
  // didn't find any, return basename in case it is in "." and that
  // wasn't listed in the XML path list.   If you want "." to take
  // precedence then it needs to be explicitly listed in $GXMLPATH.
  return basename;
}

