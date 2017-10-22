import { refreshToken } from '../shared/actions/token';
import Config from 'react-native-config';

export default function(client, store) {
  // Setup client interface
  const logout = () => {
    const refreshUrl = `${Config.SLACK_CODER_HTTP_PROTOCOL}://${Config.SLACK_CODER_HOST}/api/token/${store.getState().token}/refresh`;
    store.dispatch(refreshToken(refreshUrl));
  }
  // Set the token on the options so when the socket is created it has access
  client.networkInterface.use([{
    applyMiddleware({ request, options }, next) {
      options.token = store.getState().token;
      options.logout = logout;
      next()
    }
  }]);
}