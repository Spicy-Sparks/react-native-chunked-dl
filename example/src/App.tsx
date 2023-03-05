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
      // /* short */ url: 'https://rr4---sn-uxaxpu5ap5-ca9e.googlevideo.com/videoplayback?expire=1677960708&ei=pFEDZLztIojs1wKUx6KwAw&ip=87.3.73.240&id=o-ADPWpxaFI16Awe3f1-qmUvUFY9OpuXqe4AAnlx33BTCH&itag=140&source=youtube&requiressl=yes&mh=iC&mm=31%2C29&mn=sn-uxaxpu5ap5-ca9e%2Csn-hpa7zn76&ms=au%2Crdu&mv=m&mvi=4&pl=24&gcr=it&initcwndbps=1335000&spc=H3gIhrI7V3qJ167WeP7rmsujO6X_YBI&vprv=1&svpuc=1&mime=audio%2Fmp4&gir=yes&clen=3548166&dur=219.043&lmt=1628119430148102&mt=1677938710&fvip=6&keepalive=yes&fexp=24007246&c=ANDROID&txp=5532434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRQIhAJi3Q_qset7NcB3Yg8jcFAiKBvZ1xx9arlako6dS5UluAiApud9KIl6L26hQjHf5eLyU03t4qOdcjM8-lGFtwB03jw%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgDQ7egQ_O8jReLI0d-9ZkzzqdgKP2dSy8roUBxZT49p4CIQCkf2OMmyPXLAqpWffH_-kE6SQVk_TYbTsEIqZ-kNTPSQ%3D%3D',
      /* long */ url: 'https://rr4---sn-uxaxpu5ap5-ca9e.googlevideo.com/videoplayback?expire=1678038932&ei=NIMEZKm8JvLhx_APzOKvmAw&ip=87.3.73.240&id=o-APiOwy7kFfjYyzFrUEjzu95ODeBV8tj8FKXHdLbFd29j&itag=140&source=youtube&requiressl=yes&mh=T0&mm=31%2C29&mn=sn-uxaxpu5ap5-ca9e%2Csn-hpa7znzr&ms=au%2Crdu&mv=m&mvi=4&pl=24&gcr=it&initcwndbps=1572500&spc=H3gIhg-U3ZxGgOfgC-qIdJ9u5q1iN4M&vprv=1&svpuc=1&mime=audio%2Fmp4&gir=yes&clen=121818709&dur=7527.119&lmt=1677256272261033&mt=1678016944&fvip=3&keepalive=yes&fexp=24007246&c=ANDROID&txp=4532434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRQIhAPfC-QoqHgHcmREeNsdUzgibewcWdIFZSEdXlLvz4hUNAiB1YSHXEz5x4e9MoksO3tTLqv2jpRVLLe5-VZIgYKkAow%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgAqOMLS98t91gQyYz25_WrKrB40r8IAarlraCsvm9pq0CIGmNGlmmNoSCpPSh98MNeJY8tK4_9qFKyAMWWFu2OBj_',
      toFile: FS.DocumentDirectoryPath + '/playback.m4a',
      contentLength: 121818709,
      chunkSize: 1024 * 1024 * 10
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
