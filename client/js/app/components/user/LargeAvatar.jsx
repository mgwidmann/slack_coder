import React from 'react';

export default ({ avatarUrl, name, github }) => {
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
