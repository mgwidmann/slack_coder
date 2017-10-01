import React from 'react';
import Setting from './Setting';

export default ({ title, config, type }) => {
  return (
    <div className="panel panel-default">
      <div className="panel-heading">{title}</div>
      <div className="panel-body">
        <div className="row">
          <div className="col-xs-6">
            <Setting setting='open' label='👀 Open' value={config[`open${type}`]} />
          </div>
          <div className="col-xs-6">
            <Setting setting='close' label='😡 Close' value={config[`close${type}`]} />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-6">
            <Setting setting='fail' label='👎 Build Failure' value={config[`fail${type}`]} />
          </div>
          <div className="col-xs-6">
            <Setting setting='pass' label='🎉 Build Success' value={config[`pass${type}`]} />
          </div>
        </div>
        {/* <div className="row">
          <div className="col-xs-6">
            <Setting setting='stale' label='💩 Stale' value={config[`stale${type}`]} />
          </div>
          <div className="col-xs-6">
            <Setting setting='unstale' label='✉️ Active' value={config[`unstale${type}`]} />
          </div>
        </div> */}
        <div className="row">
          <div className="col-xs-6">
            <Setting setting='merge' label='😈 Merged' value={config[`merge${type}`]} />
          </div>
          <div className="col-xs-6">
            <Setting setting='conflict' label='✖︎ Merge Conflicts' value={config[`conflict${type}`]} />
          </div>
        </div>
      </div>
    </div>
  )
}
