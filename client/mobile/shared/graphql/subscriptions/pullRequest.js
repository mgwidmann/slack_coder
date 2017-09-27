import { graphql } from 'react-apollo';
import SUBSCRIBE_PULL_REQUEST from './pullRequest.graphql';
import PULL_REQUESTS_QUERY from '../queries/pullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { currentUser, mine, monitors, loading, subscribeToMore } }) => {
    return {
      currentUser,
      mine,
      monitors,
      loading,
      subscribePullRequest: (params) => {
        subscribeToMore({
          document: SUBSCRIBE_PULL_REQUEST,
          variables: {
            id: params.id,
          }
        })
      }
    };
  }
})
