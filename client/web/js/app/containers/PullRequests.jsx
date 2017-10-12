import React, { Component } from 'react';
import PropTypes from 'prop-types';
import PRList from '../components/PRList';
import { compose } from 'react-apollo';
import { withRouter } from 'react-router';
import subscribeMinePullRequests from '../../../shared/graphql/subscriptions/minePullRequest';
import subscribeMonitorsPullRequests from '../../../shared/graphql/subscriptions/monitorsPullRequest';
import Loading from '../components/Loading';

class PullRequests extends Component {
  componentDidMount() {
    this.props.subscribeNew(this.props.currentUser);
  }

  renderMyEmpty() {
    if(this.props.mineLoading) {
      return <Loading/>;
    } else {
      return (
        <div className="text-center">
          <h2>
            Looks like you have no Pull Requests!
            <br/>
            <small>You should start coding some Elixir!</small>
          </h2>
        </div>
      );
    }
  }

  renderMonitorEmpty() {
    if(this.props.monitorsLoading) {
      return <Loading/>;
    } else {
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
  }

  render() {
    const { currentUser, mine, monitors, subscribeMine, subscribeMonitors } = this.props;
    return (
      <div>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">
              My pull requests
            </span>
          </div>
          <div className="panel-body pull-request-pannel">
            <PRList pullRequests={mine || []} type={'mine'} subscribe={subscribeMine} >
              {this.renderMyEmpty()}
            </PRList>
          </div>
        </section>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">Team members I monitor</span>
          </div>
          <div className="panel-body pull-request-pannel">
            <PRList pullRequests={monitors || []} type={'monitors'} subscribe={subscribeMonitors} >
              {this.renderMonitorEmpty()}
            </PRList>
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
  withRouter,
  subscribeMinePullRequests,
  subscribeMonitorsPullRequests
)(PullRequests);
