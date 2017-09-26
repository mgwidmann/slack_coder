import configureClient from '../../mobile/shared/graphql/client';
import networkInterface from '../../mobile/shared/graphql/websocketNetworkInterface';
import socket from '../socket';

export default configureClient(networkInterface(socket));
