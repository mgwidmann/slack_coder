import React, { Component } from 'react';
import synchronize from '../../../mobile/shared/graphql/mutations/synchronize';

class SynchronizePRLink extends Component {
  constructor(props) {
    super(props);
    this.synchronizePR = this.synchronizePR.bind(this);
  }

  synchronizePR() {
    const { owner, repository, number } = this.props;
    this.props.synchronize({
      variables: {
        owner: owner,
        repo: repository,
        number: number
      }
    })
  }

  render() {
    return <a
      href="javascript:void(0);"
      className="refresh-pr"
      title="Synchronize PR"
      data-toggle="tooltip"
      data-placement="top"
      onClick={this.synchronizePR}>
      <i className="glyphicon glyphicon-refresh"></i>
    </a>
  }
}

export default synchronize(SynchronizePRLink);
