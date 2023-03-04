@objc(ChunkedDl)
class ChunkedDl: NSObject {
    
    var downloaders: [Int: Downloader] = [:]

    @objc(download:withResolver:withRejecter:)
    func request(options: NSDictionary, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        let jobId : Int = options["jobId"] as! Int;
        let fromUrl : String = options["fromUrl"] as! String;
        let toFile : String = options["toFile"] as! String;
        let headers : NSDictionary = options["headers"] as! NSDictionary;
        let chunkSize : Int = options["chunkSize"] as? Int ?? 1024 * 1024 * 10
        let contentLength : Int = options["contentLength"] as! Int
        let background = options["background"];
        
        let downloader = Downloader(jobId: jobId)
        
        downloaders[jobId] = downloader
      
       // create downloader instance and start the download
        downloader.download(url: fromUrl, toFile: toFile, contentLength: contentLength, chunkSize: chunkSize, headers: headers, resolve: resolve, reject: reject)
  }
    
    @objc(stopDownload:withResolver:withRejecter:)
    func stopDownload(jobId: Int, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        let downloader = downloaders[jobId]
        
        if(downloader != nil){
            downloader?.stopDownload()
        }
        
        resolve(true)
  }
    
    @objc(suspendDownload:withResolver:withRejecter:)
    func suspendDownload(jobId: Int, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        let downloader = downloaders[jobId]
        
        if(downloader != nil){
            downloader?.suspendDownload()
        }
        
        resolve(true)
  }
    
    @objc(resumeDownload:withResolver:withRejecter:)
    func resumeDownload(jobId: Int, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        let downloader = downloaders[jobId]
        
        if(downloader != nil){
            downloader?.resumeDownload()
        }
        
        resolve(true)
  }
}
