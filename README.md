farse
=====

## Farse -- a parse clone

This is a proof of concept project to create a clone of the Parse backend ios client and web services.

The backend is modeled using Apache Solr, and a lightweight clone of the Parse iOS sdk is implemented in Objective C. 

Read doc/farse.pdf for more information.

Example code:

```objc

    // find a single object using the specified object id
    FPQuery *query = [FPQuery queryWithClassName:@"GameScore"];
    [query getObjectInBackgroundWithId:self.lastObjectId block:^(FPObject *object, NSError *error) {
        NSLog(@"object by id query complete %@",object);
        NSLog(@"name %@ score %@",object[@"playerName"],object[@"score"]);
    }];
   
    //alternatively  find all objects with field name GameScore
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"multiple objects query complete: found %d object(s)",objects.count);
        for (FPObject *o in objects) {
            NSLog(@"object: %@ - %@",o[@"playerName"],o[@"score"]);
        }
    }];
   
    // now do the same query but add a "where clause"
    [query whereKey:@"playerName" equalTo:@"Sean Plott"];
   
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"multiple objects query complete: found %d object(s)",objects.count);
        for (FPObject *o in objects) {
            NSLog(@"object: %@ - %@",o[@"playerName"],o[@"score"]);
        }
    }];

```

