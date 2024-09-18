package com.chunkeddl

import android.os.AsyncTask
import android.os.Bundle
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.atomic.AtomicBoolean

class DownloadResult {
  var statusCode = 0
  var bytesWritten: Long = 0
  var exception: Exception? = null
}

class DownloadParams {
  interface OnTaskCompleted {
    fun onTaskCompleted(res: DownloadResult?)
  }

  var contentId: String? = null
  var url: String? = null
  var toFile: String? = null
  var headers: ReadableMap? = null
  var chunkSize: Int = 0
  var contentLength: Int = 0

  var onTaskCompleted: OnTaskCompleted? = null
}
open class Downloader (private val reactContext: ReactApplicationContext): AsyncTask<DownloadParams, LongArray, DownloadResult>() {
  private var params: DownloadParams = DownloadParams()
  private var res: DownloadResult = DownloadResult()
  private val abort: AtomicBoolean = AtomicBoolean(false)
  private var conn: HttpURLConnection? = null

  override fun doInBackground(vararg args: DownloadParams?): DownloadResult? {
    res = DownloadResult()
    if(args[0] == null) {
      res.exception = Exception("Invalid params")
      return res
    }
    params = args[0]!!
    Thread {
      try {
        download(this.params, res)
        this.params.onTaskCompleted?.onTaskCompleted(res)
      } catch (ex: java.lang.Exception) {
        res.exception = ex
        this.params.onTaskCompleted?.onTaskCompleted(res)
      }
    }.start()
    return res
  }

  private fun sendEvent(reactContext: ReactContext, eventName: String, params: WritableMap) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  private fun download(param: DownloadParams, res: DownloadResult) {
    var start = 0
    var downloaded = 0
    var end = if (params.chunkSize <= 0) 1024 * 1024 * 10 else params.chunkSize

    var file = File(params.toFile)
    var inputStream : InputStream
    var outputStream : OutputStream = FileOutputStream(file)

    fun getNextChunk() {
      if (abort.get())
        throw Exception("Download has been aborted")

      if (end >= params.contentLength) {
        end = params.contentLength
      }

      val isFinalChunk = end >= params.contentLength

      val url = URL("${params.url}&range=${start}-${end}")
      conn = url.openConnection() as HttpURLConnection
      conn!!.requestMethod = "GET"

      if (params.headers != null) {
        for (header in params.headers!!.entryIterator)
          conn!!.setRequestProperty(header.key, header.value as String)
      }

      if (conn!!.responseCode == HttpURLConnection.HTTP_OK) {
        if (abort.get())
          throw Exception("Download has been aborted")

        res.statusCode = conn!!.responseCode
        inputStream = conn!!.inputStream
        if (!file.exists()) {
          throw Exception("File does not exist")
        }
        res.bytesWritten = conn!!.contentLength.toLong()

        val bufferSize = 8 * 1024 // 8 KB buffer size
        val buffer = ByteArray(bufferSize)
        var bytesRead = inputStream.read(buffer)
        while (bytesRead != -1) {
          outputStream.write(buffer, 0, bytesRead)

          // Increment downloaded by the number of bytes just written
          downloaded += bytesRead
          Log.d("Downloaded var:", "Downloaded: $downloaded, ContentLength: ${params.contentLength}")

          if (params.contentId != null) {
            val paramsMap = Arguments.createMap()
            paramsMap.putInt("bytesWritten", downloaded)
            paramsMap.putString("contentId", params.contentId)
            paramsMap.putInt("contentLength", params.contentLength)
            sendEvent(reactContext, eventName = "downloadProgress", params = paramsMap)
          }

          bytesRead = inputStream.read(buffer)
        }

        outputStream.flush()
        inputStream.close()
      } else {
        if (abort.get())
          throw Exception("Download has been aborted")

        res.statusCode = conn!!.responseCode
        throw Exception("HTTP Error: ${conn!!.responseCode} ${conn!!.responseMessage}")
      }

      conn!!.disconnect()
      conn = null

      if (!isFinalChunk) {
        start = end + 1
        end += params.chunkSize
        getNextChunk()
        return
      }

      outputStream.close()
    }

    getNextChunk()
  }

  fun stop() {
    abort.set(true)
    conn?.disconnect()
    try {
      File(params.toFile).delete()
    } catch (ex: Exception) {}
  }
}
