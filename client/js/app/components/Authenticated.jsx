import React, { Component } from 'react';
import { Redirect, withRouter } from 'react-router';

class Authenticated extends React.Component {
  render() {
    let { currentUser, location, redirect, header } = this.props;
    if (Object.keys(currentUser).length > 0 || location.pathname == '/login' && !header) {
      return this.props.children;
    } else if (redirect === true) {
      return <Redirect to="/login" />;
    } else {
      return null;
    }
  }
}

export default withRouter(Authenticated);
