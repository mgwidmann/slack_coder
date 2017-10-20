import React, { Component } from 'react';
import { AsyncStorage, StyleSheet, View, Image, Text, TextInput } from 'react-native';
import { BarCodeScanner, Permissions } from 'expo';

import mainStyles from '../styles/main';

class Login extends Component {
  state = {
    hasCameraPermission: null,
  }

  componentDidMount() {
    this._loadInitialState().done();
  }

  async _loadInitialState() {
    const value = await AsyncStorage.getItem('@SlackCoder:token');
    this.props.setToken(value);
    if (__DEV__) {
      this.setState({ hasCameraPermission: true });
    } else {
      if (value === null) {
        const { status } = await Permissions.askAsync(Permissions.CAMERA);
        this.setState({ hasCameraPermission: status === 'granted' });
      }
    }
  }

  _handleBarCodeRead({ data }) {
    this.props.setToken(data);
    AsyncStorage.setItem('@SlackCoder:token', data);
  }

  render() {
    const { hasCameraPermission } = this.state;

    if (hasCameraPermission === true) {
      return (
        <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer]}>
          {__DEV__ &&
            <TextInput
              style={{ height: 40, width: '75%', backgroundColor: 'white', borderColor: 'gray', borderWidth: 1 }}
              onChangeText={(token) => { this._handleBarCodeRead({ data: token }); }}
            />
          }
          <Image source={require('../assets/botlogo.png')} style={[mainStyles.logo, mainStyles.logoWithScanner]} />
          <Text style={mainStyles.loginText}>Scan to log in</Text>
          {!__DEV__ &&
            <BarCodeScanner
              onBarCodeRead={this._handleBarCodeRead}
              style={[StyleSheet.absoluteFill, mainStyles.scanner]}
            />
          }
        </View>
      );
    } else if (hasCameraPermission === false) {
      return (
        <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer]}>
          <Text style={mainStyles.loginText}>No access to camera</Text>
          <Button onPress={this._loadInitialState} title={'Request Access'} />
        </View>
      );
    } else {
      return null;
    }
  }
}

export default Login;
