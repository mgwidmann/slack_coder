import React from 'react';
import { connect } from 'react-redux';

import MainView from '../components/MainView';
import client from '../client';
import { toggleExpandPR } from '../../shared/actions/pullRequest';
import { setToken } from '../../shared/actions/token';

const mapStateToProps = (state, props) => {
  return {
    loggedIn: state.token && state.token != '',
    loading: state.graphql.loading,
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
    setToken: (token) => {
      // Keep the token in the store for safe keeping
      dispatch(setToken(token));
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(MainView);
