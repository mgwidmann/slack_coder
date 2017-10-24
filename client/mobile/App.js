import React, { Component } from 'react';
import { AsyncStorage } from 'react-native';
import { ApolloProvider } from 'react-apollo';

import Main from './app/containers/Main';
import store from './app/store';
import client from './app/client';
import configureNetwork from './app/configureNetwork';
import { setToken, setLoggedIn } from './shared/actions/login';

configureNetwork(client, store);

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
    store.dispatch(setToken(token));
    if (token) {
      store.dispatch(setLoggedIn());
    }
  }

  render() {
    return (
      <ApolloProvider client={client} store={store}>
        <Main />
      </ApolloProvider>
    );
  }
}

export default App;