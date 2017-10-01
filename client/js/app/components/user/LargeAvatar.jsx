import React from 'react';

export default ({ avatarUrl, github }) => {
  return (
    <h2 className="center">
      <img src={avatarUrl} className="img-md img-circle"/>
      {github}
    </h2>
  )
};
