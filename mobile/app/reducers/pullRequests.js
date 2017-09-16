import { TOGGLE_EXPAND_PR } from '../actions/constants/pullRequest';

const initialState = {
  main: [
    {id: 1, title: 'CC-2376 Adding force category to backend to enable ability to move the saved vendor object to a new category if it is in the wrong one.', status: 'SUCCESS', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 2, title: 'Start on measuring cache key hit rates.', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 3, title: 'CC-2468 Catalog moved over to v5.', status: 'CONFLICT', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 4, title: 'Top level changes', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 5, title: 'Cucumber Messaging Feature', status: 'PENDING', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 6, title: 'Someone had to do it :)', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 7, title: 'Reload objects in memory after the database cleaner has rolled back the transaction.', status: 'ERROR', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 8, title: '[ CC-1833 ] Race condition', status: 'SUCCESS', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 9, title: 'Some other PR I made up', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 10, title: 'Some other PR I made up', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
  ],
  monitors: [
    {id: 1, title: 'CC-2376 Adding force category to backend to enable ability to move the saved vendor object to a new category if it is in the wrong one.', status: 'SUCCESS', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 2, title: 'Start on measuring cache key hit rates.', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 3, title: 'CC-2468 Catalog moved over to v5.', status: 'CONFLICT', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 4, title: 'Top level changes', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 5, title: 'Cucumber Messaging Feature', status: 'PENDING', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 6, title: 'Someone had to do it :)', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 7, title: 'Reload objects in memory after the database cleaner has rolled back the transaction.', status: 'ERROR', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 8, title: '[ CC-1833 ] Race condition', status: 'SUCCESS', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 9, title: 'Some other PR I made up', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 10, title: 'Some other PR I made up', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
  ],
  hidden: [
    {id: 1, title: 'CC-2376 Adding force category to backend to enable ability to move the saved vendor object to a new category if it is in the wrong one.', status: 'SUCCESS', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 2, title: 'Start on measuring cache key hit rates.', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 3, title: 'CC-2468 Catalog moved over to v5.', status: 'CONFLICT', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 4, title: 'Top level changes', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 5, title: 'Cucumber Messaging Feature', status: 'PENDING', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 6, title: 'Someone had to do it :)', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 7, title: 'Reload objects in memory after the database cleaner has rolled back the transaction.', status: 'ERROR', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 8, title: '[ CC-1833 ] Race condition', status: 'SUCCESS', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 9, title: 'Some other PR I made up', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
    {id: 10, title: 'Some other PR I made up', status: 'FAILURE', avatar: 'https://avatars1.githubusercontent.com/u/5035724?v=4', repo: 'weddingwire-ng', buildUrl: 'https://travis-ci.com/weddingwire/weddingwire-ng/builds/50174437?utm_source=github_status&utm_medium=notification'},
  ]
}

export default pullRequests = (state = initialState, action) => {
  switch (action.type) {
    case TOGGLE_EXPAND_PR:
      let newState = Object.assign({}, state);
      let prIndex = newState[action.from].findIndex((p) => p.id == action.id);
      newState[action.from][prIndex].expand = !newState[action.from][prIndex].expand;
      return newState;
    default:
      return state;
  }
}
