import {
  SET_TOKEN,
  SET_LOGGED_IN,
  SET_LOGGED_OUT,
  SET_ONLINE,
  SET_OFFLINE,
  SET_RECONNECTING
} from './constants/login';

// LOGIN / LOGOUT actions

export function login(token) {
  return (dispatch) => {
    dispatch(setToken(token));
    dispatch(setLoggedIn());
  };
}

export function logout() {
  return (dispatch) => {
    dispatch(setToken(null));
    dispatch(setLoggedOut());
  };
}

function setToken(value) {
  return {
    type: SET_TOKEN,
    token: value
  };
}

function setLoggedIn() {
  return {
    type: SET_LOGGED_IN
  };
}

function setLoggedOut() {
  return {
    type: SET_LOGGED_OUT
  };
}

// CONNECTION actions

export function online() {
  return {
    type: SET_ONLINE
  };
}

export function reconnecting() {
  return {
    type: SET_RECONNECTING
  };
}

export function offline() {
  return {
    type: SET_OFFLINE
  };
}

export function refreshToken(url) {
  return (dispatch) => {
    fetch(url)
    .then((response) => response.json())
    .then(({ token }) => {
      dispatch(setToken(token || null));
      if (token) {
        dispatch(setLoggedIn());
      }
    })
    .catch((e) => {
      dispatch(setToken(null));
      dispatch(offline());
    })
  };
}