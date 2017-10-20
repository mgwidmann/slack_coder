import configureClient from '../shared/graphql/client';
import websocketNetworkInterface from '../shared/graphql/websocketNetworkInterface';
import createSocket from './socket';

export default configureClient(websocketNetworkInterface('ws://slack-coder.dev:4000/socket', createSocket));
