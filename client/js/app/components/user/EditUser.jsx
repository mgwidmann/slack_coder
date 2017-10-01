import React from 'react';
import EditSlack from './EditSlack';
import EditMonitors from './EditMonitors';
import GeneralSettings from './GeneralSettings';
import NotificationSettings from './NotificationSettings';

export default ({ user, search }) => {
  return (
    <div className="row">
      <div className="col-xs-8 col-xs-offset-2">
        <div className="row">
          <div className="form-group col-xs-6">
            <EditSlack github={user.github} slack={user.slack} />
            <EditMonitors monitors={user.monitors} search={search} />
          </div>

          <div className="form-group col-xs-6">
            <h4>Notifications</h4>
            <GeneralSettings muted={user.muted} />
            <NotificationSettings title={'My Pull Requests'} config={user.config} type='Self' />
            <NotificationSettings title={'People I Monitor'} config={user.config} type='Monitors' />
          </div>
        </div>

        <div className="form-group pull-right">
          <input type="submit" className="btn btn-primary" />
        </div>
      </div>
    </div>
  )
}
