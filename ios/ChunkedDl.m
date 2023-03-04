#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ChunkedDl, NSObject)

RCT_EXTERN_METHOD(request:(NSString)url toFile:(NSString)toFile
                  contentLength:(int)contentLength
                  chunkSize:(int)chunkSize
                  headers:(NSDictionary*)headers
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
