import {Socket} from "phoenix";

let socket = new Socket("/socket", { params: { token: token } });
socket.connect();
export default socket;
