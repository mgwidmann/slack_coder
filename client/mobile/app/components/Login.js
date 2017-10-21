import React, { Component } from 'react';
import { AsyncStorage, StyleSheet, View, Image, Text, TextInput, Button } from 'react-native';
import QRCodeScanner from 'react-native-qrcode-scanner';
import Permissions from 'react-native-permissions';

import mainStyles from '../styles/main';

class Login extends Component {
  constructor(props) {
    super(props);
    this._loadInitialState = this._loadInitialState.bind(this);
    this._handleBarCodeRead = this._handleBarCodeRead.bind(this);
  }

  componentDidMount() {
    this._loadInitialState().done();
  }

  async _loadInitialState() {
    const value = await AsyncStorage.getItem('@SlackCoder:token');
    this.props.setToken(value);
  }

  _handleBarCodeRead({ data }) {
    AsyncStorage.setItem('@SlackCoder:token', data);
    this.props.setToken(data);
  }

  render() {
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
              <Text style={mainStyles.loginSubText}>Please allow access in settings and try again.</Text>
              <Button onPress={this._loadInitialState} title={'Retry'} />
            </View>
          )}
        />
      </View>
    );
  }
}

export default Login;
