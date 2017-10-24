import { graphql } from 'react-apollo';
import createSubscribePR from './subscribePR';
import PULL_REQUESTS_QUERY from '../queries/monitorsPullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { monitors, refetch, loading, subscribeToMore, error } }) => {
    return {
      pullRequests: monitors,
      loading,
      error,
      refetch,
      subscribe: createSubscribePR(subscribeToMore, 'monitors')
    };
  }
})
