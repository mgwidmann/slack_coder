import React, { Component } from 'react';
import { Provider } from 'react-redux';
import Main from './app/containers/Main';
import store from './app/store';

export default class App extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <Main />
      </Provider>
    );
  }
}
