//
//  FPTests.m
//  FPTests
//
//  Copyright (c) 2014 kramden.com. All rights reserved.
//

/**
 * These tests require solr to be running as the configured backend in fp_constants.h
 */

#import <XCTest/XCTest.h>

// fp
#import "FPObject.h"
#import "FPQuery.h"

@interface FPTests : XCTestCase

@end

@implementation FPTests

// test constants
NSString *testClassName = @"GameScore";
NSString *property = @"playerName";
NSString *value = @"Sean Plott";

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void) testObjectCreation
{
    FPObject *object = [FPObject objectWithClassName:testClassName];
    XCTAssert(object != nil);
}

-(void) testObjectSetProperty
{
    FPObject *object = [FPObject objectWithClassName:testClassName];
    object[property] = value;
    XCTAssertEqual(object[property], value);
}

-(void) testObjectSaveRetrieve
{
    FPObject *object = [FPObject objectWithClassName:testClassName];
    object[property] = value;
   [object saveInBackground];
    
    FPQuery *query = [FPQuery queryWithClassName:testClassName];
    [query whereKey:property equalTo:value];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        id obj = [objects firstObject];
        NSString *val = obj[property];;
        XCTAssertEqual(value,val);
    }];
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


@end
