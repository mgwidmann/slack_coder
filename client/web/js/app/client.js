import configureClient from '../../shared/graphql/client';
import networkInterface from '../../shared/graphql/websocketNetworkInterface';
import socket from './socket';

export default configureClient(networkInterface('/socket', () => { return socket }));
