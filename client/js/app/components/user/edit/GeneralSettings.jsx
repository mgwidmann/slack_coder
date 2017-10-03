import React, { Component } from 'react';
import PropTypes from 'prop-types';

class GeneralSettings extends Component {
  getSettings() {
    return {
      muted: this._muted.checked
    };
  }

  render() {
    let { muted } = this.props;
    return (
      <div className="panel panel-default">
        <div className="panel-heading">General</div>
        <div className="panel-body">
          <label htmlFor="muted">
            <input ref={(i) => { this._muted = i; }} type="checkbox" id="muted" defaultChecked={muted} />
            &nbsp;
            Mute all notifications
          </label>
        </div>
      </div>
    );
  }
}

GeneralSettings.propTypes = {
  muted: PropTypes.bool.isRequired
}

export default GeneralSettings;
