import React, { Component } from 'react';

export default class Setting extends Component {
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
