@objc(ChunckedDownload)
class ChunckedDownload: NSObject {

    @objc(request:toFile:contentLength:chunkSize:headers:withResolver:withRejecter:)
    func request(url: NSString, toFile: NSString, contentLength: Int, chunkSize: Int, headers: NSDictionary, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
      
        var start = 0
        var end = chunkSize <= 0 ? 1024 * 1024 * 10 : chunkSize
        
        let uuid = UUID().uuidString
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: uuid)
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let fileURL = URL(fileURLWithPath: toFile as String, isDirectory: false)
        
        do {
            try? "".write(to: fileURL, atomically: true, encoding: .utf8)
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

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if (error != nil || data == nil) {
                    reject("err", error?.localizedDescription, error)
                }
                
                do {
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        try? fileHandle.seekToEndOfFile()
                        try? fileHandle.write(data!)
                        try? fileHandle.closeFile()
                    } else {
                        try? data!.write(to: fileURL)
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
        
        getNextChunk()
  }
}
