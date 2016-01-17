//
//  ZIKSession.h
//  ReactiveLearning
//
//  Created by Matthew Dobson on 4/3/15.
//  Copyright (c) 2015 Matthew Dobson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ZIKQuery.h"

/**
 The `ZIKSession` class manages most API transactions that take place with the Zetta HTTP API. It uses reactive programming to provide a robust model of API traversal and filtering.
 */
@interface ZIKSession : NSObject

typedef void (^ServerCompletionBlock)(NSError *error, ZIKServer *server);
typedef void (^DevicesCompletionBlock)(NSError *error, NSArray *devices);

/**
 The current endpoint the `ZIKSession` is targeting. All requests will be made against this endpoint unless specifically provided another URL.
 */
@property (nonatomic, retain, readonly) NSURL* apiEndpoint;

///---------------------------
/// @name Initialization
///---------------------------

/**
 Initialize the singleton for this session.
 
 @return The newly initialized `ZIKSession`.
 */
+(instancetype) sharedSession;

///---------------------------
/// @name Crawling the Zetta API
///---------------------------

/**
 Load the root representation of a Zetta HTTP API. 
 
 @param url The url of the particular endpoint to load.
 
 @return An RACSignal object that can be subscribed to and operated on using ReactiveCocoa extensions.
 */
- (RACSignal *) root:(NSURL *)url;

/**
 Load any representation of a Zetta HTTP API.
 
 @param url The url of the particular resource to load.
 
 @return An RACSignal object that can be subscribed to and operated on using ReactiveCocoa extensions.
 */
- (RACSignal *) load:(NSURL *)url;

/**
 Load servers from a root representation of a Zetta HTTP API.
 
 @param rootObservable The RACSignal result of retrieving the root of a Zetta HTTP API.
 
 @return An RACSignal object that can be subsribed to and operated on. This RACSignal will produce `ZIKServer` objects.
 */
- (RACSignal *) servers:(RACSignal *)rootObservable;

/**
 Load devices from a server representation of a Zetta HTTP API.
 
 @param serverObservable The RACSignal result of retrieving a server from a Zetta HTTP API.
 
 @return An RACSignal object that can be subsribed to and operated on. This RACSignal will produce `ZIKDevice` objects.
 */
- (RACSignal *) devices:(RACSignal *)serverObservable;

///---------------------------
/// @name Querying for servers and devices
///---------------------------

/**
 Query devices from a Zetta HTTP API.
 
 @param queries An `NSArray` of `ZIKQuery` objects containing information on the devices that should be retrieved.
 
 @return An RACSignal object that can be subscribed to and operated on. This RACSignal will produce `ZIKDevice` objects.
 */
- (RACSignal *) queryDevices:(NSArray *)queries;

/**
 Search for a Zetta server by name.
 
 @param name An `NSString` name of a particular Zetta server attached to the API.
 
 @return An RACSignal object that can be subscribed to and operated on. This RACSignal will produce `ZIKServer` objects.
 */
- (RACSignal *) getServerByName:(NSString *)name;

/**
 Search for a Zetta server by name.
 
 @param name An `NSString` name of a particular Zetta server attached to the API.
 @param block A block object that will be called when the HTTP transaction completes. This block has no return value and has two arguments: The potential error from the HTTP transaction, and the `ZIKServer` object representing the server.
 */
- (void) getServerByName:(NSString *)name withCompletion:(ServerCompletionBlock)block;

/**
 Query devices from a Zetta HTTP API.
 
 @param queries An `NSArray` of `ZIKQuery` objects containing information on the devices that should be retrieved.
 @param block A block object that will be called when the HTTP transaction completes. This block has no return value and has two arguments: The potential error from the HTTP transaction, and an `NSArray` of `ZIKDevice` objects that fullfil the query.
 */
- (void) queryDevices:(NSArray *)queries withCompletion:(DevicesCompletionBlock)block;

@end
