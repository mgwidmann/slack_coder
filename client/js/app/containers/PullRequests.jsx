import React, { Component } from 'react';
import PRList from '../components/PRList';
import { graphql } from 'react-apollo';
import PULL_REQUESTS_QUERY from '../../../mobile/shared/graphql/queries/pullRequests.graphql';

class PullRequests extends Component {
  renderLoading() {
    return <img src="/images/spinner.gif" className="img-responsive loading-spinner" />;
  }

  renderMyEmpty() {
    if(this.props.data.loading) {
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
    if(this.props.data.loading) {
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
    const { currentUser, mine, monitors } = this.props.data;
    return (
      <div>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">
              My pull requests
            </span>
          </div>
          <PRList pullRequests={mine || []}>
            {this.renderMyEmpty()}
          </PRList>
        </section>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">Team members I monitor</span>
          </div>
          <div className="panel-body">
            <table className="table table-striped">
              <tbody id="team-pull-requests">
                <PRList pullRequests={monitors || []}>
                  {this.renderMonitorEmpty()}
                </PRList>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    );
  }
}

export default graphql(PULL_REQUESTS_QUERY)(PullRequests);
