import * as React from 'react';
import FS from 'react-native-fs';
import { StyleSheet, View, Text } from 'react-native';
import { request } from 'react-native-chunked-download';

export default function App() {
  React.useEffect(() => {
    console.log(FS.DocumentDirectoryPath + '/playback.m4a');
    const startDate = new Date().getTime();
    request({
      url: 'https://google.com',
      toFile: FS.DocumentDirectoryPath + '/playback.m4a',
      contentLength: 3548166,
      chunkSize: 1024 * 1024 * 10,
      headers: {
        'Content-Type': 'application/text',
      },
    })
      .then(() => {
        const endDate = new Date().getTime();
        console.log('completed in', startDate - endDate);
      })
      .catch(() => {
        const endDate = new Date().getTime();
        console.log('failed in', startDate - endDate);
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
