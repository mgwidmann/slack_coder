import React from 'react';
import PropTypes from 'prop-types';
import synchronize from '../../../shared/graphql/mutations/synchronize';

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

SynchronizePRLink.propTypes = {
  owner: PropTypes.string.isRequired,
  repository: PropTypes.string.isRequired,
  number: PropTypes.number.isRequired,
  synchronize: PropTypes.func.isRequired
}

export default synchronize(SynchronizePRLink);
