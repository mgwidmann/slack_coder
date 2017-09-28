import React, { Component } from 'react';
import PRList from '../components/PRList';
import { graphql } from 'react-apollo';
import subscribePullRequests from '../../../mobile/shared/graphql/subscriptions/pullRequest';

class PullRequests extends Component {
  renderLoading() {
    return <img src="/images/spinner.gif" className="img-responsive loading-spinner" />;
  }

  renderMyEmpty() {
    if(this.props.loading) {
      return this.renderLoading();
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
    if(this.props.loading) {
      return this.renderLoading();
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
    const { currentUser, mine, monitors, subscribe } = this.props;
    return (
      <div>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">
              My pull requests
            </span>
          </div>
          <div className="panel-body pull-request-pannel">
            <PRList pullRequests={mine || []} type={'mine'} subscribe={subscribe} >
              {this.renderMyEmpty()}
            </PRList>
          </div>
        </section>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">Team members I monitor</span>
          </div>
          <div className="panel-body pull-request-pannel">
            <PRList pullRequests={monitors || []} type={'monitors'} subscribe={subscribe} >
              {this.renderMonitorEmpty()}
            </PRList>
          </div>
        </section>
      </div>
    );
  }
}

export default subscribePullRequests(PullRequests);
