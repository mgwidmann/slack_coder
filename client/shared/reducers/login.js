import { SET_TOKEN, SET_LOGGED_IN, SET_LOGGED_OUT, SET_OFFLINE, SET_LOADING } from '../actions/constants/login';

const initialState = {
  token: null,
  loggedIn: false,
  offline: false,
  loading: true
};

export default function(state = initialState, action) {
  switch(action.type) {
    case SET_TOKEN:
      return {
        ...state,
        loading: true,
        token: action.token,
      };
    case SET_LOGGED_IN:
      return {
        ...state,
        loading: false,
        loggedIn: true
      };
    case SET_LOGGED_OUT:
      return {
        ...state,
        loading: false,
        loggedIn: false
      };
    case SET_OFFLINE:
      return {
        ...state,
        loggedIn: false,
        loading: false,
        offline: true
      }
    case SET_LOADING:
      return {
        ...state,
        loading: true
      }
    default:
      return state;
  }
}