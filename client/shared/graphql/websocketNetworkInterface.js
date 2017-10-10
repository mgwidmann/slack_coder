import { createNetworkInterface } from 'apollo-phoenix-websocket';

export default (uri, createSocket) => {
  return createNetworkInterface({
    uri: uri,
    Socket: (uri, options) => {
      return createSocket(uri, options)
    }
  });
}
