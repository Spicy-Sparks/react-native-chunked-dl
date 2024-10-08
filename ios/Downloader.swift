@objc(Downloader)
class Downloader: NSObject, URLSessionDownloadDelegate {
    
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
    var downloaded: Int = 0
    var contentId: String = ""
    var onProgress: (([String: Any]) -> Void)?
    
    init(jobId: Int) {
        self.jobId = jobId
    }

    func download(url: String, toFile: String, contentLength: Int, chunkSize: Int, headers: NSDictionary, contentId: String, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        resolveCallback = resolve
        rejectCallback = reject
        
        self.url = url
        self.headers = headers
        self.contentLength = contentLength
        self.contentId = contentId
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
        
        let uuid = UUID().uuidString

        ChunkedDlHandler.setUuidForJobId(jobId as NSNumber, uuid: uuid)
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: uuid)
        sessionConfig.isDiscretionary = false
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)

        task = session.downloadTask(with: request)
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloaded += Int(bytesWritten)

        if !contentId.isEmpty {
            onProgress?([
                "bytesWritten": downloaded,
                "contentLength": contentLength,
                "contentId": contentId
            ])
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try merge(files: [location], to: self.fileURL!)
        }
        catch {
            rejectCallback!("err", "Cannot write on file", nil)
            return
        }

        var downloadedBytes = 0
        let filePath = location.path
        let fileExists = FileManager.default.fileExists(atPath: filePath)
        if fileExists {
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
                let fileSizeNumber = fileAttributes[FileAttributeKey.size] as! NSNumber
                downloadedBytes = fileSizeNumber.intValue
            } catch {}
        }
        
        if(downloadedBytes <= 0) {
            rejectCallback!("err", "Invalid or empty chunk", nil)
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: location.absoluteString)
        } catch {}
        
        let isFinalChunk = end >= contentLength
        
        let uuid = ChunkedDlHandler.getUuidForJobId(jobId as NSNumber)
        
        if(uuid != nil){
            
            let ch = ChunkedDlHandler.getCompletionHandler(forIdentifier: uuid!)
            
            if(ch != nil){
                ch!()
            }
            
            ChunkedDlHandler.removeCompletionHandler(forIdentifier: uuid!)
            
        }
        
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            if (self.stopTask) {
                rejectCallback!("err", "Download aborted", error)
                return
            }
            
            rejectCallback!("err", "Cannot write on file", error)
            return
        }
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
    
    func merge(files: [URL], to destination: URL, chunkSize: Int = 20000000)  {
            for partLocation in files {
                // create a stream that reads the data above
                let stream: InputStream
                stream = InputStream.init(url: partLocation)!
                // begin reading
                stream.open()
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: chunkSize)
                //            var writeData : Data = Data()
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: chunkSize)

                    var writeData:Data = Data()
                    writeData.append(buffer, count: read)
                    if let outputStream = OutputStream(url: destination, append: true) {
                        outputStream.open()
                        outputStream.write(buffer, maxLength: writeData.count)
                        outputStream.close()
                        writeData.removeAll()
                    }
                }
                stream.close()
                buffer.deallocate()

            }
        }
}
