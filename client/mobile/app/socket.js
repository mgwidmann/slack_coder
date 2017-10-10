import {Socket} from "phoenix";

export default (uri, options) => {
  let socket = new Socket(uri, { params: { token: options.token } });
  socket.connect();
  socket.onError( ev => console.log("WEBSOCET ERROR:", ev) )

  return socket;
}
