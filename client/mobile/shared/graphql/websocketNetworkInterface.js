import {createNetworkInterface} from 'apollo-phoenix-websocket'

export default (socket) => {
  return createNetworkInterface({
    uri: 'ws://localhost:4000/socket',
    Socket: () => { return socket; }
  });
}
