const ExtractTextPlugin = require('extract-text-webpack-plugin');
const Path = require('path');

module.exports = {
  entry: {
    'vendors': "./source/javascripts/vendors.js",
    'index': "./source/javascripts/index.js"
  },
  target: 'electron',
  output: {
    path: Path.join(__dirname, 'bundle'),
    filename: "[name].js"
  },
  module: {
    rules: [{
      test: /\.(png|woff|woff2|eot|ttf|svg)$/,
      loader: 'url-loader'
    }]
  }
};
