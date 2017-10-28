import React, { Component } from 'react';
import { AsyncStorage, StyleSheet, View, Image, Text, TextInput, Button } from 'react-native';
import QRCodeScanner from 'react-native-qrcode-scanner';
import Permissions from 'react-native-permissions';

import mainStyles from '../../styles/main';

class Login extends Component {
  constructor(props) {
    super(props);
    this._handleBarCodeRead = this._handleBarCodeRead.bind(this);
  }

  _handleBarCodeRead({ data }) {
    AsyncStorage.setItem('@SlackCoder:token', data);
    this.props.loginWithToken(data);
  }

  render() {
    if (this.props.offline) {
      return (
        <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer, mainStyles.main]}>
          <Image source={require('../../assets/botlogo.png')} style={[mainStyles.logo]} />
          <Text style={mainStyles.loginText}>Looks like you're offline.</Text>
          <Text>Please reconnect and try again.</Text>
        </View>
      );
    }
    return (
      <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer, mainStyles.main]}>
        <QRCodeScanner
          onRead={this._handleBarCodeRead}
          showMarker={true}
          fadeIn={false}
          topContent={(
            <Image source={require('../../assets/botlogo.png')} style={[mainStyles.logo]} />
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
            <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer, mainStyles.main]}>
              <Text style={mainStyles.loginText}>No access to camera</Text>
              <Text style={mainStyles.loginSubText}>Please allow access in settings and try again.</Text>
            </View>
          )}
        />
      </View>
    );
  }
}

export default Login;
