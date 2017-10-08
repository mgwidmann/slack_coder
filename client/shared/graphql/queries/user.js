import { graphql } from 'react-apollo';
import USER_QUERY from  './user.graphql';

export default graphql(USER_QUERY, {
  options: (props) => ({ variables: { id: props.match.params.id } }),
  props: ({data: { user, loading }}) => {
    return {
      user,
      loading
    }
  }
});
