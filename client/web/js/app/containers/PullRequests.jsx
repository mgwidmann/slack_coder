import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { compose, withApollo } from 'react-apollo';
import { withRouter } from 'react-router';
import MinePRs from '../components/MinePRs';
import MonitorsPRs from '../components/MonitorsPRs';

class PullRequests extends Component {
  renderMyEmpty() {
    return (
      <div className="text-center">
        <h2>
          Looks like you have no pull requests!
          <br/>
          <small>You should start coding some Elixir! 💻</small>
        </h2>
      </div>
    );
  }

  renderMonitorEmpty() {
    return (
      <div className="text-center">
        <h2>
          None of your friends have pull requests...
          <br/>
          <small>or do you not have any friends? 🤓</small>
        </h2>
      </div>
    );
  }

  render() {
    const { currentUser } = this.props;
    return (
      <div>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">
              My pull requests
            </span>
          </div>
          <div className="panel-body pull-request-pannel">
            <MinePRs type={'mine'} empty={() => { return this.renderMyEmpty() } } />
          </div>
        </section>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">Team members I monitor</span>
          </div>
          <div className="panel-body pull-request-pannel">
            <MonitorsPRs type={'monitors'} empty={() => { return this.renderMonitorEmpty() } } />
          </div>
        </section>
      </div>
    );
  }
}

import currentUserType from '../../../shared/props/currentUser';

PullRequests.propTypes = {
  currentUser: currentUserType
}

export default compose(
  withRouter
)(PullRequests);
