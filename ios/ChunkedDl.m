#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ChunkedDl, NSObject)

RCT_EXTERN_METHOD(download:(NSString)url toFile:(NSString)toFile
                  contentLength:(int)contentLength
                  chunkSize:(int)chunkSize
                  headers:(NSDictionary*)headers
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopDownload:(int)jobId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(suspendDownload:(int)jobId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(resumeDownload:(int)jobId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
