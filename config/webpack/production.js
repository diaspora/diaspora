// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require("webpack");
const merge = require("webpack-merge");
const CompressionPlugin = require("compression-webpack-plugin");
const sharedConfig = require("./shared.js");

module.exports = merge(sharedConfig, {
  output: { filename: "[name]-[chunkhash].js" },
  devtool: "source-map",
  stats: "normal",

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      minimize: true,
      sourceMap: true,

      compress: {
        warnings: false
      },

      output: {
        comments: false
      }
    }),

    new CompressionPlugin({
      asset: "[path].gz[query]",
      algorithm: "gzip",
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
    })
  ]
});
