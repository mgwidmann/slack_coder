import { createNetworkInterface } from 'react-apollo';

export default createNetworkInterface({
  uri: 'http://localhost:4000/api/graphql',
});
