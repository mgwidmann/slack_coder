import React from 'react';
import PropTypes from 'prop-types';
import { Route, Switch } from 'react-router';
import Layout from './app/containers/Layout';
import PullRequests from './app/containers/PullRequests';
import MobileLogin from './app/containers/MobileLogin';
import Users from './app/containers/Users';
import User from './app/containers/User';
import NotFound from './app/components/NotFound';
import Login from './app/components/Login';
import FailedTests from './app/components/FailedTests';

const Routing = ({ store }) => {
  return (
    <Layout>
      <Switch>
        <Route exact path="/" render={() => {
          return <PullRequests currentUser={store.getState().currentUser} />;
        }} />
        <Route exact path="/mobile/login" render={() => {
          return <MobileLogin token={store.getState().token} />;
        }} />
        <Route exact path="/users" render={() => {
          return <Users admin={store.getState().currentUser.admin} />;
        }} />
        <Route exact path="/users/:id/edit" render={() => {
          return <User admin={store.getState().currentUser.admin} />;
        }} />
        <Route exact path="/failed_tests/:id" render={() => {
          return <FailedTests />;
        }} />
        <Route path="/login" component={Login} />
        <Route component={NotFound} />
      </Switch>
    </Layout>
  );
}

Routing.propTypes = {
  store: PropTypes.shape({
    getState: PropTypes.func.isRequired
  })
}

export default Routing;
