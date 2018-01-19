import React from 'react';
import { compose } from 'react-apollo';
import parseLogs from '../../../mobile/shared/graphql/queries/failedTests';

const FailedTests = ({ rspec_failure, cucumber_failure }) => {
  return (
    <div>
      <div className="panel panel-default">
        <div className="panel-heading">
          <h3 class="panel-title">Rspec</h3>
        </div>
        <div className="panel-body">
          {rspec_failure}
        </div>
      </div>
      <div className="panel panel-default">
        <div className="panel-heading">
          <h3 class="panel-title">Cucumber</h3>
        </div>
        <div className="panel-body">
          {cucumber_failure}
        </div>
      </div>
    </div>
  );
}

export default compose(parseLogs(FailedTests));