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

export function request(options: {
  url: string;
  toFile: string;
  contentLength: number;
  chunkSize?: number;
  headers?: { [key: string]: string };
}): Promise<number> {
  return ChunkedDl.request(
    options.url,
    options.toFile,
    options.contentLength,
    options.chunkSize ?? 0,
    options.headers ?? {}
  );
}
