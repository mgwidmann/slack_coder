import React, { Component } from 'react';
import UserSearch from '../UserSearch';

export default class EditMonitors extends Component {
  getUsers() {
    return this._monitors.getUsers();
  }

  render() {
    let { monitors, search } = this.props;
    return (
      <div className="form-group">
        <label htmlFor="monitors" className="control-label">Team members you wish to monitor</label>
        <UserSearch ref={(i) => { this._monitors = i; }} multiple initial={monitors} search={search} />
      </div>
    );
  }
}
