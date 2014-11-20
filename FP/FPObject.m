//
//  FPObject.m
//  FP
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//
#include <time.h>
#import "FPObject.h"
#import "fp_constants.h"

@interface FPObject()
@property (nonatomic,copy) NSString *className;

/**
 * a backing data store
 */

@property (nonatomic,retain) NSMutableDictionary  *store;

/**
 * String date of creation
 */

@property (nonatomic,copy) NSString *creationDate;



@end

@implementation FPObject

+(FPObject*) objectWithClassName:(NSString*) className
{
    
    FPObject *ob = [[FPObject alloc]init];
    ob.className = className;
    ob.store = [NSMutableDictionary dictionary];
    
    
    ob.store[@"className"] = className;
    
    time_t thyme;
    time (&thyme);
    printf("created at %s",ctime(&thyme));
    ob.creationDate = [NSString stringWithFormat:@"%s",ctime(&thyme)];
    ob.creationDate = [ob.creationDate stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    ob.store[@"createdAt"] =  ob.creationDate;
    
    return ob;
}


+(FPObject*) objectWithDictionary:(NSDictionary*) dictionary {
    
    FPObject *ob = [[FPObject alloc]init];
    ob.store = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    return ob;
    
}


- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    
    _store[key] = obj;
    
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    return _store[key];
}

-(NSString*) createdAt {
    return _creationDate;
}

-(NSString*) objectId {
    
    if( !_store[@"id"] ) {
        // Generate an Id for the object. This id will serve as the primary key in Solr.
        // It could be made more robust to protect against data collisions
        // by using a UUID style string i.e. BBCAE0D4-9133-418F-9BE4-D4A8814A6DC3
        
        // get the hash of this object
        NSInteger hash = self.hash;
        
        // store the hash as a base64 encoded string to mirror parse's alpha-numeric style
        NSString *_objectId = [[NSData dataWithBytes:&hash length:sizeof(hash)] base64EncodedStringWithOptions:0];
        // remove trailing '=' padding spaces
        _objectId = [_objectId stringByReplacingOccurrencesOfString:@"=" withString:@""];
        // set as id in backing store, so that it is passed to solr
        _store[@"id"] = _objectId;
    }
    
    return _store[@"id"];
}

-(void) saveInBackground {
    
    NSError *error;
    
    // force generation of an object id, if one did not exist yet
    [self objectId];
    
    // Solr expects an array of documents, each one being a json object of key/value pairs
    NSArray *dataToSave = @[_store];
    
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:dataToSave
                                                   options:0
                                                     error:&error];
    
    NSURL *url = [NSURL URLWithString:kUPDATE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:json];
    
    [NSURLConnection sendAsynchronousRequest:request  queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {
            NSLog(@"Connection failed: %@",error.localizedDescription);
        } else {
            
            NSError *readError;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&readError];
            
            if( readError) {
                NSLog(@"could not read response. %@",readError.localizedDescription);
            } else {
                /// a successful response should look like:
                /// {"responseHeader":{"status":0,"QTime":60}}
                NSDictionary *responseHeader = responseDictionary[@"responseHeader"];
                
                if(responseHeader) {
                    NSInteger status = [responseHeader[@"status"] intValue];
                    if( status == 0 ) {
                        
                        NSString *jsonString = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
                        NSLog(@"Saved object %@ ",jsonString);
                    }
                } else {
                    
                }
                
            }
        }
        
    }];
    
    
}


@end
