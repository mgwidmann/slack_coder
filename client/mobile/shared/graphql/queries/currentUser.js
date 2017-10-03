import { graphql } from 'react-apollo';
import CURRENT_USER_QUERY from  './currentUser.graphql';

export default graphql(CURRENT_USER_QUERY, {
  props: ({data: { user, loading }}) => {
    return {
      currentUser: user,
      loading
    }
  }
});
