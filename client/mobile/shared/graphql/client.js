import { ApolloClient } from 'react-apollo';

let client;
export default (networkInterface) => {
  if (client) {
    return client;
  } else {
    client = new ApolloClient({
      reduxRootSelector: (state) => state.graphql,
      networkInterface: networkInterface
    });
    return client;
  }
};
