import React, { Component } from 'react';
import Setting from './Setting';

export default class NotificationSettings extends Component {
  getSettings() {
    let { type } = this.props;
    let returnValue = {};
    returnValue[`open${type}`] = this._open.getValue();
    returnValue[`close${type}`] = this._close.getValue();
    returnValue[`fail${type}`] = this._fail.getValue();
    returnValue[`pass${type}`] = this._pass.getValue();
    // returnValue[`stale${type}`] = this._stale.getValue();
    // returnValue[`unstale${type}`] = this._unstale.getValue();
    returnValue[`merge${type}`] = this._merge.getValue();
    returnValue[`conflict${type}`] = this._conflict.getValue();

    return returnValue;
  }

  render() {
    let { title, config, type } = this.props;
    return (
      <div className="panel panel-default">
        <div className="panel-heading">{title}</div>
        <div className="panel-body">
          <div className="row">
            <div className="col-xs-6">
              <Setting ref={(i) => { this._open = i; } } setting='open' label='👀 Open' value={config[`open${type}`]} />
            </div>
            <div className="col-xs-6">
              <Setting ref={(i) => { this._close = i; } } setting='close' label='😡 Close' value={config[`close${type}`]} />
            </div>
          </div>
          <div className="row">
            <div className="col-xs-6">
              <Setting ref={(i) => { this._fail = i; } } setting='fail' label='👎 Build Failure' value={config[`fail${type}`]} />
            </div>
            <div className="col-xs-6">
              <Setting ref={(i) => { this._pass = i; } } setting='pass' label='🎉 Build Success' value={config[`pass${type}`]} />
            </div>
          </div>
          {/* <div className="row">
            <div className="col-xs-6">
              <Setting ref={(i) => { this._ = i; } } setting='stale' label='💩 Stale' value={config[`stale${type}`]} />
            </div>
            <div className="col-xs-6">
              <Setting ref={(i) => { this._ = i; } } setting='unstale' label='✉️ Active' value={config[`unstale${type}`]} />
            </div>
          </div> */}
          <div className="row">
            <div className="col-xs-6">
              <Setting ref={(i) => { this._merge = i; } } setting='merge' label='😈 Merged' value={config[`merge${type}`]} />
            </div>
            <div className="col-xs-6">
              <Setting ref={(i) => { this._conflict = i; } } setting='conflict' label='✖︎ Merge Conflicts' value={config[`conflict${type}`]} />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
