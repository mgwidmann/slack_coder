import configureClient from '../shared/graphql/client';
import networkInterface from '../shared/graphql/apiNetworkInterface';

// Configure default client w/ api network interface so it won't make any requests
export default configureClient(networkInterface);
