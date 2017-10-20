import { SET_TOKEN } from './constants/token';

export function setToken(value) {
  return {
    type: SET_TOKEN,
    token: value
  };
}