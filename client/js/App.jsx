import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { ConnectedRouter } from 'react-router-redux';
import { Route, Switch } from 'react-router';
import { ApolloProvider } from 'react-apollo';
import Layout from './app/containers/Layout';
import PullRequests from './app/containers/PullRequests';
import MobileLogin from './app/containers/MobileLogin';
import Users from './app/containers/Users';
import User from './app/containers/User';
import NotFound from './app/components/NotFound';
import Login from './app/components/Login';
import { store, history } from './app/store';
import client from './app/client';
import '../css/app.scss';
import 'bootstrap';
import 'react-select/dist/react-select.css';

class App extends React.Component {
  render() {
    return (
      <ApolloProvider client={client} store={store}>
        <ConnectedRouter dispatch={store.dispatch} history={history}>
          <Layout>
            <Switch>
              <Route exact path="/" component={PullRequests} />
              <Route exact path="/mobile/login" render={() => {
                return <MobileLogin token={store.getState().token} />;
              }} />
              <Route exact path="/users" render={() => {
                return <Users admin={store.getState().currentUser.admin} />;
              }} />
              <Route exact path="/users/:id/edit" render={() => {
                return <User admin={store.getState().currentUser.admin} />;
              }} />
              <Route path="/login" component={Login} />
              <Route component={NotFound} />
            </Switch>
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
