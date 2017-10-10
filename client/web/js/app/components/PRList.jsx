import React from 'react';
import PropTypes from 'prop-types';
import FlipMove from 'react-flip-move';
import PRRow from '../components/PRRow';

const PRList = ({ pullRequests, type, subscribe, children }) => {
  return (
    <div>
      <div className="table table-striped">
        <FlipMove appearAnimation='fade' enterAnimation="fade" leaveAnimation="fade">
          { pullRequests.map((pr) => { return <PRRow key={pr.id} pr={pr} type={type} subscribe={subscribe} /> }) }
        </FlipMove>
      </div>
      { pullRequests.length == 0 && children}
    </div>
  );
}

import prType from '../../../shared/props/pr';

PRList.propTypes = {
  pullRequests: PropTypes.arrayOf(prType),
  type: PropTypes.string.isRequired,
  subscribe: PropTypes.func.isRequired,
  children: PropTypes.element.isRequired
}

export default PRList;
