import configureClient from '../shared/graphql/client';
import websocketNetworkInterface from '../shared/graphql/websocketNetworkInterface';
import createSocket from './socket';

export default configureClient(websocketNetworkInterface('ws://192.168.1.176:4000/socket', createSocket));
