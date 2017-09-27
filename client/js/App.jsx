import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { ConnectedRouter } from 'react-router-redux';
import { Route } from 'react-router'
import { ApolloProvider } from 'react-apollo';
import Layout from './app/containers/Layout';
import PullRequests from './app/containers/PullRequests';
import MobileLogin from './app/containers/MobileLogin';
import Users from './app/containers/Users';
import { store, history } from './app/store';
import client from './app/client';
import '../css/app.scss';
import 'bootstrap';

class App extends React.Component {
  render() {
    return (
      <ApolloProvider client={client} store={store}>
        <ConnectedRouter dispatch={store.dispatch} history={history}>
          <Layout>
            <Route exact path="/" component={PullRequests} />
            <Route exact path="/mobile/login" render={() => {
              return <MobileLogin token={store.getState().token} />
            }} />
            <Route exact path="/users" render={() => {
              return <Users admin={store.getState().currentUser.admin} />
            }} />
          </Layout>
        </ConnectedRouter>
      </ApolloProvider>
    );
  }
}

ReactDOM.render(
  <App/>,
  document.getElementById('app')
);
