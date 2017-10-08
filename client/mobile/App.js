import React, { Component } from 'react';
import { ApolloProvider } from 'react-apollo';
import Main from './app/containers/Main';
import store from './app/store';
import client from './app/client';

export default class App extends React.Component {
  render() {
    return (
      <ApolloProvider client={client} store={store}>
        <Main />
      </ApolloProvider>
    );
  }
}
