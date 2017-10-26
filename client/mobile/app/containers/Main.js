import React from 'react';
import { connect } from 'react-redux';

import MainView from '../components/MainView';
import { toggleExpandPR } from '../../shared/actions/pullRequest';
import { login } from '../../shared/actions/login';
import { OFFLINE, RECONNECTING } from '../../shared/actions/constants/login';

const mapStateToProps = (state, props) => {
  return {
    loggedIn: state.login.loggedIn,
    loading: state.graphql.loading || state.login.loading,
    offline: state.login.connection === OFFLINE,
    reconnecting: state.login.connection === RECONNECTING,
    error: state.graphql.error,
    expandedPr: state.expandedPr,
    ...props
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    togglePRRow: (pr) => {
      dispatch(toggleExpandPR(pr));
    },
    loginWithToken: (token) => {
      // Keep the token in the store for safe keeping
      dispatch(login(token));
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(MainView);
