import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-chunked-dl' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ChunkedDl = NativeModules.ChunkedDl
  ? NativeModules.ChunkedDl
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

let jobId: number = 0

var getJobId = () => {
  jobId += 1;
  return jobId;
}

export function download(options: {
  url: string;
  toFile: string;
  contentLength: number;
  chunkSize?: number;
  headers?: { [key: string]: string };
}): {
  jobId: number,
  promise: Promise<any>
} {
  const jobId = getJobId()
  const promise = ChunkedDl.download({
    ...options,
    jobId
  })
  return {
    jobId,
    promise
  }
}

export function stopDownload(jobId: number): Promise<any> {
  return ChunkedDl.stopDownload(jobId);
}

export function resumeDownload(jobId: number): Promise<any> {
  return ChunkedDl.resumeDownload(jobId);
}