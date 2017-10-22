import React from 'react';
import { ApolloProvider } from 'react-apollo';

import Main from './app/containers/Main';
import store from './app/store';
import client from './app/client';
import configureNetwork from './app/configureNetwork';

configureNetwork(client, store);

// Show requests in chrome debugger tools
// GLOBAL.XMLHttpRequest = GLOBAL.originalXMLHttpRequest || GLOBAL.XMLHttpRequest;

const App = () => {
  return (
    <ApolloProvider client={client} store={store}>
      <Main />
    </ApolloProvider>
  );
};

export default App;