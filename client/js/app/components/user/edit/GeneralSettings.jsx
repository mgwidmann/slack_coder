import React from 'react';

export default ({ muted }) => {
  return (
    <div className="panel panel-default">
      <div className="panel-heading">General</div>
      <div className="panel-body">
        <label htmlFor="muted">
          <input type="checkbox" id="muted" defaultChecked={muted} />
          &nbsp;
          Mute all notifications
        </label>
      </div>
    </div>
  )
}
