import { graphql } from 'react-apollo';
import SEARCH_USERS_QUERY from  './searchUsers.graphql';

export default graphql(SEARCH_USERS_QUERY, {
  props: ({ data: { users, loading, fetchMore, error }}) => {
    return {
      searchResults: users ? users.entries : undefined,
      searchLoading: loading,
      search(q) {
        return fetchMore({
          variables: {
            search: q
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            if (!fetchMoreResult) { return previousResult; }
            return fetchMoreResult;
          }
        });
      }
    }
  }
});
