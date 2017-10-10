import { TOGGLE_EXPAND_PR } from './constants/pullRequest';

export function toggleExpandPR(pr) {
  return {
    type: TOGGLE_EXPAND_PR,
    id: pr.id
  };
}
