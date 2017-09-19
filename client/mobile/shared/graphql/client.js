import { ApolloClient, createNetworkInterface } from 'react-apollo';
import networkInterface from './networkInterface';

export default new ApolloClient({
  reduxRootSelector: () => 'graphql',
  networkInterface: networkInterface
});
