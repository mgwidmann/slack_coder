import React, { Component } from 'react';
import { ApolloProvider } from 'react-apollo';
import { AsyncStorage } from 'react-native';
import Main from './app/containers/Main';
import store from './app/store';
import client from './app/client';
import { setToken } from './shared/actions/token';

// Show requests in chrome debugger tools
// GLOBAL.XMLHttpRequest = GLOBAL.originalXMLHttpRequest || GLOBAL.XMLHttpRequest;

// Setup client interface
const logout = () => {
  AsyncStorage.removeItem('@SlackCoder:token')
  store.dispatch(setToken(null));
}
// Set the token on the options so when the socket is created it has access
client.networkInterface.use([{
  applyMiddleware({ request, options }, next) {
    options.token = store.getState().token;
    options.logout = logout;
    next()
  }
}]);

export default class App extends React.Component {
  render() {
    return (
      <ApolloProvider client={client} store={store}>
        <Main />
      </ApolloProvider>
    );
  }
}
