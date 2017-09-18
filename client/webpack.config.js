const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const { join, resolve } = require('path');

var BUILD_DIR = resolve(__dirname, '../priv/static');
var APP_DIR = __dirname;

var config = {
  entry:{
    'App': [resolve(__dirname, 'js/App.js')],
    'dependencies': [
      'react',
      'redux'
    ]
  },
  output: {
    path: BUILD_DIR,
    publicPath: '/js',
    filename: 'js/[name].js'
  },
  plugins: [
    new ExtractTextPlugin('css/app.css', { allChunks: true }),
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': '"production"'
      }
    }),
    new webpack.ProvidePlugin({
      Promise: 'babel-polyfill'
    }),
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
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          //resolve-url-loader may be chained before sass-loader if necessary
          use: ['css-loader', 'sass-loader']
        })
      },
      // { test: /\.png$/, loader: "url-loader?limit=100000" },
      // { test: /\.jpg$/, loader: "file-loader" },
      // { test: /\.(woff2?|svg)$/, loader: 'url?limit=10000' },
      // { test: /\.(ttf|eot)$/, loader: 'file' },
      // { test: /\.json$/, loader: "json-loader" }
    ]
  }
};

module.exports = config;
