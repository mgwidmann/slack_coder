import { graphql } from 'react-apollo';
import SUBSCRIBE_PULL_REQUEST from './pullRequest.graphql';
import PULL_REQUESTS_QUERY from '../queries/pullRequests.graphql';

export default graphql(PULL_REQUESTS_QUERY, {
  props: ({ data: { currentUser, mine, monitors, loading, subscribeToMore, error } }) => {
    return {
      currentUser,
      mine,
      monitors,
      loading,
      error,
      subscribe(pr, type) {
        return subscribeToMore({
          document: SUBSCRIBE_PULL_REQUEST,
          variables: {
            id: pr.id,
          },
          updateQuery: (prev, {subscriptionData}) => {
            console.log("Update Query run");
            if (!subscriptionData.data) {
              return prev;
            }
            let pullRequest = subscriptionData.data.pullRequest;
            let index = prev[type].findIndex(p => p.id == pullRequest.id);
            if (index === -1) {
              return prev;
            }
            let result = Object.assign([], prev[type])
            if (pullRequest.closedAt || pullRequest.mergedAt) {
              result.splice(index, 1)
            } else {
              result.splice(index, 1, pullRequest);
            }
            let fullResult = Object.assign({}, prev);
            fullResult[type] = result;
            return fullResult;
          }
        });
      }
    };
  }
})
