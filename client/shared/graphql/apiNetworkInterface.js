import { createNetworkInterface } from 'react-apollo';

export default createNetworkInterface({
  uri: 'http://192.168.1.176:4000/api/graphql',
});
