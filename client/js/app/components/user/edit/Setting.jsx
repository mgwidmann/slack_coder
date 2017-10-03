import React, { Component } from 'react';
import PropTypes from 'prop-types';

class Setting extends Component {
  getValue() {
    return this._setting.checked;
  }

  render() {
    let { setting, label, value } = this.props;
    return (
      <label htmlFor={setting}>
        <input ref={(i) => { this._setting = i; }} type="checkbox" id={setting} defaultChecked={value} />
        &nbsp;
        {label}
      </label>
    );
  }
}

Setting.propTypes = {
  setting: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  value: PropTypes.bool.isRequired
};

export default Setting;
