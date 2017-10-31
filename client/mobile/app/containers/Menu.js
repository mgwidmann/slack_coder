import React from 'react';
import { connect } from 'react-redux';
import { AsyncStorage } from 'react-native';

import MenuView from '../components/MenuView';
import { logout } from '../../shared/actions/login';
import { setImmutable } from '../../shared/actions/immutable';

const mapStateToProps = (state, props) => {
  return {
    ...props,
    navigateSettings: () => {
      props.navigation.navigate('Settings', { currentUser: state.currentUser });
    }
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    logout: () => {
      AsyncStorage.removeItem('@SlackCoder:token');
      dispatch(logout());
    },
    setCurrentUser: (currentUser) => {
      dispatch(setImmutable('currentUser', currentUser));
    }
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(MenuView);
