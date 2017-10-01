const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const { join, resolve } = require('path');

var BUILD_DIR = resolve(__dirname, '../priv/static');
var APP_DIR = __dirname;
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var config = {
  entry:{
    'app.bundle': [resolve(__dirname, 'js/App.jsx')],
    'store.bundle': [resolve(__dirname, 'js/app/store.js')],
    'dependencies.bundle': [
      "react",
      "react-dom",
      "react-redux",
      "redux-thunk",
      "redux-logger",
      "react-router-redux",
      "history",
      "react-apollo",
      "qrcode.react",
      "graphql-tag",
      "react-select",
      "apollo-phoenix-websocket",
      "jquery",
      "phoenix",
      "bootstrap",
    ]
  },
  output: {
    path: BUILD_DIR,
    publicPath: '/js',
    filename: 'js/[name].js'
  },
  plugins: [
    new webpack.SourceMapDevToolPlugin(),
    new ExtractTextPlugin('css/app.css', { allChunks: true }),
    new webpack.EnvironmentPlugin({
      NODE_ENV: JSON.stringify(process.env.NODE_ENV),
      DEBUG: process.env.NODE_ENV == 'development'
    }),
    new webpack.optimize.CommonsChunkPlugin({ name: "dependencies.bundle", filename: 'js/[name].js', minChunks: Infinity }),
    // new webpack.ProvidePlugin({
    //   Promise: 'babel-polyfill'
    // }),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery"
    }),
    new CopyWebpackPlugin([{ from: resolve(join(__dirname, "./assets")) }], { ignore: [resolve(join(__dirname, '.gitkeep'))] }),
  ],
  resolve: {
    extensions: ['.json', '.jsx', '.js']
  },
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        include: __dirname,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'react', 'stage-0'],
            plugins: ['transform-decorators-legacy', 'transform-class-properties', ["resolver", { "resolveDirs": [resolve(join(__dirname, 'js'))] }]]
          }
        }
      },
      {
        test: /\.css$/,
        use: [
          { loader: "style-loader" },
          { loader: "css-loader" }
        ]
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          //resolve-url-loader may be chained before sass-loader if necessary
          use: ['css-loader', 'sass-loader']
        })
      },
      {
        test: /\.(graphql|gql)$/,
        exclude: /node_modules/,
        loader: 'graphql-tag/loader',
      }
      // { test: /\.png$/, loader: "url-loader?limit=100000" },
      // { test: /\.jpg$/, loader: "file-loader" },
      // { test: /\.(woff2?|svg)$/, loader: 'url?limit=10000' },
      // { test: /\.(ttf|eot)$/, loader: 'file' },
      // { test: /\.json$/, loader: "json-loader" }
    ]
  }
};

module.exports = config;
