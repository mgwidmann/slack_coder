import { SET_TOKEN } from '../actions/constants/token';

export default function(state = null, action) {
  switch(action.type) {
    case SET_TOKEN:
      return action.token;
    default:
      return state;
  }
}