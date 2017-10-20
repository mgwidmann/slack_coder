import {Socket} from "phoenix";

export default (uri, options) => {
  let socket = new Socket(uri, { params: { token: options.token } });
  socket.onError((_error) => {
    console.log("Token is invalid, unable to connect to websocket");
    if (options.logout) {
      options.logout();
    }
  });
  
  if (options.token) {
    socket.connect();
  }

  return socket;
}
