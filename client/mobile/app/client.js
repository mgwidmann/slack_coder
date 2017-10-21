import configureClient from '../shared/graphql/client';
import websocketNetworkInterface from '../shared/graphql/websocketNetworkInterface';
import createSocket from './socket';
import Config from 'react-native-config';

const wss = Config.SLACK_CODER_WEBSOCKET_PROTOCOL;
export default configureClient(websocketNetworkInterface(`${wss}://${Config.SLACK_CODER_HOST}/socket`, createSocket));
