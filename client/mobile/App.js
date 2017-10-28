import React, { Component } from 'react';
import { AsyncStorage } from 'react-native';
import { ApolloProvider } from 'react-apollo';

import Router from './app/router';
import store from './app/store';
import client from './app/client';
import { login } from './shared/actions/login';

// Show requests in chrome debugger tools
// GLOBAL.XMLHttpRequest = GLOBAL.originalXMLHttpRequest || GLOBAL.XMLHttpRequest;

class App extends Component {
  constructor(props) {
    super(props);
    this._loadToken = this._loadToken.bind(this);
    this._loadToken().done(); // Fire as soon as possible
  }

  async _loadToken() {
    const token = await AsyncStorage.getItem('@SlackCoder:token');
    if (token && token !== '') {
      store.dispatch(login(token));
    }
  }

  render() {
    return (
      <ApolloProvider client={client} store={store}>
        <Router />
      </ApolloProvider>
    );
  }
}

export default App;