import { graphql } from 'react-apollo';
import SUBSCRIBE_PULL_REQUEST from './pullRequest.graphql';

export default graphql(SUBSCRIBE_PULL_REQUEST, {
  options: ({ pr }) => {
    return {
      props: () => {
        console.log("props called")
      },
      subscribePullRequest: (params) => {
        console.log("Called subscribe", params);
      }
    }
  }
})
