#import <React/RCTBridgeModule.h>
#import "ChunkedDlHandler.h"

typedef void (^CompletionHandler)(void);

@implementation ChunkedDlHandler

static NSMutableDictionary *chs;
static NSMutableDictionary *uuids;

#pragma mark - instance

+ (instancetype)sharedInstance {
    static ChunkedDlHandler *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
      if (instance == nil) {
          instance = [[ChunkedDlHandler alloc] init];
      }
    });

    return instance;
}

+(void)setUuidForJobId: (NSNumber*)jobId uuid: (NSString*)uuid
{
    if (!uuids) uuids = [[NSMutableDictionary alloc] init];
    if (!chs) chs = [[NSMutableDictionary alloc] init];
    [uuids setValue:uuid forKey:jobId];
}

+(NSString*)getUuidForJobId: (NSNumber *)jobId
{
    if (uuids)
        return [uuids objectForKey:jobId];

    return nil;
}

+(void)removeUuidForJobId: (NSNumber *)jobId
{
    if (uuids)
        [uuids removeObjectForKey:jobId];
}

+(void)setCompletionHandlerForIdentifier: (NSString *)identifier completionHandler: (CompletionHandler)completionHandler
{
    if (!chs) chs = [[NSMutableDictionary alloc] init];
    [chs setValue:completionHandler forKey:identifier];
}

+(CompletionHandler)getCompletionHandlerForIdentifier: (NSString *)identifier
{
    if (chs)
        return [chs objectForKey:identifier];

    return nil;
}

+(void)removeCompletionHandlerForIdentifier: (NSString *)identifier
{
    if (chs)
        [chs removeObjectForKey:identifier];
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
