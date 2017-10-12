import React from 'react';
import PropTypes from 'prop-types';
import toggleHidePullRequestMutation from '../../../shared/graphql/mutations/toggleHidePullRequest';

const ToggleHidePRLink = ({ id, hidden, toggleHidePullRequest }) => {
  const toggleHidePR = () => {
    toggleHidePullRequest({
      variables: {
        id: id
      }
    });
  }

  return (
    <a href="javascript:void(0);"
      className="hide-pr"
      title="Hide Pull Request"
      data-toggle="tooltip"
      data-placement="top"
      onClick={toggleHidePR}>
      <i className={`glyphicon ${hidden ? 'glyphicon-eye-open' : 'glyphicon glyphicon-eye-close'}`}></i>
    </a>
  );
}

ToggleHidePRLink.propTypes = {
  id: PropTypes.string.isRequired,
  hidden: PropTypes.bool.isRequired,
  toggleHidePullRequest: PropTypes.func.isRequired
}

export default toggleHidePullRequestMutation(ToggleHidePRLink);
