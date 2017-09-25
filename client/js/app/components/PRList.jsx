import React, { Component } from 'react';
import PRRow from '../components/PRRow';

export default class PRList extends Component {
  render() {
    const { pullRequests } = this.props;
    return (
      <div className="panel-body">
        <table className="table table-striped">
          <tbody id="pull-requests">
            { pullRequests.map((pr) => { return <PRRow pr={pr} /> }) }
          </tbody>
        </table>
        { pullRequests.length == 0 && this.props.children}
      </div>
    );
  }
}
