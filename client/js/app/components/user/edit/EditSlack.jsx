import React from 'react';

export default ({ github, slack }) => {
  return (
    <div>
      <h4>Slack Info</h4>
      <label htmlFor="slack" className="control-label">Slack</label>
      <input id="slack" className="form-control" placeholder={github} defaultValue={slack} />
      <p className="help-block">Enter your name on slack without the @</p>
    </div>
  )
};
