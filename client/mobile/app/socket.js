import {Socket} from "phoenix";

export default (token) => {
  let socket = new Socket("ws://192.168.1.176:4000/socket", { params: { token: token } });
  socket.connect();
  socket.onOpen( ev => console.log("OPEN", ev) )
  socket.onError( ev => console.log("ERROR", ev) )

  return socket;
}
