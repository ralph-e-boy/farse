//
//  ViewController.m
//  FP
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//


#import "ViewController.h"


#import "FPObject.h"
#import "FPQuery.h"

@interface ViewController ()
- (IBAction)handleCreateAndSave:(id)sender;
- (IBAction)handleQuery:(id)sender;

// a temporary holding spot for an object id, so that we can retrieve the object we just saved.
@property (nonatomic,copy) NSString *lastObjectId;
@property (nonatomic,copy) NSString *lastBandObjectId;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (IBAction)handleCreateAndSave:(id)sender {
    
    // create the object, giving it a "class name".
    // Using Parse, the object would be stored in a "table" with the name of the class.
    // In Solr, the object class name becomes a single field in each "document", named "className".
    // To facilitate retrieval within a single "table', queries can make use of Solr's faceted search
    // capabilities to cordon off a series of documents matching a specific "object type".
    
    FPObject *object = [FPObject objectWithClassName:@"GameScore"];
    
    // set values on the object, using string keys, which become field names in Solr
    // values can be typical primative json types, such as string, numbers, and boolean.
    object[@"score"] = @1337;
    object[@"cheatMode"] = @NO;
    object[@"playerName"] = @"Sean Plott";
    
    // save the object asyncronously to the solr backend
    [object saveInBackground];
    
    // for ease of retrieval in this demo, store the object's id into a property
    self.lastObjectId = object.objectId;
    
    // create another type of arbitrary object, "TopBands"
    // (with band name generated by the kramden.com bandname generator of course... )
    FPObject *bandObject = [FPObject objectWithClassName:@"TopBands"];
    bandObject[@"bandName"] = @"the mud besiegers";
    bandObject[@"numberOfSongs"] = @(arc4random() % 10);
    bandObject[@"hometown"] = @"New York";
    // save the object to the server
    [bandObject saveInBackground];
    
    // again, for ease of query in this demo, set last object id to use in future query
    self.lastBandObjectId = bandObject.objectId;
    
    
}

- (IBAction)handleQuery:(id)sender {
    
    // find a single object using the specified object id
    FPQuery *query = [FPQuery queryWithClassName:@"GameScore"];
    [query getObjectInBackgroundWithId:self.lastObjectId block:^(FPObject *object, NSError *error) {
        NSLog(@"object by id query complete %@",object);
        NSLog(@"name %@ score %@",object[@"playerName"],object[@"score"]);
    }];
    
    //alternatively  find all objects with field name GameScore
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"multiple objects query complete: found %ld object(s)",objects.count);
        for (FPObject *o in objects) {
            NSLog(@"object: %@ - %@",o[@"playerName"],o[@"score"]);
        }
    }];
    
    // now do the same query but add a "where clause"
    [query whereKey:@"playerName" equalTo:@"Sean Plott"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"multiple objects query complete: found %ld object(s)",objects.count);
        for (FPObject *o in objects) {
            NSLog(@"object: %@ - %@",o[@"playerName"],o[@"score"]);
        }
    }];
    
    
    // do a query against the "band" object type
    FPQuery *bandQuery = [FPQuery queryWithClassName:@"TopBands"];
    [bandQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"multiple objects query complete: found %ld object(s)",objects.count);
        for (FPObject *o in objects) {
            NSLog(@"object: %@ - %@",o[@"bandName"],o[@"numberOfSongs"]);
        }
    }];
    
    
}
@end