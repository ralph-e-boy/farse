//
//  FPQuery.m
//  FP
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//

#import "FPQuery.h"
#import "fp_constants.h"

@interface FPQuery()

@property (nonatomic,copy) NSString *className;
@property (nonatomic,copy) NSString *whereClause;
@property (nonatomic,copy) NSString *match;

@end

@implementation FPQuery


+(FPQuery*) queryWithClassName:(NSString *)className
{
    
    FPQuery *query = [[FPQuery alloc]init];
    query.className = className;
    return query;
    
}

-(void) getObjectInBackgroundWithId:(NSString*) objectId
                              block:(void(^)(FPObject  *object, NSError *error) ) completionBlock
{
    
    NSString *query = [NSString stringWithFormat:@"id:%@",objectId];
    
    NSString * escapedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *urlstring = [NSString stringWithFormat:@"%@%@",kQUERY_URL,escapedQuery];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if( connectionError) {
                                   // pass through the connection error 
                                   NSLog(@"Connection error:%@",connectionError.localizedDescription);
                                   completionBlock(nil,connectionError);
                               } else {
                                   
                                   NSError *readError = nil;
                                   
                                   // convert the response to an json object
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingMutableContainers
                                                                                     error:&readError];
                                   
                                   // need to grab the "docs" value out of the
                                   NSDictionary *response = [jsonResponse objectForKey:@"response"];
                                   
                                   // documents returned
                                   NSArray *docs = [response objectForKey:@"docs"];
                                   
                                   // should only be one doc, since we queried on unique id.
                                   NSDictionary *dict = [docs firstObject];
                                   
                                   // convert this object to an FPObject, by initialising it
                                   // with the returned dictionary
                                   
                                   FPObject *returnedObject = [FPObject objectWithDictionary:dict];
                                   
                                   completionBlock(returnedObject,nil);
                                   
                               }
                               
                               
                           }];
}


-(void) whereKey:(NSString *)whereClause equalTo:(NSString *)match
{
    self.whereClause = whereClause;
    self.match = match;
}


-(void) findObjectsInBackgroundWithBlock:(void (^)(NSArray *, NSError *))completionBlock
{
    
    // use faceted query with className
    NSString *query = [NSString stringWithFormat:@"className:%@",self.className];
    
    NSString *additionalQuery = nil;
    
    
    
    NSString * escapedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlstring = [NSString stringWithFormat:@"%@%@",kFACET_QUERY_URL,escapedQuery];
    
    if( self.whereClause && self.match) {
        additionalQuery = [NSString stringWithFormat:@"&fq=%@:%@",self.whereClause,self.match];
        NSString * escapedWhereClause = [additionalQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        urlstring = [NSString stringWithFormat:@"%@%@",urlstring,escapedWhereClause];
    }
    
    NSURL *url = [NSURL URLWithString:urlstring];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if( connectionError) {
                                   // pass through the connection error
                                   NSLog(@"Connection error:%@",connectionError.localizedDescription);
                                   completionBlock(nil,connectionError);
                               } else {
                                   
                                   NSError *readError = nil;
                                   
                                   // convert the response to an json object
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:NSJSONReadingMutableContainers
                                                                                                  error:&readError];
                                   
                                   // need to grab the "docs" value out of the
                                   NSDictionary *response = [jsonResponse objectForKey:@"response"];
                                   
                                   // documents returned
                                   NSMutableArray *returnedObjects = [NSMutableArray array];
                                   
                                   NSArray *docs = [response objectForKey:@"docs"];
                                   
                                   // while through returned results and create FPObjects out of them.
                                   for (NSDictionary *doc in docs ) {
                                       // add to result array
                                       [returnedObjects addObject:[FPObject objectWithDictionary:doc]];
                                   }
                                   
                                   
                                   // finally, call our completion block with results..
                                   completionBlock(returnedObjects,nil);
                                   
                               }
                               
                               
                           }];
    
}


@end
