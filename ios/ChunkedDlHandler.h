//
//  ChunkedDlHandler.h
//  react-native-chunked-dl
//
//  Created by Marco on 05/03/23.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>

typedef void (^CompletionHandler)(void);

@interface ChunkedDlHandler : NSObject

+(void)setUuidForJobId: (NSNumber*)jobId uuid: (NSString*)uuid;

+(NSString*)getUuidForJobId: (NSNumber *)jobId;

+(void)removeUuidForJobId: (NSNumber *)jobId;

+(void)setCompletionHandlerForIdentifier: (NSString *)identifier completionHandler: (CompletionHandler)completionHandler;

+(CompletionHandler)getCompletionHandlerForIdentifier: (NSString *)identifier;

+(void)removeCompletionHandlerForIdentifier: (NSString *)identifier;

@end
