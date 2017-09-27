import { graphql } from 'react-apollo';
import USERS_QUERY from  './users.graphql';

export default graphql(USERS_QUERY, {
  props: ({ data: { users, loading, fetchMore, error }}) => {
    if (loading) {
      return { loading };
    } else {
      let { pageSize, pageNumber, totalPages, totalEntries, entries } = users;
      return {
        users: entries,
        pageNumber,
        pageSize,
        totalPages,
        totalEntries,
        loading,
        gotoPage(page) {
          fetchMore({
            variables: {
              page: page
            },
            updateQuery: (previousResult, { fetchMoreResult }) => {
              if (!fetchMoreResult) { return previousResult; }
              return fetchMoreResult;
            }
          });
        }
      }
    }
  }
});
