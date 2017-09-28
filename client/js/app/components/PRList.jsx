import React, { Component } from 'react';
import FlipMove from 'react-flip-move';
import PRRow from '../components/PRRow';

export default class PRList extends Component {
  render() {
    const { pullRequests, type, subscribe } = this.props;
    return (
      <div>
        <div className="table table-striped">
          <FlipMove appearAnimation='fade' enterAnimation="fade" leaveAnimation="fade">
            { pullRequests.map((pr) => { return <PRRow key={pr.id} pr={pr} type={type} subscribe={subscribe} /> }) }
          </FlipMove>
        </div>
        { pullRequests.length == 0 && this.props.children}
      </div>
    );
  }
}
