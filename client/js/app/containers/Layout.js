import React, { Component } from 'react';
import { connect } from 'react-redux'

class Main extends Component {
  render () {
    let { children, ...remainingProps } = this.props
    const childrenWithProps = React.Children.map(this.props.children, (child) => React.cloneElement(child, remainingProps));
    const { currentUser } = this.props;
    return (
      <div>
        <div className="header">
          <div className="container">
            <div className="col-md-3 hidden-xs hidden-sm">
              <a className="logo" href="/"></a>
            </div>
            <div className="col-md-6 col-sm-8 hidden-xs text-center">
              <h1>
                Slack Coder
              </h1>
              <p className="lead">Monitoring your <strong>dead</strong> pull requests</p>
            </div>
            {currentUser && (
              <div>
                <div className="col-md-3 col-sm-4 col-xs-12 text-right">
                  <span>
                    <img src={currentUser.avatar_url} className="img-xs img-circle"/>
                    {currentUser.id ? (
                      <a href={`/users/${currentUser.id}/edit`}>{currentUser.github}</a>
                    ) : (
                      <a href={`/update/this/to/new`}>{currentUser.github}</a>
                    )}
                  </span>
                  &nbsp;|&nbsp;
                  <a href='/mobile/login'>Mobile</a>
                  &nbsp;|&nbsp;
                  <a href={`/update/this/to/logout`}>Logout</a>
                </div>
                <div className="col-md-3 col-sm-4 col-xs-12 text-right">
                  <a href={`/update/this/to/users`}>
                    <i className="glyphicon glyphicon-user"></i> Users
                  </a>
                </div>
              </div>
            )}
            <div className="col-md-3 col-sm-4 col-xs-12 text-right">
              <a href="/wobserver">
                <i className="glyphicon glyphicon-time"></i> Application Metrics
              </a>
              &nbsp;|&nbsp;
              <a href="/errors">
                <i className="glyphicon glyphicon-remove"></i> Errors
              </a>
            </div>
            <div className="col-md-3 col-sm-4 col-xs-12 text-right">
              {currentUser && (
                <span>
                  <a href="/graphiql">
                    <i className="glyphicon glyphicon-console"></i> GraphiQL
                  </a>
                  &nbsp;|&nbsp;
                  <a href={`https://github.com/mgwidmann/slack_coder/commit/${window.commitSha}`}>
                    <i className="glyphicon glyphicon-tag"></i> Version
                  </a>
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="container" role="main">
          {/* <p className="alert alert-info" role="alert"><%= get_flash(@conn, :info) %></p> */}
          {/* <p className="alert alert-danger" role="alert"><%= get_flash(@conn, :error) %></p> */}

          {currentUser ? (
            childrenWithProps
          ) : (
            <div className="center sign-in">
              <a className="btn btn-default btn-xxl" href="/auth/github">
                <i className="fa fa-github"></i>
                Sign in with GitHub
                <i className="fa fa-angle-right"></i>
              </a>
            </div>
          )}
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => { return state; }

export default connect(mapStateToProps)(Main);
