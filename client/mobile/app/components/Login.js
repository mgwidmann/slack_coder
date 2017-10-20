import React, { Component } from 'react';
import { AsyncStorage, StyleSheet, View, Image, Text, TextInput, Button } from 'react-native';
import QRCodeScanner from 'react-native-qrcode-scanner';
import Permissions from 'react-native-permissions';

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
        Permissions.request('camera').then((status) => {
          this.setState({ hasCameraPermission: status === 'authorized' });
        });
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
          <QRCodeScanner
            onRead={this._handleBarCodeRead}
            showMarker={true}
            /* containerStyle={[StyleSheet.absoluteFill, mainStyles.scanner]} */
            topContent={(
              <Image source={require('../assets/botlogo.png')} style={[mainStyles.logo]} />
            )}
            bottomContent={(
              <View>
                <Text style={mainStyles.loginText}>Scan to log in</Text>  
                {__DEV__ &&
                  <TextInput
                    style={mainStyles.devTokenInput}
                    onChangeText={(token) => { this._handleBarCodeRead({ data: token }); }}
                  />
                }
              </View>
            )}
            notAuthorizedView={(
              <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer]}>
                <Text style={mainStyles.loginText}>No access to camera</Text>
                <Button onPress={this._loadInitialState} title={'Request Access'} />
              </View>
            )}
          />
        </View>
      );
    } else {
      return null;
    }
  }
}

export default Login;
