import { Socket } from "phoenix";
import { connectionOnline, connectionOffline, reconnect, token } from './network';

export default (uri, options) => {
  let timeoutTimer = null;
  let socket = new Socket(uri, { params: { token: token() } });
  socket.onError((_error) => {
    console.log("Token is invalid, unable to connect to websocket");
  });
  socket.onOpen(() => {
    connectionOnline();
  });
  socket.onClose(() => {
    reconnect();
    clearTimeout(timeoutTimer);
    timeoutTimer = setTimeout(() => {
      if (!socket.isConnected()) {
        connectionOffline();
      }
    }, 5000)
  });
  
  if (token()) {
    socket.connect();
  }

  return socket;
}
