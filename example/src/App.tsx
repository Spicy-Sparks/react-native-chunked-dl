import * as React from 'react';
import FS from 'react-native-fs';
import { StyleSheet, View, Text } from 'react-native';
import { download, stopDownload } from 'react-native-chunked-dl';

export default function App() {
  React.useEffect(() => {
    console.log(FS.DocumentDirectoryPath + '/playback.m4a');
    const startDate = new Date().getTime();
    const {
      promise,
      jobId
    } = download({
      url: 'https://google.com',
      toFile: FS.DocumentDirectoryPath + '/playback.m4a',
      contentLength: 121818709,
      chunkSize: 1024 * 1024 * 10,
      headers: {
        'Accept-Language': 'en-US,en;q=0.5'
      }
    })

    /*setTimeout(() => {
      stopDownload(jobId)
    }, 7 * 1000)*/

    promise.then(() => {
      const endDate = new Date().getTime();
      console.log('completed in', endDate - startDate);
    })
    .catch(() => {
      const endDate = new Date().getTime();
      console.log('failed in', endDate - startDate);
    });
  }, []);

  return (
    <View style={styles.container}>
      <Text>Download</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
