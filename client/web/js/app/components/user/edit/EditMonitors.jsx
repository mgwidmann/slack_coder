import React, { Component } from 'react';
import PropTypes from 'prop-types';
import UserSearch from '../UserSearch';

class EditMonitors extends Component {
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

EditMonitors.propTypes = {
  monitors: UserSearch.propTypes.initial,
  search: PropTypes.func.isRequired,
}

export default EditMonitors;
