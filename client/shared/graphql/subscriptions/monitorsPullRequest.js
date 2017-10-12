import { graphql } from 'react-apollo';
import createSubscribeNew from './subscribeNew';
import createSubscribePR from './subscribePR';
import PULL_REQUESTS_QUERY from '../queries/monitorsPullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { monitors, loading, subscribeToMore, error } }) => {
    return {
      monitors,
      monitorsLoading: loading,
      error,
      subscribeNew: createSubscribeNew(subscribeToMore),
      subscribeMonitors: createSubscribePR(subscribeToMore, 'monitors')
    };
  }
})
