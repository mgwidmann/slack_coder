import {createNetworkInterface} from 'apollo-phoenix-websocket'

export default (socket) => {
  return createNetworkInterface({
    uri: '/this-does-not-matter',
    Socket: () => { return socket; }
  });
}
