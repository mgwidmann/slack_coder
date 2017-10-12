import { graphql } from 'react-apollo';
import TOGGLE_HIDE_PULL_REQUEST from  './toggleHidePullRequest.graphql';

export default graphql(TOGGLE_HIDE_PULL_REQUEST, {
  name: 'toggleHidePullRequest'
});
