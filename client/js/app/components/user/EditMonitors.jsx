import React from 'react';
import UserSearch from './UserSearch';

export default ({ monitors, search }) => {
  return (
    <div className="form-group">
      <label htmlFor="monitors" className="control-label">Team members you wish to monitor</label>
      <UserSearch multiple initial={monitors} search={search} />
    </div>
  )
};
