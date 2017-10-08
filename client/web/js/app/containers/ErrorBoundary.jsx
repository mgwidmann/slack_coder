import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  componentDidCatch(error, info) {
    // Display fallback UI
    this.setState({ hasError: true });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div>
          <div className="header">
            <div className="container">
              <div className="col-lg-3 hidden-md hidden-xs hidden-sm">
                <Link to="/" className="logo" />
              </div>
              <div className="col-lg-6 col-md-7 col-sm-7 hidden-xs text-center">
                <h1>
                  Slack Coder
                </h1>
                <p className="lead">Monitoring your <strong>dead</strong> pull requests</p>
              </div>
              <div className="col-lg-3 col-md-5 col-sm-5 col-xs-12 text-right">
                <span>
                  <a href={`https://github.com/mgwidmann/slack_coder/commit/${window.commitSha}`}>
                    <i className="glyphicon glyphicon-tag"></i> Version
                  </a>
                </span>
              </div>
            </div>
          </div>
          <div className="container" role="main">
            <div class="center center-vertical">
              <h1 className="text-center extra-large">
                500
                <div class="small text-muted">You killed the zombie!</div>
              </h1>
              <img src="/images/zombie-kill.gif" />
            </div>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

export default ErrorBoundary;
