import { graphql } from 'react-apollo';
import USERS_QUERY from  './users.graphql';

export default graphql(USERS_QUERY, {
  props: ({ data: { users, loading, fetchMore, error }}) => {
    if (loading) {
      return { loading, users: [], pageNumber: 0, totalPages: 0, totalEntries: 0, gotoPage() {} };
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
          return fetchMore({
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
