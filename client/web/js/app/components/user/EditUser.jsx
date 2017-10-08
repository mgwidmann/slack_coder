import React, { Component } from 'react';
import { Redirect } from 'react-router';
import EditSlack from './edit/EditSlack';
import EditMonitors from './edit/EditMonitors';
import GeneralSettings from './edit/GeneralSettings';
import NotificationSettings from './edit/NotificationSettings';

export default class EditUser extends Component {
  submitForm() {
    let { user, updateUser, success } = this.props;
    let userParams = {
      id: user.id,
      user: {
        slack: this._slack.getValue(),
        monitors: this._users.getUsers().map((u) => { return u.github; }),
        ...this._general.getSettings(),
        config: {
          ...this._selfConfig.getSettings(),
          ...this._monitorsConfig.getSettings()
        }
      }
    };
    updateUser({ variables: userParams }).then(() => {
      success()
    });
  };

  render() {
    let { user, search } = this.props;
    return (
      <div className="row">
        <div className="col-xs-8 col-xs-offset-2">
          <div className="row">
            <div className="form-group col-xs-6">
              <EditSlack ref={(i) => { this._slack = i; } } github={user.github} slack={user.slack} />
              <EditMonitors ref={(i) => { this._users = i; }} monitors={user.monitors} search={search} />
            </div>

            <div className="form-group col-xs-6">
              <h4>Notifications</h4>
              <GeneralSettings ref={(i) => { this._general = i; }} muted={user.muted} />
              <NotificationSettings ref={(i) => { this._selfConfig = i; }} title={'My Pull Requests'} config={user.config} type='Self' />
              <NotificationSettings ref={(i) => { this._monitorsConfig = i; }} title={'People I Monitor'} config={user.config} type='Monitors' />
            </div>
          </div>

          <div className="form-group pull-right">
            <input type="submit" onClick={::this.submitForm} className="btn btn-primary" />
          </div>
        </div>
      </div>
    )
  }
}
