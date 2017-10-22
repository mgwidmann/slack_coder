import React from 'react';
import { connect } from 'react-redux';
import { AsyncStorage } from 'react-native';

import Menu from '../components/Menu';
import { setToken } from '../../shared/actions/token';

const mapStateToProps = (state, props) => {
  return {
    ...props
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    logout: () => {
      AsyncStorage.removeItem('@SlackCoder:token');
      dispatch(setToken(null));
    }
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(Menu);
