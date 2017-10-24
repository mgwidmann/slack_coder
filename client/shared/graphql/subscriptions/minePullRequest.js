import { graphql } from 'react-apollo';
import createSubscribePR from './subscribePR';
import PULL_REQUESTS_QUERY from '../queries/minePullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { mine, refetch, loading, subscribeToMore, error } }) => {
    return {
      pullRequests: mine,
      loading,
      error,
      refetch,
      subscribe: createSubscribePR(subscribeToMore, 'mine')
    };
  }
})
