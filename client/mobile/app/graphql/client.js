import { ApolloClient, createNetworkInterface } from 'react-apollo';

export default client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: 'http://slack-coder.nanoapp.io/api/graphql',
  })
});
