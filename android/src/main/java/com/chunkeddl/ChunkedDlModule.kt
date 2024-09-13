package com.chunkeddl

import android.util.SparseArray
import com.facebook.react.bridge.*

class ChunkedDlModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  private val downloaders: SparseArray<Downloader> = SparseArray()

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun download(options: ReadableMap, promise: Promise) {
    try {
      val jobId = options.getInt("jobId")
      val params = DownloadParams()
      params.url = options.getString("url")
      params.toFile = options.getString("toFile")?.replace("file://", "")
      params.headers = options.getMap("headers")
      params.contentLength = options.getInt("contentLength")
      params.chunkSize = options.getInt("chunkSize")
      params.onTaskCompleted = object : DownloadParams.OnTaskCompleted {
        override fun onTaskCompleted(res: DownloadResult?) {
          if (res!!.exception == null) {
            val infoMap = Arguments.createMap()
            infoMap.putInt("jobId", jobId)
            infoMap.putInt("statusCode", res.statusCode)
            infoMap.putDouble("bytesWritten", res.bytesWritten.toDouble())
            promise.resolve(infoMap)
          } else {
            promise.reject(options.getString("toFile"), res.exception)
          }
        }
      }
      val downloader = Downloader(reactContext)
      downloader.execute(params)
      this.downloaders.put(jobId, downloader)
    } catch (ex: Exception) {
      ex.printStackTrace()
      promise.reject(options.getString("toFile"), ex)
    }
  }

  @ReactMethod
  fun stopDownload(jobId: Int) {
    val downloader: Downloader = this.downloaders.get(jobId)
    if (downloader != null) {
      downloader.stop()
    }
  }

  companion object {
    const val NAME = "ChunkedDl"
  }
}
