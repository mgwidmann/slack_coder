import React from 'react';
import PropTypes from 'prop-types';
import FlipMove from 'react-flip-move';
import PRRow from '../components/PRRow';
import Loading from '../components/Loading';

const PRList = ({ pullRequests, loading, type, subscribe, children }) => {
  if (loading) {
    return <Loading/>;
  } else if (pullRequests && pullRequests.length > 0) {
    return (
      <div>
        <div className="table table-striped">
          <FlipMove appearAnimation='fade' enterAnimation="fade" leaveAnimation="fade">
            { pullRequests.map((pr) => { return <PRRow key={pr.id} pr={pr} type={type} subscribe={subscribe} /> }) }
          </FlipMove>
        </div>
      </div>
    );
  } else {
    return children;
  }
}

import prType from '../../../shared/props/pr';

PRList.propTypes = {
  pullRequests: PropTypes.arrayOf(prType),
  type: PropTypes.string.isRequired,
  subscribe: PropTypes.func.isRequired,
  children: PropTypes.element.isRequired
}

export default PRList;
