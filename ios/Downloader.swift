@objc(Downloader)
class Downloader: NSObject, URLSessionDataDelegate {
    
    var jobId : Int
    var url : String = ""
    var fileURL : URL? = nil
    var task : URLSessionTask = URLSessionTask()
    var stopTask : Bool = false
    var start : Int = 0
    var end : Int = 0
    var resolveCallback : RCTPromiseResolveBlock? = nil
    var rejectCallback : RCTPromiseRejectBlock? = nil
    var contentLength : Int = 0
    var chunkSize : Int = 0
    var headers : NSDictionary = [:]
    var tmpChunk : Data = Data.init()
    
    init(jobId: Int) {
        self.jobId = jobId
    }

    func download(url: String, toFile: String, contentLength: Int, chunkSize: Int, headers: NSDictionary, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        resolveCallback = resolve
        rejectCallback = reject
        
        self.url = url
        self.headers = headers
        self.contentLength = contentLength
        self.chunkSize = chunkSize
        self.start = 0;
        self.end = chunkSize <= 0 ? 1024 * 1024 * 10 : chunkSize
        
        fileURL = URL(fileURLWithPath: toFile as String, isDirectory: false)
        
        do {
            try "".write(to: fileURL!, atomically: true, encoding: .utf8)
        }
        catch {
            reject("err", "Cannot create file", error)
        }
        
        if(!self.stopTask){
            self.getNextChunk()
        }
    }
    
    func getNextChunk() {
        if (end >= contentLength){
            end = contentLength
        }
        
        let finalUrl = URL(string: "\(url)&range=\(start)-\(end)")!
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        
        for (key, value) in headers {
            request.addValue(value as! String, forHTTPHeaderField: key as! String)
        }
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: String(jobId))
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)

        task = session.dataTask(with: request)
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        tmpChunk.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            tmpChunk = Data.init()
            rejectCallback!("err", "Cannot write on file", error)
            return
        }
        
        do {
            if let fileHandle = try? FileHandle(forWritingTo: self.fileURL!) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(tmpChunk)
                fileHandle.closeFile()
            } else {
                try tmpChunk.write(to: self.fileURL!)
            }
            tmpChunk = Data.init()
        }
        catch {
            tmpChunk = Data.init()
            rejectCallback!("err", "Cannot write on file", NSError())
            return
        }
        
        let isFinalChunk = end >= contentLength
        
        if(!isFinalChunk) {
            start = end + 1
            end += chunkSize
            self.getNextChunk()
            return
        }
        
        resolveCallback!([
            "jobId": jobId,
            "statusCode": 200,
            "bytesWritten": contentLength
        ])
    }
    
    func stopDownload(){
        
        if(task.state == URLSessionTask.State.running){
            self.stopTask = true
            task.cancel()
            
            if FileManager.default.fileExists(atPath: fileURL!.path) {
                // delete file
                do {
                    try FileManager.default.removeItem(atPath: fileURL!.path)
                } catch {
                    //print("Could not delete file, probably read-only filesystem")
                }
            }
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
