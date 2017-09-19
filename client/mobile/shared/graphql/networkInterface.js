import { createNetworkInterface } from 'react-apollo';

export default networkInterface = createNetworkInterface({
  uri: 'http://localhost:4000/api/graphql',
});
