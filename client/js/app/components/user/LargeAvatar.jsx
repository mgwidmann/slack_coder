import React from 'react';
import PropTypes from 'prop-types';

const LargeAvatar = ({ avatarUrl, name, github }) => {
  return (
    <h2 className="center">
      <img src={avatarUrl} className="img-md img-circle"/>
      <div className="name-header">
        {name}
        <br/>
        <small className="muted">{github}</small>
      </div>
    </h2>
  )
};

LargeAvatar.propTypes = {
  avatarUrl: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  github: PropTypes.string.isRequired
}

export default LargeAvatar;
