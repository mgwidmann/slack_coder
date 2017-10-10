import { graphql } from 'react-apollo';
import SYNCHRONIZE_PR_QUERY from  './synchronize.graphql';

export default graphql(SYNCHRONIZE_PR_QUERY, {
  name: 'synchronize'
});
