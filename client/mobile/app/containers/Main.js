import React, { Component } from 'react';
import { AsyncStorage, View, Text, Image, StyleSheet, Button, Animated, Easing } from 'react-native';
import { connect } from 'react-redux'
import { BarCodeScanner, Permissions } from 'expo';
import ScrollableTabView from 'react-native-scrollable-tab-view';
import mainStyles from '../styles/main';
import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from '../styles/constants';
import PRView from '../components/PRView';
import Loading from '../components/Loading';
import { setImmutable } from '../../shared/actions/immutable';
import client from '../../shared/graphql/client';

class Main extends Component {
  state = {
    hasCameraPermission: null,
  }

  componentDidMount() {
    this._loadInitialState().done();
  }

  spin () {
    this.spinValue.setValue(0)
    Animated.timing(
      this.spinValue,
      {
        toValue: 1,
        duration: 4000,
        easing: Easing.linear
      }
    ).start(() => this.spin())
  }

  _loadInitialState = async () => {
    try {
      const value = await AsyncStorage.getItem('@SlackCoder:token');
      this.props.dispatch(setImmutable('token', value || ''));
      if (value == null) {
        const { status } = await Permissions.askAsync(Permissions.CAMERA);
        this.setState({hasCameraPermission: status === 'granted'});
      }
    } catch (error) {
      // Error retrieving data, don't worry about it
    }
  }

  _handleBarCodeRead = ({ data }) => {
    this.props.dispatch(setImmutable('token', data));
    AsyncStorage.setItem('@SlackCoder:token', data);
  }

  render () {
    const { hasCameraPermission } = this.state;
    const { dispatch, pullRequests, token, graphql } = this.props;
     // Cannot use null/undefined to determine difference between unknown and no value
    if (token && token != '' && Object.keys(graphql.data).length !== 0 && !graphql.data.error) {
      return (
        <ScrollableTabView
          tabBarPosition="bottom"
          style={mainStyles.tabBarContainer}
          tabBarBackgroundColor={PRIMARY_COLOR}
          tabBarActiveTextColor={FOREGROUND_COLOR}
          tabBarUnderlineStyle={mainStyles.tabBarUnderline}
          >
          <PRView tabLabel='Main' dispatch={dispatch} tab={'main'} prs={pullRequests.main || []} />
          <PRView tabLabel='Monitors' dispatch={dispatch} tab={'monitors'} prs={pullRequests.monitors || []} />
          <PRView tabLabel='Hidden' dispatch={dispatch} tab={'hidden'} prs={pullRequests.hidden || []} />
        </ScrollableTabView>
      );
    } else if (token === '') {
      return (
        <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer]}>
          <Image source={require('../assets/botlogo.png')} style={[mainStyles.logo, mainStyles.logoWithScanner]} />
          <Text style={mainStyles.loginText}>Scan to log in</Text>
          <BarCodeScanner
            onBarCodeRead={this._handleBarCodeRead}
            style={[StyleSheet.absoluteFill, mainStyles.scanner]}
          />
        </View>
      );
    } else if (hasCameraPermission === false) {
      return (
        <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer]}>
          <Text style={mainStyles.loginText}>No access to camera</Text>
          <Button onPress={this._loadInitialState} title={'Request Access'} />
        </View>
      );
    } else if (graphql.data.error !== undefined) {
      return <Loading animate={false} />;
    } else {
      return <Loading />;
    }
  }
}

const mapStateToProps = (state) => { return state; }

export default connect(mapStateToProps)(Main);
