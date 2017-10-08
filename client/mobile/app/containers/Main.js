import React from 'react';
import { connect } from 'react-redux';

import MainView from '../components/MainView';
import { setImmutable } from '../../shared/actions/immutable';
import createSocket from '../socket';
import client from '../client';
import createWebsocketNetworkInterface from '../../shared/graphql/websocketNetworkInterface';

const Main = (props) => {
  return (
    <MainView {...props} />
  );
}

const mapStateToProps = (state) => {
  return {
    loggedIn: state.token && state.token != '',
    loading: state.graphql.loading,
    error: state.graphql.error
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    setToken: (token) => {
      let socket = createSocket(token);
      // client.networkInterface = createWebsocketNetworkInterface(socket);
      // console.log("The fresh new client!", client);
      dispatch(setImmutable('token', token));
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Main);
