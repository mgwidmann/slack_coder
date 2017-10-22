import React from 'react';
import { View, Text, TouchableHighlight, StyleSheet, Linking, Alert } from 'react-native';

const StatusText = ({ link, status, children }) => {
  const openLink = () => {
    if (link) {
      Linking.openURL(link);
    } else {
      Alert.alert('No build URL for this pull request yet.');
    }
  }

  const statusColor = () => {
    switch(status) {
      case 'SUCCESS':  return '#5cb85c';
      case 'FAILURE':  return '#d9534f';
      case 'ERROR':    return '#d9534f';
      case 'CONFLICT': return '#8b33b7';
      case 'PENDING':  return '#f0ad4e';
      default:         return '#5bc0de';
    }
  }

  return (
    <View style={styles.statusView}>
      <TouchableHighlight onPress={openLink} style={[{backgroundColor: statusColor()}, styles.button]}>
        <Text style={styles.statusText}>{status || 'UNKNOWN'}</Text>
      </TouchableHighlight>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  statusView: {
    justifyContent: 'flex-end',
    flexDirection: 'column'
  },
  button: {
    borderRadius: 3,
    borderWidth: 1,
    borderColor: 'transparent',
    paddingRight: 2,
    paddingLeft: 2,
    marginBottom: 10
  },
  statusText: {
    color: '#fff',
    height: 20,
    textAlign: 'center'
  }
});

export default StatusText;