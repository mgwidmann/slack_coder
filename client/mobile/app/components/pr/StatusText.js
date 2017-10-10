import React, { Component } from 'react';
import { View, Text, TouchableHighlight, StyleSheet, Linking, Alert } from 'react-native';

export default class StatusText extends Component {
  constructor(props) {
    super(props);
    this.statusColor = this.statusColor.bind(this);
    this.openLink = this.openLink.bind(this);
  }

  openLink() {
    if (this.props.link) {
      Linking.openURL(this.props.link);
    } else {
      Alert.alert('There is no link to open!');
    }
  }

  statusColor() {
    switch(this.props.status) {
      case 'SUCCESS':  return '#5cb85c';
      case 'FAILURE':  return '#d9534f';
      case 'ERROR':    return '#d9534f';
      case 'CONFLICT': return '#8b33b7';
      case 'PENDING':  return '#f0ad4e';
      default:         return '#5bc0de';
    }
  }

  render() {
    const { status } = this.props;
    return (
      <View style={styles.statusView}>
        <TouchableHighlight onPress={this.openLink} style={[{backgroundColor: this.statusColor()}, styles.button]}>
          <Text style={styles.statusText}>{status || 'UNKNOWN'}</Text>
        </TouchableHighlight>
        {this.props.children}
      </View>
    );
  }
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
