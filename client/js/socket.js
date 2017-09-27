import {Socket} from "phoenix";

let socket = new Socket("/socket", { params: { token: token } });
if (token != null) { // Don't try to connect if theres no token since it wont work
  socket.connect();
}
export default socket;
