import { SET_TOKEN, SET_LOGGED_IN, SET_LOGGED_OUT, SET_OFFLINE } from './constants/login';

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

export function setToken(value) {
  return {
    type: SET_TOKEN,
    token: value
  };
}

export function setLoggedIn() {
  return {
    type: SET_LOGGED_IN
  }
}

export function setLoggedOut() {
  return {
    type: SET_LOGGED_OUT
  }
}

export function setOffline() {
  return {
    type: SET_OFFLINE
  }
}

export function refreshToken(url) {
  return (dispatch) => {
    fetch(url)
    .then((response) => response.json())
    .then(({ token }) => {
      if (token) {
        dispatch(setLoggedIn());
      }
      dispatch(setToken(token || null));
    })
    .catch((e) => {
      dispatch(setToken(null));
      dispatch(setOffline());
    })
  };
}