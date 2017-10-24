import React from 'react';
import { connect } from 'react-redux';

import MainView from '../components/MainView';
import { toggleExpandPR } from '../../shared/actions/pullRequest';
import { login } from '../../shared/actions/login';

const mapStateToProps = (state, props) => {
  return {
    loggedIn: state.login.loggedIn,
    loading: state.graphql.loading || state.login.loading,
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
