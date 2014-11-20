//
//  FPQuery.h
//  FP
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPObject.h"

@interface FPQuery : NSObject

/**
 * create a query object targeted towards the specified class
 * @param[in] className - an NSString instance describing the class to query
 */
+(FPQuery*) queryWithClassName:(NSString*) className;

/**
 * Retrieve a single object by specifying its primary key, 
 * (aka "id" field in Solr, "objectId", in FPObject.
 * Solr, in schema-less mode, will not need the className parameter 
 * to return an object with this method.
 * In Parse, this method's signature returns the found object. 
 * In FP the object is queried asynchonously,
 * so it uses a completion block to return the object instead.
 */

-(void) getObjectInBackgroundWithId:(NSString*) objectId
                              block:(void(^)(FPObject *object, NSError *error) ) completionBlock;


/**
 * set criteria for this query's query request
 * @param[in] whereKey: the name of the field to search in for "match"
 * @param[in] equalTo: the value of the field specifed in whereKey to match against
 */

-(void) whereKey:(NSString*)whereClause equalTo:(NSString*)match;


/**
 * Execute a query, returning an array of FPObjects
 *
 */

-(void)findObjectsInBackgroundWithBlock:(void(^)(NSArray *objects, NSError *error) ) completionBlock;

@end
