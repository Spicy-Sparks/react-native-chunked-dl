# react-native-chunked-dl

Chunked download for react-native

## Installation

```sh
npm install react-native-chunked-dl
```

## Usage

```js
import { request } from 'react-native-chunked-dl';

// ...

const result = await request({
    url: 'https://google.com',
    toFile: FS.DocumentDirectoryPath + '/playback.m4a',
    contentLength: 3548166,
    chunkSize: 1024 * 1024 * 10,
    headers: {
        'Content-Type': 'application/text',
    }
});
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
