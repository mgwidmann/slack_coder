import React from 'react';
import synchronize from '../../../mobile/shared/graphql/mutations/synchronize';

const SynchronizePRLink = ({ owner, repository, number, synchronize }) => {
  const synchronizePR = () => {
    synchronize({
      variables: {
        owner: owner,
        repo: repository,
        number: number
      }
    });
  }

  return (
    <a href="javascript:void(0);"
      className="refresh-pr"
      title="Synchronize PR"
      data-toggle="tooltip"
      data-placement="top"
      onClick={synchronizePR}>
      <i className="glyphicon glyphicon-refresh"></i>
    </a>
  );
}

export default synchronize(SynchronizePRLink);
