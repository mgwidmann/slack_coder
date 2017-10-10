import React from 'react';
import { connect } from 'react-redux';

import MainView from '../components/MainView';
import { setImmutable } from '../../shared/actions/immutable';
import client from '../client';
import networkInterface from '../../shared/graphql/apiNetworkInterface';
import { toggleExpandPR } from '../../shared/actions/pullRequest';

const Main = (props) => {
  return (
    <MainView {...props} />
  );
}

const mapStateToProps = (state) => {
  return {
    loggedIn: state.token && state.token != '',
    loading: state.graphql.loading,
    error: state.graphql.error,
    expandedPr: state.expandedPr
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    togglePRRow: (pr) => {
      dispatch(toggleExpandPR(pr));
    },
    setToken: (token) => {
      // Set the token on the options so when the socket is created it has access
      client.networkInterface.use([{
        applyMiddleware({request, options}, next) {
          options.token = token;
          next()
        }
      }]);
      // Keep the token in the store for safe keeping
      dispatch(setImmutable('token', token));
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Main);
