import React from 'react';
import { Text, View, TouchableHighlight, StyleSheet, TouchableOpacity, Linking } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

const ExpandedPRRow = ({ show, githubUrl, analysisUrl, synchronize }) => {
  const openInBrowser = (url) => {
    Linking.openURL(url);
  };

  return (
    <View style={[{ display: show ? 'flex' : 'none' }, styles.hiddenView]}>
      <TouchableOpacity onPress={() => openInBrowser(githubUrl)}>
        <View style={styles.buttonView}>
          <Icon name='github-square' color='#000' size={24} />
          <Text>Open on Github</Text>
        </View>
      </TouchableOpacity>
      <TouchableOpacity onPress={synchronize}>
        <View style={styles.buttonView}>
          <Icon name='refresh' color='#000' size={24} />
          <Text>Synchronize</Text>
        </View>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => openInBrowser(analysisUrl)}>
        <View style={styles.buttonView}>
          <Icon name='code' color='#000' size={24} />
          <Text>Code Analysis</Text>
        </View>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  buttonView: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center'
  },
  hiddenView: {
    paddingTop: 10,
    paddingBottom: 10,
    paddingRight: 5,
    paddingLeft: 5,
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between'
  }
});

export default ExpandedPRRow;