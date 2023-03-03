package com.chunkeddl

import com.facebook.react.bridge.*
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class ChunkedDlModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun request(url: String, toFile: String, contentLength: Int, chunkSize: Int, headers: ReadableMap, promise: Promise) {

    var start = 0
    var end = if (chunkSize <= 0) 1024 * 1024 * 10 else chunkSize

    var file = File(toFile)
    file.createNewFile()

    fun getNextChunk() {
      if (end >= contentLength){
        end = contentLength
      }

      val isFinalChunk = end >= contentLength

      try {
        val url = URL("${url}&range=${start}-${end}")
        val conn = url.openConnection() as HttpURLConnection
        conn.requestMethod = "GET"

        for(header in headers.entryIterator)
          conn.setRequestProperty(header.key, header.value as String)

        if (conn.responseCode == HttpURLConnection.HTTP_OK) {
          val inputStream = conn.inputStream
          if (!file.exists()) {
            promise.reject("File does not exists")
          }
          file.appendBytes(inputStream.readBytes())
          inputStream.close()
        } else {
          promise.reject("HTTP Error: ${conn.responseCode} ${conn.responseMessage}")
        }

        conn.disconnect()
      } catch (e: Exception) {
        promise.reject(e.message)
      }

      if(!isFinalChunk) {
        start = end + 1
        end += chunkSize
        getNextChunk()
        return
      }

      promise.resolve(true)
    }

    getNextChunk()
  }

  companion object {
    const val NAME = "ChunkedDl"
  }
}
