import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router';
import { Route } from 'react-router';
import { Link } from 'react-router-dom';
import Authenticated from '../components/Authenticated';

class Layout extends Component {
  render () {
    let { children, ...remainingProps } = this.props
    const childrenWithProps = React.Children.map(this.props.children, (child) => React.cloneElement(child, remainingProps));
    const { currentUser } = this.props;
    return (
      <Route {...this.props}>
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
              <Authenticated currentUser={currentUser} header={true}>
                <div>
                  <div className="col-lg-3 col-md-5 col-sm-5 col-xs-12 text-right">
                    <span>
                      <img src={currentUser.avatar_url} className="img-xs img-circle"/>
                      &nbsp;
                      <Link to={`/users/${currentUser.id}/edit`}>{currentUser.name}</Link>
                    </span>
                    &nbsp;|&nbsp;
                    <Link to='/mobile/login'>Mobile</Link>
                    &nbsp;|&nbsp;
                    <a href={`/auth/logout`}>Logout</a> {/* Not <Link/> on purpose, needs to hit server */}
                  </div>
                  <div className="col-lg-3 col-md-5 col-sm-5 col-xs-12 text-right">
                    <Link to={`/users`}>
                      <i className="glyphicon glyphicon-user"></i> Users
                    </Link>
                  </div>
                </div>
              </Authenticated>
              <div className="col-lg-3 col-md-5 col-sm-5 col-xs-12 text-right">
                <Authenticated currentUser={currentUser} header={true}>
                  <span>
                    {/* Not <Link/> on purpose, needs to hit server */}
                    <a href="/tools/wobserver">
                      <i className="glyphicon glyphicon-time"></i> Application Metrics
                    </a>
                    &nbsp;|&nbsp;
                    {/* Not <Link/> on purpose, needs to hit server */}
                    <a href="/tools/errors">
                      <i className="glyphicon glyphicon-remove"></i> Errors
                    </a>
                  </span>
                </Authenticated>
              </div>
              <div className="col-lg-3 col-md-5 col-sm-5 col-xs-12 text-right">
                <Authenticated currentUser={currentUser} header={true}>
                  <span>
                    {/* Not <Link/> on purpose, needs to hit server */}
                    <a href="/tools/graphiql">
                      <i className="glyphicon glyphicon-console"></i> GraphiQL
                    </a>
                    &nbsp;|&nbsp;
                  </span>
                </Authenticated>
                <span>
                  <a href={`https://github.com/mgwidmann/slack_coder/commit/${window.commitSha}`}>
                    <i className="glyphicon glyphicon-tag"></i> Version
                  </a>
                </span>
              </div>
            </div>
          </div>

          <div className="container" role="main">
            <Authenticated currentUser={currentUser} redirect={true}>
              <div>
                {childrenWithProps}
              </div>
            </Authenticated>
          </div>
        </div>
      </Route>
    );
  }
}

const mapStateToProps = (state) => { return state; }

export default connect(mapStateToProps)(Layout);
