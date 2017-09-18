import React, { Component } from 'react';
import { Text, StyleSheet } from 'react-native';

export default class StatusText extends Component {
  render() {
    const { repo } = this.props;
    return (
      <Text style={styles.repoText}>{repo}</Text>
    );
  }
}

const styles = StyleSheet.create({
  repoText: {
    textAlign: 'right',
    backgroundColor: 'transparent',
    fontSize: 12,
    color: '#BBBBCC'
  }
});
