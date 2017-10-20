import configureClient from '../shared/graphql/client';
import websocketNetworkInterface from '../shared/graphql/websocketNetworkInterface';
import createSocket from './socket';
import Config from 'react-native-config';

export default configureClient(websocketNetworkInterface(`ws://${Config.SLACK_CODER_HOST}/socket`, createSocket));
