import { graphql } from 'react-apollo';
import SUBSCRIBE_NEW_PULL_REQUEST from './newPullRequest.graphql';

export default graphql(SUBSCRIBE_NEW_PULL_REQUEST, {
  options: ({ currentUser }) => {
    return {
      updateQuery: (prev, { subscriptionData }) => {
        if (!subscriptionData.data) {
          return prev;
        }
        let newPullRequest = subscriptionData.data.newPullRequest;
        let type = newPullRequest.user.id == currentUser.id ? 'mine' : 'monitors';
        let result = Object.assign([], prev[type]);
        let index = result.findIndex(p => p.user.id == newPullRequest.user.id);
        result.splice(index, 0, newPullRequest);

        let fullResult = Object.assign({}, prev);
        fullResult[type] = result;
        return fullResult;
      }
    }
  }
});
