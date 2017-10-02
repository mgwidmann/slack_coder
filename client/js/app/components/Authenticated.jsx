import React, { Component } from 'react';

export default class Authenticated extends React.Component {
  render() {
    let { currentUser } = this.props;
    if (currentUser) {
      return this.props.children;
    } else {
      return (
        <div className="center sign-in">
          <a className="btn btn-default btn-xxl" href="/auth/github">
            <i className="fa fa-github"></i>
            Sign in with GitHub
            <i className="fa fa-angle-right"></i>
          </a>
        </div>
      );
    }
  }
}
