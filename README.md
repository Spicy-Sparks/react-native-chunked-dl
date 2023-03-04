# react-native-chunked-dl

Chunked download for react-native

## Installation

```sh
npm install react-native-chunked-dl
```

## Usage

```js
import { download, stopDownload } from 'react-native-chunked-dl';

// ...

const {
    jobId,
    promise
} = download({
    url: 'https://google.com',
    toFile: FS.DocumentDirectoryPath + '/playback.m4a',
    contentLength: 3548166,
    chunkSize: 1024 * 1024 * 10,
    headers: {
        'Content-Type': 'application/text',
    }
});

promise.then((result) => {
    console.log(result.statusCode)
}).catch((err) => {
    console.log(err)
});

setTimeout(() => {
    stopDownload(jobId)
}, 1000)
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
