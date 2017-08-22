
window.jQuery = window.$ = require('jquery');
require('messenger/build/js/messenger.js');
window._ = require('underscore');
window.async = require('async');
require('bootstrap');
require('form-serializer');
window.MD5 = require('md5');
window._.mixin(require('underscore.string').exports());
window.moment = require('moment');

require('style-loader!css-loader!bootswatch/spacelab/bootstrap.css');
require('style-loader!css-loader!messenger/build/css/messenger.css');
require('style-loader!css-loader!messenger/build/css/messenger-spinner.css');
require('style-loader!css-loader!messenger/build/css/messenger-theme-future.css');
require('style-loader!css-loader!font-awesome/css/font-awesome.css');

require('style-loader!css-loader!sass-loader?sourceMap=true!../stylesheets/all.sass');
require('style-loader!css-loader!less-loader?sourceMap=true!../stylesheets/loaders.less');
