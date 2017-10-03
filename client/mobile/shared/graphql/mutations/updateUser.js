import { graphql } from 'react-apollo';
import UPDATE_USER_MUTATION from  './updateUser.graphql';

export default graphql(UPDATE_USER_MUTATION, {
  name: 'updateUser'
});
