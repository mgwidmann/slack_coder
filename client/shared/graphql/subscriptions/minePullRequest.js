import { graphql } from 'react-apollo';
import createSubscribeNew from './subscribeNew';
import createSubscribePR from './subscribePR';
import PULL_REQUESTS_QUERY from '../queries/minePullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { mine, loading, subscribeToMore, error } }) => {
    return {
      mine,
      mineLoading: loading,
      error,
      subscribeNew: createSubscribeNew(subscribeToMore),
      subscribeMine: createSubscribePR(subscribeToMore, 'mine')
    };
  }
})
