//
//  fp_constants.c
//  FP
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//


#include "fp_constants.h"


NSString* const kUPDATE_URL         = @"http://10.0.1.23:8983/solr/update?commit=true";
NSString* const kQUERY_URL          = @"http://10.0.1.23:8983/solr/collection1/select?wt=json&indent=true&q=";
NSString* const kFACET_QUERY_URL    = @"http://10.0.1.23:8983/solr/collection1/select?wt=json&df=id&q=*%3A*&fq=" ;