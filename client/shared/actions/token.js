import { SET_TOKEN } from './constants/token';

export function setToken(value) {
  return {
    type: SET_TOKEN,
    token: value
  };
}

export function refreshToken(url) {
  return (dispatch) => {
    fetch(url)
    .then((response) => response.json())
    .then(({ token }) => {
      dispatch(setToken(token));
    })
    .catch((e) => {
      console.error("Unable to refresh token at URL", url, "\n", e);
      dispatch(setToken(null));
    })
  };
}