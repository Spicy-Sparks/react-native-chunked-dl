@objc(Downloader)
class Downloader: NSObject {
    
    var jobId : Int
    var task : URLSessionTask = URLSessionTask()
    var stopTask : Bool = false
    
    init(jobId: Int) {
        self.jobId = jobId
    }

    func download(url: String, toFile: String, contentLength: Int, chunkSize: Int, headers: NSDictionary, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
      
        var start = 0;
        var end = chunkSize <= 0 ? 1024 * 1024 * 10 : chunkSize;
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let fileURL = URL(fileURLWithPath: toFile as String, isDirectory: false)
        
        do {
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
        }
        catch {
            reject("err", "Cannot create file", error)
        }
        
        func getNextChunk() -> Void {
            if (end >= contentLength){
                end = contentLength
            }

            let isFinalChunk = end >= contentLength
            
            let finalUrl = URL(string: "\(url)&range=\(start)-\(end)")!
            
            var request = URLRequest(url: finalUrl)
            request.httpMethod = "GET"
            
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key as! String)
            }

            task = URLSession.shared.dataTask(with: request) { data, response, error in
                if (error != nil || data == nil) {
                    reject("err", error?.localizedDescription, error)
                }
                
                do {
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data!)
                        fileHandle.closeFile()
                    } else {
                        try data!.write(to: fileURL)
                    }
                }
                catch {
                    reject("err", "Cannot write on file", error)
                }
                
                if(!isFinalChunk) {
                    start = end + 1
                    end += chunkSize
                    getNextChunk()
                    return
                }
                
                resolve(true)
            }
            
            task.resume()
        }
        
        if(!self.stopTask){
            getNextChunk()
        }
  }
    
    func stopDownload(){
        
        if(task.state == URLSessionTask.State.running){
            self.stopTask = true
            task.cancel()
        }
        
    }
    
    func suspendDownload(){
        
        if(task.state == URLSessionTask.State.running){
            self.stopTask = true
            task.suspend()
        }
        
    }
    
    func resumeDownload(){
        
        if(task.state == URLSessionTask.State.suspended){
            self.stopTask = false
            task.resume()
        }
        
    }
}
