//
//  FPObject.h
//  FakeParse, aka FARSE
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPObject : NSObject

/**
 * The object's creation date, as a string
 */

@property (nonatomic,readonly,retain) NSString *createdAt;

/**
 * The object's unique identifier
 */

@property (nonatomic,readonly,retain) NSString *objectId;

/**
 * create an object with the specified classname
 * @param[in] className - an NSString instance naming the class
 */
+(FPObject*) objectWithClassName:(NSString*) className;


/**
 * Create an FPobject using the specified dictionary as the backing store.
 * This is the method used to convert raw json data into FPObjects
 */
+(FPObject*) objectWithDictionary:(NSDictionary*) dictionary;


/**
 * Asynchronously save the object to the solr backend
 */

-(void) saveInBackground;



/// NSDictionary syntax compatibility methods
/// This allows shorthand, object literal syntax such as  myobject[@"fieldName"] = ...

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
