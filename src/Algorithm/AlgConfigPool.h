//____________________________________________________________________________
/*!

\class    genie::AlgConfigPool

\brief    A singleton class which holds all configuration registries assembled
          from XML configuration files for all (agorithm-name, parameter-set)
          pairs. Any algorithmic object can get an instance of the algorithm
          config. pool and query it to learn its configuration parameters.

\author   Costas Andreopoulos <C.V.Andreopoulos@rl.ac.uk>
          CCLRC, Rutherford Appleton Laboratory

\created  May 06, 2004

*/
//____________________________________________________________________________

#ifndef _ALG_CONFIG_POOL_H_
#define _ALG_CONFIG_POOL_H_

#include <map>
#include <string>
#include <iostream>

#include "Algorithm/Algorithm.h"
#include "Registry/Registry.h"

using std::map;
using std::string;
using std::ostream;

namespace genie {

class AlgConfigPool {

public:

  static AlgConfigPool * Instance();

  Registry * FindRegistry (string alg_name, string param_set) const;
  Registry * FindRegistry (const Algorithm * algorithm)       const;
  
  void Print(ostream & stream) const;
  
  friend ostream& operator<<(ostream& stream, const AlgConfigPool & config_pool); 

private:

  AlgConfigPool(); 
  AlgConfigPool(const AlgConfigPool & config_pool);
  virtual ~AlgConfigPool();

  bool LoadXMLConfig(void);
    
  static AlgConfigPool * fInstance;

  map<string, Registry *> fRegistryPool;    //-- algorithm/param_set -> Registry
  
  struct Cleaner {
      void DummyMethodAndSilentCompiler() { }
      ~Cleaner() {
         if (AlgConfigPool::fInstance !=0) {
            delete AlgConfigPool::fInstance;
            AlgConfigPool::fInstance = 0;
         }
      }
  };

  friend struct Cleaner;
};

}      // genie namespace

#endif // _ALG_CONFIG_POOL_H_
