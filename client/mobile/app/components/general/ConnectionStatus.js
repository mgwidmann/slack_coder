import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

import { SECONDARY_COLOR } from '../../styles/constants';

const ConnectionStatus = ({ offline, reconnecting }) => {
  if (offline || reconnecting) {
    const style = offline ? 'offline' : 'reconnecting';
    const message = offline ? 'Connection lost!' : 'Reconnecting...'
    return (
      <View style={[styles.container, styles[style]]}>
        <Text style={[styles.text, styles[`${style}Text`]]}>{message}</Text>
      </View>
    );
  } else {
    return null;
  }
}

const styles = StyleSheet.create({
  container: {
    height: 20,
    paddingTop: 2,
    paddingBottom: 2
  },
  offline: {
    backgroundColor: SECONDARY_COLOR
  },
  reconnecting: {
    backgroundColor: '#FFFF00'
  },
  text: {
    textAlign: 'center',
    fontSize: 12
  },
  offlineText: {
    color: 'white'
  },
  reconnectingText: {
    color: 'black'
  }
});

export default ConnectionStatus;