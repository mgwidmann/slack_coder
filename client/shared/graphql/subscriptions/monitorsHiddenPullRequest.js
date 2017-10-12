import { graphql } from 'react-apollo';
import createSubscribePR from './subscribePR';
import PULL_REQUESTS_QUERY from '../queries/monitorsHiddenPullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { monitors, loading, subscribeToMore, error } }) => {
    return {
      pullRequests: monitors,
      loading,
      error,
      subscribe: createSubscribePR(subscribeToMore, 'monitors', true)
    };
  }
})
