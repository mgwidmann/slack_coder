import React from 'react';
import { connect } from 'react-redux';
import { AsyncStorage } from 'react-native';

import Menu from '../components/Menu';
import { logout } from '../../shared/actions/login';

const mapStateToProps = (state, props) => {
  return {
    ...props
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    logout: () => {
      AsyncStorage.removeItem('@SlackCoder:token');
      dispatch(logout());
    }
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(Menu);
