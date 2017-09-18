import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { ConnectedRouter } from 'react-router-redux';
import { Route } from 'react-router'
import Layout from './app/containers/Layout';
import PullRequests from './app/containers/PullRequests';
import MobileLogin from './app/containers/MobileLogin';
import { store, history } from './app/store';
import '../css/app.scss';
import 'bootstrap';
import socket from "./socket";

$( document ).ajaxSend((event, xhr, settings) => {
  xhr.setRequestHeader('Authorization', `Bearer ${window.token}`);
});

class App extends React.Component {
  render() {
    const state = store.getState();
    return (
      <Provider store={store}>
        <ConnectedRouter history={history}>
          <Layout>
            <Route exact path="/" render={(props) => <PullRequests pullRequests={state.pullRequests} />} />
            <Route exact path="/mobile/login" render={(props) => <MobileLogin {...props} token={state.token}/>} />
          </Layout>
        </ConnectedRouter>
      </Provider>
    );
  }
}

ReactDOM.render(
  <App/>,
  document.getElementById('app')
);
