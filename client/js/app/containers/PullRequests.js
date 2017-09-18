import React, { Component } from 'react';
import PRRow from '../components/PRRow';

export default class PullRequests extends Component {
  render() {
    const { currentUser, pullRequests } = this.props;
    // const { main, monitors } = pullRequests;
    return (
      <div>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">
              My pull requests
            </span>
          </div>
          <div className="panel-body">
            <table className="table table-striped">
              <tbody id="pull-requests">
                { (pullRequests && pullRequests.main || []).map((pr) => { return <PRRow pr={pr} /> }) }
              </tbody>
            </table>
            { (pullRequests && pullRequests.main || []).length == 0 && (
              <div className="text-center">
                <h2>
                  Looks like you have no Pull Requests!
                  <br/>
                  <small>You should start coding some Elixir!</small>
                </h2>
              </div>
            )}
          </div>
        </section>
        <section className="panel panel-default">
          <div className="panel-heading">
            <span className="h3">Team members I monitor</span>
          </div>
          <div className="panel-body">
            <table className="table table-striped">
              <tbody id="team-pull-requests">
                { (pullRequests && pullRequests.monitors || []).map((pr) => { return <PRRow pr={pr} /> }) }
              </tbody>
            </table>
          </div>
        </section>
      </div>
    );
  }
}
