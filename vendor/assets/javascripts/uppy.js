/**
 * Uppy v1.5.2 https://uppy.io
 * 
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Transloadit (https://transloadit.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
  window.Uppy = {}
  Uppy.Core = require('@uppy/core')
  Uppy.XHRUpload = require('@uppy/xhr-upload')
  
  },{"@uppy/core":9,"@uppy/xhr-upload":29}],2:[function(require,module,exports){
  'use strict';
  
  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
  
  function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }
  
  function isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }
  
  function _construct(Parent, args, Class) { if (isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }
  
  function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }
  
  function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }
  
  function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }
  
  var AuthError =
  /*#__PURE__*/
  function (_Error) {
    _inheritsLoose(AuthError, _Error);
  
    function AuthError() {
      var _this;
  
      _this = _Error.call(this, 'Authorization required') || this;
      _this.name = 'AuthError';
      _this.isAuthError = true;
      return _this;
    }
  
    return AuthError;
  }(_wrapNativeSuper(Error));
  
  module.exports = AuthError;
  },{}],3:[function(require,module,exports){
  'use strict';
  
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
  
  var RequestClient = require('./RequestClient');
  
  var tokenStorage = require('./tokenStorage');
  
  var _getName = function _getName(id) {
    return id.split('-').map(function (s) {
      return s.charAt(0).toUpperCase() + s.slice(1);
    }).join(' ');
  };
  
  module.exports =
  /*#__PURE__*/
  function (_RequestClient) {
    _inheritsLoose(Provider, _RequestClient);
  
    function Provider(uppy, opts) {
      var _this;
  
      _this = _RequestClient.call(this, uppy, opts) || this;
      _this.provider = opts.provider;
      _this.id = _this.provider;
      _this.authProvider = opts.authProvider || _this.provider;
      _this.name = _this.opts.name || _getName(_this.id);
      _this.pluginId = _this.opts.pluginId;
      _this.tokenKey = "companion-" + _this.pluginId + "-auth-token";
      return _this;
    }
  
    var _proto = Provider.prototype;
  
    _proto.headers = function headers() {
      var _this2 = this;
  
      return new Promise(function (resolve, reject) {
        _RequestClient.prototype.headers.call(_this2).then(function (headers) {
          _this2.getAuthToken().then(function (token) {
            resolve(_extends({}, headers, {
              'uppy-auth-token': token
            }));
          });
        }).catch(reject);
      });
    };
  
    _proto.onReceiveResponse = function onReceiveResponse(response) {
      response = _RequestClient.prototype.onReceiveResponse.call(this, response);
      var plugin = this.uppy.getPlugin(this.pluginId);
      var oldAuthenticated = plugin.getPluginState().authenticated;
      var authenticated = oldAuthenticated ? response.status !== 401 : response.status < 400;
      plugin.setPluginState({
        authenticated: authenticated
      });
      return response;
    } // @todo(i.olarewaju) consider whether or not this method should be exposed
    ;
  
    _proto.setAuthToken = function setAuthToken(token) {
      return this.uppy.getPlugin(this.pluginId).storage.setItem(this.tokenKey, token);
    };
  
    _proto.getAuthToken = function getAuthToken() {
      return this.uppy.getPlugin(this.pluginId).storage.getItem(this.tokenKey);
    };
  
    _proto.authUrl = function authUrl() {
      return this.hostname + "/" + this.id + "/connect";
    };
  
    _proto.fileUrl = function fileUrl(id) {
      return this.hostname + "/" + this.id + "/get/" + id;
    };
  
    _proto.list = function list(directory) {
      return this.get(this.id + "/list/" + (directory || ''));
    };
  
    _proto.logout = function logout() {
      var _this3 = this;
  
      return new Promise(function (resolve, reject) {
        _this3.get(_this3.id + "/logout").then(function (res) {
          _this3.uppy.getPlugin(_this3.pluginId).storage.removeItem(_this3.tokenKey).then(function () {
            return resolve(res);
          }).catch(reject);
        }).catch(reject);
      });
    };
  
    Provider.initPlugin = function initPlugin(plugin, opts, defaultOpts) {
      plugin.type = 'acquirer';
      plugin.files = [];
  
      if (defaultOpts) {
        plugin.opts = _extends({}, defaultOpts, opts);
      }
  
      if (opts.serverUrl || opts.serverPattern) {
        throw new Error('`serverUrl` and `serverPattern` have been renamed to `companionUrl` and `companionAllowedHosts` respectively in the 0.30.5 release. Please consult the docs (for example, https://uppy.io/docs/instagram/ for the Instagram plugin) and use the updated options.`');
      }
  
      if (opts.companionAllowedHosts) {
        var pattern = opts.companionAllowedHosts; // validate companionAllowedHosts param
  
        if (typeof pattern !== 'string' && !Array.isArray(pattern) && !(pattern instanceof RegExp)) {
          throw new TypeError(plugin.id + ": the option \"companionAllowedHosts\" must be one of string, Array, RegExp");
        }
  
        plugin.opts.companionAllowedHosts = pattern;
      } else {
        // does not start with https://
        if (/^(?!https?:\/\/).*$/i.test(opts.companionUrl)) {
          plugin.opts.companionAllowedHosts = "https://" + opts.companionUrl.replace(/^\/\//, '');
        } else {
          plugin.opts.companionAllowedHosts = opts.companionUrl;
        }
      }
  
      plugin.storage = plugin.opts.storage || tokenStorage;
    };
  
    return Provider;
  }(RequestClient);
  },{"./RequestClient":4,"./tokenStorage":7}],4:[function(require,module,exports){
  'use strict';
  
  var _class, _temp;
  
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
  
  function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }
  
  var AuthError = require('./AuthError'); // Remove the trailing slash so we can always safely append /xyz.
  
  
  function stripSlash(url) {
    return url.replace(/\/$/, '');
  }
  
  module.exports = (_temp = _class =
  /*#__PURE__*/
  function () {
    function RequestClient(uppy, opts) {
      this.uppy = uppy;
      this.opts = opts;
      this.onReceiveResponse = this.onReceiveResponse.bind(this);
      this.allowedHeaders = ['accept', 'content-type', 'uppy-auth-token'];
      this.preflightDone = false;
    }
  
    var _proto = RequestClient.prototype;
  
    _proto.headers = function headers() {
      var userHeaders = this.opts.companionHeaders || this.opts.serverHeaders || {};
      return Promise.resolve(_extends({}, this.defaultHeaders, {}, userHeaders));
    };
  
    _proto._getPostResponseFunc = function _getPostResponseFunc(skip) {
      var _this = this;
  
      return function (response) {
        if (!skip) {
          return _this.onReceiveResponse(response);
        }
  
        return response;
      };
    };
  
    _proto.onReceiveResponse = function onReceiveResponse(response) {
      var state = this.uppy.getState();
      var companion = state.companion || {};
      var host = this.opts.companionUrl;
      var headers = response.headers; // Store the self-identified domain name for the Companion instance we just hit.
  
      if (headers.has('i-am') && headers.get('i-am') !== companion[host]) {
        var _extends2;
  
        this.uppy.setState({
          companion: _extends({}, companion, (_extends2 = {}, _extends2[host] = headers.get('i-am'), _extends2))
        });
      }
  
      return response;
    };
  
    _proto._getUrl = function _getUrl(url) {
      if (/^(https?:|)\/\//.test(url)) {
        return url;
      }
  
      return this.hostname + "/" + url;
    };
  
    _proto._json = function _json(res) {
      if (res.status === 401) {
        throw new AuthError();
      }
  
      if (res.status < 200 || res.status > 300) {
        var errMsg = "Failed request with status: " + res.status + ". " + res.statusText;
        return res.json().then(function (errData) {
          errMsg = errData.message ? errMsg + " message: " + errData.message : errMsg;
          errMsg = errData.requestId ? errMsg + " request-Id: " + errData.requestId : errMsg;
          throw new Error(errMsg);
        }).catch(function () {
          throw new Error(errMsg);
        });
      }
  
      return res.json();
    };
  
    _proto.preflight = function preflight(path) {
      var _this2 = this;
  
      return new Promise(function (resolve, reject) {
        if (_this2.preflightDone) {
          return resolve(_this2.allowedHeaders.slice());
        }
  
        fetch(_this2._getUrl(path), {
          method: 'OPTIONS'
        }).then(function (response) {
          if (response.headers.has('access-control-allow-headers')) {
            _this2.allowedHeaders = response.headers.get('access-control-allow-headers').split(',').map(function (headerName) {
              return headerName.trim().toLowerCase();
            });
          }
  
          _this2.preflightDone = true;
          resolve(_this2.allowedHeaders.slice());
        }).catch(function (err) {
          _this2.uppy.log("[CompanionClient] unable to make preflight request " + err, 'warning');
  
          _this2.preflightDone = true;
          resolve(_this2.allowedHeaders.slice());
        });
      });
    };
  
    _proto.preflightAndHeaders = function preflightAndHeaders(path) {
      var _this3 = this;
  
      return Promise.all([this.preflight(path), this.headers()]).then(function (_ref) {
        var allowedHeaders = _ref[0],
            headers = _ref[1];
        // filter to keep only allowed Headers
        Object.keys(headers).forEach(function (header) {
          if (allowedHeaders.indexOf(header.toLowerCase()) === -1) {
            _this3.uppy.log("[CompanionClient] excluding unallowed header " + header);
  
            delete headers[header];
          }
        });
        return headers;
      });
    };
  
    _proto.get = function get(path, skipPostResponse) {
      var _this4 = this;
  
      return new Promise(function (resolve, reject) {
        _this4.preflightAndHeaders(path).then(function (headers) {
          fetch(_this4._getUrl(path), {
            method: 'get',
            headers: headers,
            credentials: 'same-origin'
          }).then(_this4._getPostResponseFunc(skipPostResponse)).then(function (res) {
            return _this4._json(res).then(resolve);
          }).catch(function (err) {
            err = err.isAuthError ? err : new Error("Could not get " + _this4._getUrl(path) + ". " + err);
            reject(err);
          });
        }).catch(reject);
      });
    };
  
    _proto.post = function post(path, data, skipPostResponse) {
      var _this5 = this;
  
      return new Promise(function (resolve, reject) {
        _this5.preflightAndHeaders(path).then(function (headers) {
          fetch(_this5._getUrl(path), {
            method: 'post',
            headers: headers,
            credentials: 'same-origin',
            body: JSON.stringify(data)
          }).then(_this5._getPostResponseFunc(skipPostResponse)).then(function (res) {
            return _this5._json(res).then(resolve);
          }).catch(function (err) {
            err = err.isAuthError ? err : new Error("Could not post " + _this5._getUrl(path) + ". " + err);
            reject(err);
          });
        }).catch(reject);
      });
    };
  
    _proto.delete = function _delete(path, data, skipPostResponse) {
      var _this6 = this;
  
      return new Promise(function (resolve, reject) {
        _this6.preflightAndHeaders(path).then(function (headers) {
          fetch(_this6.hostname + "/" + path, {
            method: 'delete',
            headers: headers,
            credentials: 'same-origin',
            body: data ? JSON.stringify(data) : null
          }).then(_this6._getPostResponseFunc(skipPostResponse)).then(function (res) {
            return _this6._json(res).then(resolve);
          }).catch(function (err) {
            err = err.isAuthError ? err : new Error("Could not delete " + _this6._getUrl(path) + ". " + err);
            reject(err);
          });
        }).catch(reject);
      });
    };
  
    _createClass(RequestClient, [{
      key: "hostname",
      get: function get() {
        var _this$uppy$getState = this.uppy.getState(),
            companion = _this$uppy$getState.companion;
  
        var host = this.opts.companionUrl;
        return stripSlash(companion && companion[host] ? companion[host] : host);
      }
    }, {
      key: "defaultHeaders",
      get: function get() {
        return {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'Uppy-Versions': "@uppy/companion-client=" + RequestClient.VERSION
        };
      }
    }]);
  
    return RequestClient;
  }(), _class.VERSION = "1.4.1", _temp);
  },{"./AuthError":2}],5:[function(require,module,exports){
  var ee = require('namespace-emitter');
  
  module.exports =
  /*#__PURE__*/
  function () {
    function UppySocket(opts) {
      this.opts = opts;
      this._queued = [];
      this.isOpen = false;
      this.emitter = ee();
      this._handleMessage = this._handleMessage.bind(this);
      this.close = this.close.bind(this);
      this.emit = this.emit.bind(this);
      this.on = this.on.bind(this);
      this.once = this.once.bind(this);
      this.send = this.send.bind(this);
  
      if (!opts || opts.autoOpen !== false) {
        this.open();
      }
    }
  
    var _proto = UppySocket.prototype;
  
    _proto.open = function open() {
      var _this = this;
  
      this.socket = new WebSocket(this.opts.target);
  
      this.socket.onopen = function (e) {
        _this.isOpen = true;
  
        while (_this._queued.length > 0 && _this.isOpen) {
          var first = _this._queued[0];
  
          _this.send(first.action, first.payload);
  
          _this._queued = _this._queued.slice(1);
        }
      };
  
      this.socket.onclose = function (e) {
        _this.isOpen = false;
      };
  
      this.socket.onmessage = this._handleMessage;
    };
  
    _proto.close = function close() {
      if (this.socket) {
        this.socket.close();
      }
    };
  
    _proto.send = function send(action, payload) {
      // attach uuid
      if (!this.isOpen) {
        this._queued.push({
          action: action,
          payload: payload
        });
  
        return;
      }
  
      this.socket.send(JSON.stringify({
        action: action,
        payload: payload
      }));
    };
  
    _proto.on = function on(action, handler) {
      this.emitter.on(action, handler);
    };
  
    _proto.emit = function emit(action, payload) {
      this.emitter.emit(action, payload);
    };
  
    _proto.once = function once(action, handler) {
      this.emitter.once(action, handler);
    };
  
    _proto._handleMessage = function _handleMessage(e) {
      try {
        var message = JSON.parse(e.data);
        this.emit(message.action, message.payload);
      } catch (err) {
        console.log(err);
      }
    };
  
    return UppySocket;
  }();
  },{"namespace-emitter":36}],6:[function(require,module,exports){
  'use strict';
  /**
   * Manages communications with Companion
   */
  
  var RequestClient = require('./RequestClient');
  
  var Provider = require('./Provider');
  
  var Socket = require('./Socket');
  
  module.exports = {
    RequestClient: RequestClient,
    Provider: Provider,
    Socket: Socket
  };
  },{"./Provider":3,"./RequestClient":4,"./Socket":5}],7:[function(require,module,exports){
  'use strict';
  /**
   * This module serves as an Async wrapper for LocalStorage
   */
  
  module.exports.setItem = function (key, value) {
    return new Promise(function (resolve) {
      localStorage.setItem(key, value);
      resolve();
    });
  };
  
  module.exports.getItem = function (key) {
    return Promise.resolve(localStorage.getItem(key));
  };
  
  module.exports.removeItem = function (key) {
    return new Promise(function (resolve) {
      localStorage.removeItem(key);
      resolve();
    });
  };
  },{}],8:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  var preact = require('preact');
  
  var findDOMElement = require('@uppy/utils/lib/findDOMElement');
  /**
   * Defer a frequent call to the microtask queue.
   */
  
  
  function debounce(fn) {
    var calling = null;
    var latestArgs = null;
    return function () {
      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }
  
      latestArgs = args;
  
      if (!calling) {
        calling = Promise.resolve().then(function () {
          calling = null; // At this point `args` may be different from the most
          // recent state, if multiple calls happened since this task
          // was queued. So we use the `latestArgs`, which definitely
          // is the most recent call.
  
          return fn.apply(void 0, latestArgs);
        });
      }
  
      return calling;
    };
  }
  /**
   * Boilerplate that all Plugins share - and should not be used
   * directly. It also shows which methods final plugins should implement/override,
   * this deciding on structure.
   *
   * @param {object} main Uppy core object
   * @param {object} object with plugin options
   * @returns {Array|string} files or success/fail message
   */
  
  
  module.exports =
  /*#__PURE__*/
  function () {
    function Plugin(uppy, opts) {
      this.uppy = uppy;
      this.opts = opts || {};
      this.update = this.update.bind(this);
      this.mount = this.mount.bind(this);
      this.install = this.install.bind(this);
      this.uninstall = this.uninstall.bind(this);
    }
  
    var _proto = Plugin.prototype;
  
    _proto.getPluginState = function getPluginState() {
      var _this$uppy$getState = this.uppy.getState(),
          plugins = _this$uppy$getState.plugins;
  
      return plugins[this.id] || {};
    };
  
    _proto.setPluginState = function setPluginState(update) {
      var _extends2;
  
      var _this$uppy$getState2 = this.uppy.getState(),
          plugins = _this$uppy$getState2.plugins;
  
      this.uppy.setState({
        plugins: _extends({}, plugins, (_extends2 = {}, _extends2[this.id] = _extends({}, plugins[this.id], {}, update), _extends2))
      });
    };
  
    _proto.update = function update(state) {
      if (typeof this.el === 'undefined') {
        return;
      }
  
      if (this._updateUI) {
        this._updateUI(state);
      }
    } // Called after every state update, after everything's mounted. Debounced.
    ;
  
    _proto.afterUpdate = function afterUpdate() {}
    /**
     * Called when plugin is mounted, whether in DOM or into another plugin.
     * Needed because sometimes plugins are mounted separately/after `install`,
     * so this.el and this.parent might not be available in `install`.
     * This is the case with @uppy/react plugins, for example.
     */
    ;
  
    _proto.onMount = function onMount() {}
    /**
     * Check if supplied `target` is a DOM element or an `object`.
     * If it’s an object — target is a plugin, and we search `plugins`
     * for a plugin with same name and return its target.
     *
     * @param {string|object} target
     *
     */
    ;
  
    _proto.mount = function mount(target, plugin) {
      var _this = this;
  
      var callerPluginName = plugin.id;
      var targetElement = findDOMElement(target);
  
      if (targetElement) {
        this.isTargetDOMEl = true; // API for plugins that require a synchronous rerender.
  
        this.rerender = function (state) {
          // plugin could be removed, but this.rerender is debounced below,
          // so it could still be called even after uppy.removePlugin or uppy.close
          // hence the check
          if (!_this.uppy.getPlugin(_this.id)) return;
          _this.el = preact.render(_this.render(state), targetElement, _this.el);
  
          _this.afterUpdate();
        };
  
        this._updateUI = debounce(this.rerender);
        this.uppy.log("Installing " + callerPluginName + " to a DOM element '" + target + "'"); // clear everything inside the target container
  
        if (this.opts.replaceTargetContent) {
          targetElement.innerHTML = '';
        }
  
        this.el = preact.render(this.render(this.uppy.getState()), targetElement);
        this.onMount();
        return this.el;
      }
  
      var targetPlugin;
  
      if (typeof target === 'object' && target instanceof Plugin) {
        // Targeting a plugin *instance*
        targetPlugin = target;
      } else if (typeof target === 'function') {
        // Targeting a plugin type
        var Target = target; // Find the target plugin instance.
  
        this.uppy.iteratePlugins(function (plugin) {
          if (plugin instanceof Target) {
            targetPlugin = plugin;
            return false;
          }
        });
      }
  
      if (targetPlugin) {
        this.uppy.log("Installing " + callerPluginName + " to " + targetPlugin.id);
        this.parent = targetPlugin;
        this.el = targetPlugin.addTarget(plugin);
        this.onMount();
        return this.el;
      }
  
      this.uppy.log("Not installing " + callerPluginName);
      throw new Error("Invalid target option given to " + callerPluginName + ". Please make sure that the element\n      exists on the page, or that the plugin you are targeting has been installed. Check that the <script> tag initializing Uppy\n      comes at the bottom of the page, before the closing </body> tag (see https://github.com/transloadit/uppy/issues/1042).");
    };
  
    _proto.render = function render(state) {
      throw new Error('Extend the render method to add your plugin to a DOM element');
    };
  
    _proto.addTarget = function addTarget(plugin) {
      throw new Error('Extend the addTarget method to add your plugin to another plugin\'s target');
    };
  
    _proto.unmount = function unmount() {
      if (this.isTargetDOMEl && this.el && this.el.parentNode) {
        this.el.parentNode.removeChild(this.el);
      }
    };
  
    _proto.install = function install() {};
  
    _proto.uninstall = function uninstall() {
      this.unmount();
    };
  
    return Plugin;
  }();
  },{"@uppy/utils/lib/findDOMElement":18,"preact":37}],9:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
  
  function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }
  
  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
  
  function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }
  
  function isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }
  
  function _construct(Parent, args, Class) { if (isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }
  
  function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }
  
  function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }
  
  function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }
  
  var Translator = require('@uppy/utils/lib/Translator');
  
  var ee = require('namespace-emitter');
  
  var cuid = require('cuid');
  
  var throttle = require('lodash.throttle');
  
  var prettyBytes = require('@uppy/utils/lib/prettyBytes');
  
  var match = require('mime-match');
  
  var DefaultStore = require('@uppy/store-default');
  
  var getFileType = require('@uppy/utils/lib/getFileType');
  
  var getFileNameAndExtension = require('@uppy/utils/lib/getFileNameAndExtension');
  
  var generateFileID = require('@uppy/utils/lib/generateFileID');
  
  var supportsUploadProgress = require('./supportsUploadProgress');
  
  var _require = require('./loggers'),
      nullLogger = _require.nullLogger,
      debugLogger = _require.debugLogger;
  
  var Plugin = require('./Plugin'); // Exported from here.
  
  
  var RestrictionError =
  /*#__PURE__*/
  function (_Error) {
    _inheritsLoose(RestrictionError, _Error);
  
    function RestrictionError() {
      var _this;
  
      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }
  
      _this = _Error.call.apply(_Error, [this].concat(args)) || this;
      _this.isRestriction = true;
      return _this;
    }
  
    return RestrictionError;
  }(_wrapNativeSuper(Error));
  /**
   * Uppy Core module.
   * Manages plugins, state updates, acts as an event bus,
   * adds/removes files and metadata.
   */
  
  
  var Uppy =
  /*#__PURE__*/
  function () {
    /**
     * Instantiate Uppy
     *
     * @param {object} opts — Uppy options
     */
    function Uppy(opts) {
      var _this2 = this;
  
      this.defaultLocale = {
        strings: {
          youCanOnlyUploadX: {
            0: 'You can only upload %{smart_count} file',
            1: 'You can only upload %{smart_count} files',
            2: 'You can only upload %{smart_count} files'
          },
          youHaveToAtLeastSelectX: {
            0: 'You have to select at least %{smart_count} file',
            1: 'You have to select at least %{smart_count} files',
            2: 'You have to select at least %{smart_count} files'
          },
          exceedsSize: 'This file exceeds maximum allowed size of',
          youCanOnlyUploadFileTypes: 'You can only upload: %{types}',
          companionError: 'Connection with Companion failed',
          companionAuthError: 'Authorization required',
          companionUnauthorizeHint: 'To unauthorize to your %{provider} account, please go to %{url}',
          failedToUpload: 'Failed to upload %{file}',
          noInternetConnection: 'No Internet connection',
          connectedToInternet: 'Connected to the Internet',
          // Strings for remote providers
          noFilesFound: 'You have no files or folders here',
          selectX: {
            0: 'Select %{smart_count}',
            1: 'Select %{smart_count}',
            2: 'Select %{smart_count}'
          },
          selectAllFilesFromFolderNamed: 'Select all files from folder %{name}',
          unselectAllFilesFromFolderNamed: 'Unselect all files from folder %{name}',
          selectFileNamed: 'Select file %{name}',
          unselectFileNamed: 'Unselect file %{name}',
          openFolderNamed: 'Open folder %{name}',
          cancel: 'Cancel',
          logOut: 'Log out',
          filter: 'Filter',
          resetFilter: 'Reset filter',
          loading: 'Loading...',
          authenticateWithTitle: 'Please authenticate with %{pluginName} to select files',
          authenticateWith: 'Connect to %{pluginName}',
          emptyFolderAdded: 'No files were added from empty folder',
          folderAdded: {
            0: 'Added %{smart_count} file from %{folder}',
            1: 'Added %{smart_count} files from %{folder}',
            2: 'Added %{smart_count} files from %{folder}'
          }
        } // set default options
  
      };
      var defaultOptions = {
        id: 'uppy',
        autoProceed: false,
        allowMultipleUploads: true,
        debug: false,
        restrictions: {
          maxFileSize: null,
          maxNumberOfFiles: null,
          minNumberOfFiles: null,
          allowedFileTypes: null
        },
        meta: {},
        onBeforeFileAdded: function onBeforeFileAdded(currentFile, files) {
          return currentFile;
        },
        onBeforeUpload: function onBeforeUpload(files) {
          return files;
        },
        store: DefaultStore(),
        logger: nullLogger // Merge default options with the ones set by user
  
      };
      this.opts = _extends({}, defaultOptions, opts);
      this.opts.restrictions = _extends({}, defaultOptions.restrictions, this.opts.restrictions); // Support debug: true for backwards-compatability, unless logger is set in opts
      // opts instead of this.opts to avoid comparing objects — we set logger: nullLogger in defaultOptions
  
      if (opts && opts.logger && opts.debug) {
        this.log('You are using a custom `logger`, but also set `debug: true`, which uses built-in logger to output logs to console. Ignoring `debug: true` and using your custom `logger`.', 'warning');
      } else if (opts && opts.debug) {
        this.opts.logger = debugLogger;
      }
  
      this.log("Using Core v" + this.constructor.VERSION);
  
      if (this.opts.restrictions.allowedFileTypes && this.opts.restrictions.allowedFileTypes !== null && !Array.isArray(this.opts.restrictions.allowedFileTypes)) {
        throw new TypeError('`restrictions.allowedFileTypes` must be an array');
      } // i18n
  
  
      this.translator = new Translator([this.defaultLocale, this.opts.locale]);
      this.locale = this.translator.locale;
      this.i18n = this.translator.translate.bind(this.translator);
      this.i18nArray = this.translator.translateArray.bind(this.translator); // Container for different types of plugins
  
      this.plugins = {};
      this.getState = this.getState.bind(this);
      this.getPlugin = this.getPlugin.bind(this);
      this.setFileMeta = this.setFileMeta.bind(this);
      this.setFileState = this.setFileState.bind(this);
      this.log = this.log.bind(this);
      this.info = this.info.bind(this);
      this.hideInfo = this.hideInfo.bind(this);
      this.addFile = this.addFile.bind(this);
      this.removeFile = this.removeFile.bind(this);
      this.pauseResume = this.pauseResume.bind(this); // ___Why throttle at 500ms?
      //    - We must throttle at >250ms for superfocus in Dashboard to work well (because animation takes 0.25s, and we want to wait for all animations to be over before refocusing).
      //    [Practical Check]: if thottle is at 100ms, then if you are uploading a file, and click 'ADD MORE FILES', - focus won't activate in Firefox.
      //    - We must throttle at around >500ms to avoid performance lags.
      //    [Practical Check] Firefox, try to upload a big file for a prolonged period of time. Laptop will start to heat up.
  
      this._calculateProgress = throttle(this._calculateProgress.bind(this), 500, {
        leading: true,
        trailing: true
      });
      this.updateOnlineStatus = this.updateOnlineStatus.bind(this);
      this.resetProgress = this.resetProgress.bind(this);
      this.pauseAll = this.pauseAll.bind(this);
      this.resumeAll = this.resumeAll.bind(this);
      this.retryAll = this.retryAll.bind(this);
      this.cancelAll = this.cancelAll.bind(this);
      this.retryUpload = this.retryUpload.bind(this);
      this.upload = this.upload.bind(this);
      this.emitter = ee();
      this.on = this.on.bind(this);
      this.off = this.off.bind(this);
      this.once = this.emitter.once.bind(this.emitter);
      this.emit = this.emitter.emit.bind(this.emitter);
      this.preProcessors = [];
      this.uploaders = [];
      this.postProcessors = [];
      this.store = this.opts.store;
      this.setState({
        plugins: {},
        files: {},
        currentUploads: {},
        allowNewUpload: true,
        capabilities: {
          uploadProgress: supportsUploadProgress(),
          individualCancellation: true,
          resumableUploads: false
        },
        totalProgress: 0,
        meta: _extends({}, this.opts.meta),
        info: {
          isHidden: true,
          type: 'info',
          message: ''
        }
      });
      this._storeUnsubscribe = this.store.subscribe(function (prevState, nextState, patch) {
        _this2.emit('state-update', prevState, nextState, patch);
  
        _this2.updateAll(nextState);
      }); // Exposing uppy object on window for debugging and testing
  
      if (this.opts.debug && typeof window !== 'undefined') {
        window[this.opts.id] = this;
      }
  
      this._addListeners();
    }
  
    var _proto = Uppy.prototype;
  
    _proto.on = function on(event, callback) {
      this.emitter.on(event, callback);
      return this;
    };
  
    _proto.off = function off(event, callback) {
      this.emitter.off(event, callback);
      return this;
    }
    /**
     * Iterate on all plugins and run `update` on them.
     * Called each time state changes.
     *
     */
    ;
  
    _proto.updateAll = function updateAll(state) {
      this.iteratePlugins(function (plugin) {
        plugin.update(state);
      });
    }
    /**
     * Updates state with a patch
     *
     * @param {object} patch {foo: 'bar'}
     */
    ;
  
    _proto.setState = function setState(patch) {
      this.store.setState(patch);
    }
    /**
     * Returns current state.
     *
     * @returns {object}
     */
    ;
  
    _proto.getState = function getState() {
      return this.store.getState();
    }
    /**
     * Back compat for when uppy.state is used instead of uppy.getState().
     */
    ;
  
    /**
     * Shorthand to set state for a specific file.
     */
    _proto.setFileState = function setFileState(fileID, state) {
      var _extends2;
  
      if (!this.getState().files[fileID]) {
        throw new Error("Can\u2019t set state for " + fileID + " (the file could have been removed)");
      }
  
      this.setState({
        files: _extends({}, this.getState().files, (_extends2 = {}, _extends2[fileID] = _extends({}, this.getState().files[fileID], state), _extends2))
      });
    };
  
    _proto.resetProgress = function resetProgress() {
      var defaultProgress = {
        percentage: 0,
        bytesUploaded: 0,
        uploadComplete: false,
        uploadStarted: null
      };
  
      var files = _extends({}, this.getState().files);
  
      var updatedFiles = {};
      Object.keys(files).forEach(function (fileID) {
        var updatedFile = _extends({}, files[fileID]);
  
        updatedFile.progress = _extends({}, updatedFile.progress, defaultProgress);
        updatedFiles[fileID] = updatedFile;
      });
      this.setState({
        files: updatedFiles,
        totalProgress: 0
      }); // TODO Document on the website
  
      this.emit('reset-progress');
    };
  
    _proto.addPreProcessor = function addPreProcessor(fn) {
      this.preProcessors.push(fn);
    };
  
    _proto.removePreProcessor = function removePreProcessor(fn) {
      var i = this.preProcessors.indexOf(fn);
  
      if (i !== -1) {
        this.preProcessors.splice(i, 1);
      }
    };
  
    _proto.addPostProcessor = function addPostProcessor(fn) {
      this.postProcessors.push(fn);
    };
  
    _proto.removePostProcessor = function removePostProcessor(fn) {
      var i = this.postProcessors.indexOf(fn);
  
      if (i !== -1) {
        this.postProcessors.splice(i, 1);
      }
    };
  
    _proto.addUploader = function addUploader(fn) {
      this.uploaders.push(fn);
    };
  
    _proto.removeUploader = function removeUploader(fn) {
      var i = this.uploaders.indexOf(fn);
  
      if (i !== -1) {
        this.uploaders.splice(i, 1);
      }
    };
  
    _proto.setMeta = function setMeta(data) {
      var updatedMeta = _extends({}, this.getState().meta, data);
  
      var updatedFiles = _extends({}, this.getState().files);
  
      Object.keys(updatedFiles).forEach(function (fileID) {
        updatedFiles[fileID] = _extends({}, updatedFiles[fileID], {
          meta: _extends({}, updatedFiles[fileID].meta, data)
        });
      });
      this.log('Adding metadata:');
      this.log(data);
      this.setState({
        meta: updatedMeta,
        files: updatedFiles
      });
    };
  
    _proto.setFileMeta = function setFileMeta(fileID, data) {
      var updatedFiles = _extends({}, this.getState().files);
  
      if (!updatedFiles[fileID]) {
        this.log('Was trying to set metadata for a file that has been removed: ', fileID);
        return;
      }
  
      var newMeta = _extends({}, updatedFiles[fileID].meta, data);
  
      updatedFiles[fileID] = _extends({}, updatedFiles[fileID], {
        meta: newMeta
      });
      this.setState({
        files: updatedFiles
      });
    }
    /**
     * Get a file object.
     *
     * @param {string} fileID The ID of the file object to return.
     */
    ;
  
    _proto.getFile = function getFile(fileID) {
      return this.getState().files[fileID];
    }
    /**
     * Get all files in an array.
     */
    ;
  
    _proto.getFiles = function getFiles() {
      var _this$getState = this.getState(),
          files = _this$getState.files;
  
      return Object.keys(files).map(function (fileID) {
        return files[fileID];
      });
    }
    /**
     * Check if minNumberOfFiles restriction is reached before uploading.
     *
     * @private
     */
    ;
  
    _proto._checkMinNumberOfFiles = function _checkMinNumberOfFiles(files) {
      var minNumberOfFiles = this.opts.restrictions.minNumberOfFiles;
  
      if (Object.keys(files).length < minNumberOfFiles) {
        throw new RestrictionError("" + this.i18n('youHaveToAtLeastSelectX', {
          smart_count: minNumberOfFiles
        }));
      }
    }
    /**
     * Check if file passes a set of restrictions set in options: maxFileSize,
     * maxNumberOfFiles and allowedFileTypes.
     *
     * @param {object} file object to check
     * @private
     */
    ;
  
    _proto._checkRestrictions = function _checkRestrictions(file) {
      var _this$opts$restrictio = this.opts.restrictions,
          maxFileSize = _this$opts$restrictio.maxFileSize,
          maxNumberOfFiles = _this$opts$restrictio.maxNumberOfFiles,
          allowedFileTypes = _this$opts$restrictio.allowedFileTypes;
  
      if (maxNumberOfFiles) {
        if (Object.keys(this.getState().files).length + 1 > maxNumberOfFiles) {
          throw new RestrictionError("" + this.i18n('youCanOnlyUploadX', {
            smart_count: maxNumberOfFiles
          }));
        }
      }
  
      if (allowedFileTypes) {
        var isCorrectFileType = allowedFileTypes.some(function (type) {
          // is this is a mime-type
          if (type.indexOf('/') > -1) {
            if (!file.type) return false;
            return match(file.type, type);
          } // otherwise this is likely an extension
  
  
          if (type[0] === '.') {
            return file.extension.toLowerCase() === type.substr(1).toLowerCase();
          }
  
          return false;
        });
  
        if (!isCorrectFileType) {
          var allowedFileTypesString = allowedFileTypes.join(', ');
          throw new RestrictionError(this.i18n('youCanOnlyUploadFileTypes', {
            types: allowedFileTypesString
          }));
        }
      } // We can't check maxFileSize if the size is unknown.
  
  
      if (maxFileSize && file.data.size != null) {
        if (file.data.size > maxFileSize) {
          throw new RestrictionError(this.i18n('exceedsSize') + " " + prettyBytes(maxFileSize));
        }
      }
    };
  
    _proto._showOrLogErrorAndThrow = function _showOrLogErrorAndThrow(err, _temp) {
      var _ref = _temp === void 0 ? {} : _temp,
          _ref$showInformer = _ref.showInformer,
          showInformer = _ref$showInformer === void 0 ? true : _ref$showInformer,
          _ref$file = _ref.file,
          file = _ref$file === void 0 ? null : _ref$file;
  
      var message = typeof err === 'object' ? err.message : err;
      var details = typeof err === 'object' && err.details ? err.details : ''; // Restriction errors should be logged, but not as errors,
      // as they are expected and shown in the UI.
  
      if (err.isRestriction) {
        this.log(message + " " + details);
        this.emit('restriction-failed', file, err);
      } else {
        this.log(message + " " + details, 'error');
      } // Sometimes informer has to be shown manually by the developer,
      // for example, in `onBeforeFileAdded`.
  
  
      if (showInformer) {
        this.info({
          message: message,
          details: details
        }, 'error', 5000);
      }
  
      throw typeof err === 'object' ? err : new Error(err);
    }
    /**
     * Add a new file to `state.files`. This will run `onBeforeFileAdded`,
     * try to guess file type in a clever way, check file against restrictions,
     * and start an upload if `autoProceed === true`.
     *
     * @param {object} file object to add
     * @returns {string} id for the added file
     */
    ;
  
    _proto.addFile = function addFile(file) {
      var _extends3,
          _this3 = this;
  
      var _this$getState2 = this.getState(),
          files = _this$getState2.files,
          allowNewUpload = _this$getState2.allowNewUpload;
  
      if (allowNewUpload === false) {
        this._showOrLogErrorAndThrow(new RestrictionError('Cannot add new files: already uploading.'), {
          file: file
        });
      }
  
      var fileType = getFileType(file);
      file.type = fileType;
      var onBeforeFileAddedResult = this.opts.onBeforeFileAdded(file, files);
  
      if (onBeforeFileAddedResult === false) {
        // Don’t show UI info for this error, as it should be done by the developer
        this._showOrLogErrorAndThrow(new RestrictionError('Cannot add the file because onBeforeFileAdded returned false.'), {
          showInformer: false,
          file: file
        });
      }
  
      if (typeof onBeforeFileAddedResult === 'object' && onBeforeFileAddedResult) {
        file = onBeforeFileAddedResult;
      }
  
      var fileName;
  
      if (file.name) {
        fileName = file.name;
      } else if (fileType.split('/')[0] === 'image') {
        fileName = fileType.split('/')[0] + '.' + fileType.split('/')[1];
      } else {
        fileName = 'noname';
      }
  
      var fileExtension = getFileNameAndExtension(fileName).extension;
      var isRemote = file.isRemote || false;
      var fileID = generateFileID(file);
  
      if (files[fileID]) {
        this._showOrLogErrorAndThrow(new RestrictionError("Cannot add the duplicate file '" + fileName + "', it already exists."), {
          file: file
        });
      }
  
      var meta = file.meta || {};
      meta.name = fileName;
      meta.type = fileType; // `null` means the size is unknown.
  
      var size = isFinite(file.data.size) ? file.data.size : null;
      var newFile = {
        source: file.source || '',
        id: fileID,
        name: fileName,
        extension: fileExtension || '',
        meta: _extends({}, this.getState().meta, meta),
        type: fileType,
        data: file.data,
        progress: {
          percentage: 0,
          bytesUploaded: 0,
          bytesTotal: size,
          uploadComplete: false,
          uploadStarted: null
        },
        size: size,
        isRemote: isRemote,
        remote: file.remote || '',
        preview: file.preview
      };
  
      try {
        this._checkRestrictions(newFile);
      } catch (err) {
        this._showOrLogErrorAndThrow(err, {
          file: newFile
        });
      }
  
      this.setState({
        files: _extends({}, files, (_extends3 = {}, _extends3[fileID] = newFile, _extends3))
      });
      this.emit('file-added', newFile);
      this.log("Added file: " + fileName + ", " + fileID + ", mime type: " + fileType);
  
      if (this.opts.autoProceed && !this.scheduledAutoProceed) {
        this.scheduledAutoProceed = setTimeout(function () {
          _this3.scheduledAutoProceed = null;
  
          _this3.upload().catch(function (err) {
            if (!err.isRestriction) {
              _this3.log(err.stack || err.message || err);
            }
          });
        }, 4);
      }
  
      return fileID;
    };
  
    _proto.removeFile = function removeFile(fileID) {
      var _this4 = this;
  
      var _this$getState3 = this.getState(),
          files = _this$getState3.files,
          currentUploads = _this$getState3.currentUploads;
  
      var updatedFiles = _extends({}, files);
  
      var removedFile = updatedFiles[fileID];
      delete updatedFiles[fileID]; // Remove this file from its `currentUpload`.
  
      var updatedUploads = _extends({}, currentUploads);
  
      var removeUploads = [];
      Object.keys(updatedUploads).forEach(function (uploadID) {
        var newFileIDs = currentUploads[uploadID].fileIDs.filter(function (uploadFileID) {
          return uploadFileID !== fileID;
        }); // Remove the upload if no files are associated with it anymore.
  
        if (newFileIDs.length === 0) {
          removeUploads.push(uploadID);
          return;
        }
  
        updatedUploads[uploadID] = _extends({}, currentUploads[uploadID], {
          fileIDs: newFileIDs
        });
      });
      this.setState(_extends({
        currentUploads: updatedUploads,
        files: updatedFiles
      }, // If this is the last file we just removed - allow new uploads!
      Object.keys(updatedFiles).length === 0 && {
        allowNewUpload: true
      }));
      removeUploads.forEach(function (uploadID) {
        _this4._removeUpload(uploadID);
      });
  
      this._calculateTotalProgress();
  
      this.emit('file-removed', removedFile);
      this.log("File removed: " + removedFile.id);
    };
  
    _proto.pauseResume = function pauseResume(fileID) {
      if (!this.getState().capabilities.resumableUploads || this.getFile(fileID).uploadComplete) {
        return;
      }
  
      var wasPaused = this.getFile(fileID).isPaused || false;
      var isPaused = !wasPaused;
      this.setFileState(fileID, {
        isPaused: isPaused
      });
      this.emit('upload-pause', fileID, isPaused);
      return isPaused;
    };
  
    _proto.pauseAll = function pauseAll() {
      var updatedFiles = _extends({}, this.getState().files);
  
      var inProgressUpdatedFiles = Object.keys(updatedFiles).filter(function (file) {
        return !updatedFiles[file].progress.uploadComplete && updatedFiles[file].progress.uploadStarted;
      });
      inProgressUpdatedFiles.forEach(function (file) {
        var updatedFile = _extends({}, updatedFiles[file], {
          isPaused: true
        });
  
        updatedFiles[file] = updatedFile;
      });
      this.setState({
        files: updatedFiles
      });
      this.emit('pause-all');
    };
  
    _proto.resumeAll = function resumeAll() {
      var updatedFiles = _extends({}, this.getState().files);
  
      var inProgressUpdatedFiles = Object.keys(updatedFiles).filter(function (file) {
        return !updatedFiles[file].progress.uploadComplete && updatedFiles[file].progress.uploadStarted;
      });
      inProgressUpdatedFiles.forEach(function (file) {
        var updatedFile = _extends({}, updatedFiles[file], {
          isPaused: false,
          error: null
        });
  
        updatedFiles[file] = updatedFile;
      });
      this.setState({
        files: updatedFiles
      });
      this.emit('resume-all');
    };
  
    _proto.retryAll = function retryAll() {
      var updatedFiles = _extends({}, this.getState().files);
  
      var filesToRetry = Object.keys(updatedFiles).filter(function (file) {
        return updatedFiles[file].error;
      });
      filesToRetry.forEach(function (file) {
        var updatedFile = _extends({}, updatedFiles[file], {
          isPaused: false,
          error: null
        });
  
        updatedFiles[file] = updatedFile;
      });
      this.setState({
        files: updatedFiles,
        error: null
      });
      this.emit('retry-all', filesToRetry);
  
      var uploadID = this._createUpload(filesToRetry);
  
      return this._runUpload(uploadID);
    };
  
    _proto.cancelAll = function cancelAll() {
      var _this5 = this;
  
      this.emit('cancel-all');
      var files = Object.keys(this.getState().files);
      files.forEach(function (fileID) {
        _this5.removeFile(fileID);
      });
      this.setState({
        totalProgress: 0,
        error: null
      });
    };
  
    _proto.retryUpload = function retryUpload(fileID) {
      this.setFileState(fileID, {
        error: null,
        isPaused: false
      });
      this.emit('upload-retry', fileID);
  
      var uploadID = this._createUpload([fileID]);
  
      return this._runUpload(uploadID);
    };
  
    _proto.reset = function reset() {
      this.cancelAll();
    };
  
    _proto._calculateProgress = function _calculateProgress(file, data) {
      if (!this.getFile(file.id)) {
        this.log("Not setting progress for a file that has been removed: " + file.id);
        return;
      } // bytesTotal may be null or zero; in that case we can't divide by it
  
  
      var canHavePercentage = isFinite(data.bytesTotal) && data.bytesTotal > 0;
      this.setFileState(file.id, {
        progress: _extends({}, this.getFile(file.id).progress, {
          bytesUploaded: data.bytesUploaded,
          bytesTotal: data.bytesTotal,
          percentage: canHavePercentage // TODO(goto-bus-stop) flooring this should probably be the choice of the UI?
          // we get more accurate calculations if we don't round this at all.
          ? Math.round(data.bytesUploaded / data.bytesTotal * 100) : 0
        })
      });
  
      this._calculateTotalProgress();
    };
  
    _proto._calculateTotalProgress = function _calculateTotalProgress() {
      // calculate total progress, using the number of files currently uploading,
      // multiplied by 100 and the summ of individual progress of each file
      var files = this.getFiles();
      var inProgress = files.filter(function (file) {
        return file.progress.uploadStarted;
      });
  
      if (inProgress.length === 0) {
        this.emit('progress', 0);
        this.setState({
          totalProgress: 0
        });
        return;
      }
  
      var sizedFiles = inProgress.filter(function (file) {
        return file.progress.bytesTotal != null;
      });
      var unsizedFiles = inProgress.filter(function (file) {
        return file.progress.bytesTotal == null;
      });
  
      if (sizedFiles.length === 0) {
        var progressMax = inProgress.length * 100;
        var currentProgress = unsizedFiles.reduce(function (acc, file) {
          return acc + file.progress.percentage;
        }, 0);
  
        var _totalProgress = Math.round(currentProgress / progressMax * 100);
  
        this.setState({
          totalProgress: _totalProgress
        });
        return;
      }
  
      var totalSize = sizedFiles.reduce(function (acc, file) {
        return acc + file.progress.bytesTotal;
      }, 0);
      var averageSize = totalSize / sizedFiles.length;
      totalSize += averageSize * unsizedFiles.length;
      var uploadedSize = 0;
      sizedFiles.forEach(function (file) {
        uploadedSize += file.progress.bytesUploaded;
      });
      unsizedFiles.forEach(function (file) {
        uploadedSize += averageSize * (file.progress.percentage || 0) / 100;
      });
      var totalProgress = totalSize === 0 ? 0 : Math.round(uploadedSize / totalSize * 100); // hot fix, because:
      // uploadedSize ended up larger than totalSize, resulting in 1325% total
  
      if (totalProgress > 100) {
        totalProgress = 100;
      }
  
      this.setState({
        totalProgress: totalProgress
      });
      this.emit('progress', totalProgress);
    }
    /**
     * Registers listeners for all global actions, like:
     * `error`, `file-removed`, `upload-progress`
     */
    ;
  
    _proto._addListeners = function _addListeners() {
      var _this6 = this;
  
      this.on('error', function (error) {
        _this6.setState({
          error: error.message || 'Unknown error'
        });
      });
      this.on('upload-error', function (file, error, response) {
        _this6.setFileState(file.id, {
          error: error.message || 'Unknown error',
          response: response
        });
  
        _this6.setState({
          error: error.message
        });
  
        var message = _this6.i18n('failedToUpload', {
          file: file.name
        });
  
        if (typeof error === 'object' && error.message) {
          message = {
            message: message,
            details: error.message
          };
        }
  
        _this6.info(message, 'error', 5000);
      });
      this.on('upload', function () {
        _this6.setState({
          error: null
        });
      });
      this.on('upload-started', function (file, upload) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);
  
          return;
        }
  
        _this6.setFileState(file.id, {
          progress: {
            uploadStarted: Date.now(),
            uploadComplete: false,
            percentage: 0,
            bytesUploaded: 0,
            bytesTotal: file.size
          }
        });
      });
      this.on('upload-progress', this._calculateProgress);
      this.on('upload-success', function (file, uploadResp) {
        var currentProgress = _this6.getFile(file.id).progress;
  
        _this6.setFileState(file.id, {
          progress: _extends({}, currentProgress, {
            uploadComplete: true,
            percentage: 100,
            bytesUploaded: currentProgress.bytesTotal
          }),
          response: uploadResp,
          uploadURL: uploadResp.uploadURL,
          isPaused: false
        });
  
        _this6._calculateTotalProgress();
      });
      this.on('preprocess-progress', function (file, progress) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);
  
          return;
        }
  
        _this6.setFileState(file.id, {
          progress: _extends({}, _this6.getFile(file.id).progress, {
            preprocess: progress
          })
        });
      });
      this.on('preprocess-complete', function (file) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);
  
          return;
        }
  
        var files = _extends({}, _this6.getState().files);
  
        files[file.id] = _extends({}, files[file.id], {
          progress: _extends({}, files[file.id].progress)
        });
        delete files[file.id].progress.preprocess;
  
        _this6.setState({
          files: files
        });
      });
      this.on('postprocess-progress', function (file, progress) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);
  
          return;
        }
  
        _this6.setFileState(file.id, {
          progress: _extends({}, _this6.getState().files[file.id].progress, {
            postprocess: progress
          })
        });
      });
      this.on('postprocess-complete', function (file) {
        if (!_this6.getFile(file.id)) {
          _this6.log("Not setting progress for a file that has been removed: " + file.id);
  
          return;
        }
  
        var files = _extends({}, _this6.getState().files);
  
        files[file.id] = _extends({}, files[file.id], {
          progress: _extends({}, files[file.id].progress)
        });
        delete files[file.id].progress.postprocess; // TODO should we set some kind of `fullyComplete` property on the file object
        // so it's easier to see that the file is upload…fully complete…rather than
        // what we have to do now (`uploadComplete && !postprocess`)
  
        _this6.setState({
          files: files
        });
      });
      this.on('restored', function () {
        // Files may have changed--ensure progress is still accurate.
        _this6._calculateTotalProgress();
      }); // show informer if offline
  
      if (typeof window !== 'undefined' && window.addEventListener) {
        window.addEventListener('online', function () {
          return _this6.updateOnlineStatus();
        });
        window.addEventListener('offline', function () {
          return _this6.updateOnlineStatus();
        });
        setTimeout(function () {
          return _this6.updateOnlineStatus();
        }, 3000);
      }
    };
  
    _proto.updateOnlineStatus = function updateOnlineStatus() {
      var online = typeof window.navigator.onLine !== 'undefined' ? window.navigator.onLine : true;
  
      if (!online) {
        this.emit('is-offline');
        this.info(this.i18n('noInternetConnection'), 'error', 0);
        this.wasOffline = true;
      } else {
        this.emit('is-online');
  
        if (this.wasOffline) {
          this.emit('back-online');
          this.info(this.i18n('connectedToInternet'), 'success', 3000);
          this.wasOffline = false;
        }
      }
    };
  
    _proto.getID = function getID() {
      return this.opts.id;
    }
    /**
     * Registers a plugin with Core.
     *
     * @param {object} Plugin object
     * @param {object} [opts] object with options to be passed to Plugin
     * @returns {object} self for chaining
     */
    ;
  
    _proto.use = function use(Plugin, opts) {
      if (typeof Plugin !== 'function') {
        var msg = "Expected a plugin class, but got " + (Plugin === null ? 'null' : typeof Plugin) + "." + ' Please verify that the plugin was imported and spelled correctly.';
        throw new TypeError(msg);
      } // Instantiate
  
  
      var plugin = new Plugin(this, opts);
      var pluginId = plugin.id;
      this.plugins[plugin.type] = this.plugins[plugin.type] || [];
  
      if (!pluginId) {
        throw new Error('Your plugin must have an id');
      }
  
      if (!plugin.type) {
        throw new Error('Your plugin must have a type');
      }
  
      var existsPluginAlready = this.getPlugin(pluginId);
  
      if (existsPluginAlready) {
        var _msg = "Already found a plugin named '" + existsPluginAlready.id + "'. " + ("Tried to use: '" + pluginId + "'.\n") + 'Uppy plugins must have unique `id` options. See https://uppy.io/docs/plugins/#id.';
  
        throw new Error(_msg);
      }
  
      if (Plugin.VERSION) {
        this.log("Using " + pluginId + " v" + Plugin.VERSION);
      }
  
      this.plugins[plugin.type].push(plugin);
      plugin.install();
      return this;
    }
    /**
     * Find one Plugin by name.
     *
     * @param {string} id plugin id
     * @returns {object|boolean}
     */
    ;
  
    _proto.getPlugin = function getPlugin(id) {
      var foundPlugin = null;
      this.iteratePlugins(function (plugin) {
        if (plugin.id === id) {
          foundPlugin = plugin;
          return false;
        }
      });
      return foundPlugin;
    }
    /**
     * Iterate through all `use`d plugins.
     *
     * @param {Function} method that will be run on each plugin
     */
    ;
  
    _proto.iteratePlugins = function iteratePlugins(method) {
      var _this7 = this;
  
      Object.keys(this.plugins).forEach(function (pluginType) {
        _this7.plugins[pluginType].forEach(method);
      });
    }
    /**
     * Uninstall and remove a plugin.
     *
     * @param {object} instance The plugin instance to remove.
     */
    ;
  
    _proto.removePlugin = function removePlugin(instance) {
      this.log("Removing plugin " + instance.id);
      this.emit('plugin-remove', instance);
  
      if (instance.uninstall) {
        instance.uninstall();
      }
  
      var list = this.plugins[instance.type].slice();
      var index = list.indexOf(instance);
  
      if (index !== -1) {
        list.splice(index, 1);
        this.plugins[instance.type] = list;
      }
  
      var updatedState = this.getState();
      delete updatedState.plugins[instance.id];
      this.setState(updatedState);
    }
    /**
     * Uninstall all plugins and close down this Uppy instance.
     */
    ;
  
    _proto.close = function close() {
      var _this8 = this;
  
      this.log("Closing Uppy instance " + this.opts.id + ": removing all files and uninstalling plugins");
      this.reset();
  
      this._storeUnsubscribe();
  
      this.iteratePlugins(function (plugin) {
        _this8.removePlugin(plugin);
      });
    }
    /**
     * Set info message in `state.info`, so that UI plugins like `Informer`
     * can display the message.
     *
     * @param {string | object} message Message to be displayed by the informer
     * @param {string} [type]
     * @param {number} [duration]
     */
    ;
  
    _proto.info = function info(message, type, duration) {
      if (type === void 0) {
        type = 'info';
      }
  
      if (duration === void 0) {
        duration = 3000;
      }
  
      var isComplexMessage = typeof message === 'object';
      this.setState({
        info: {
          isHidden: false,
          type: type,
          message: isComplexMessage ? message.message : message,
          details: isComplexMessage ? message.details : null
        }
      });
      this.emit('info-visible');
      clearTimeout(this.infoTimeoutID);
  
      if (duration === 0) {
        this.infoTimeoutID = undefined;
        return;
      } // hide the informer after `duration` milliseconds
  
  
      this.infoTimeoutID = setTimeout(this.hideInfo, duration);
    };
  
    _proto.hideInfo = function hideInfo() {
      var newInfo = _extends({}, this.getState().info, {
        isHidden: true
      });
  
      this.setState({
        info: newInfo
      });
      this.emit('info-hidden');
    }
    /**
     * Passes messages to a function, provided in `opts.logger`.
     * If `opts.logger: Uppy.debugLogger` or `opts.debug: true`, logs to the browser console.
     *
     * @param {string|object} message to log
     * @param {string} [type] optional `error` or `warning`
     */
    ;
  
    _proto.log = function log(message, type) {
      var logger = this.opts.logger;
  
      switch (type) {
        case 'error':
          logger.error(message);
          break;
  
        case 'warning':
          logger.warn(message);
          break;
  
        default:
          logger.debug(message);
          break;
      }
    }
    /**
     * Obsolete, event listeners are now added in the constructor.
     */
    ;
  
    _proto.run = function run() {
      this.log('Calling run() is no longer necessary.', 'warning');
      return this;
    }
    /**
     * Restore an upload by its ID.
     */
    ;
  
    _proto.restore = function restore(uploadID) {
      this.log("Core: attempting to restore upload \"" + uploadID + "\"");
  
      if (!this.getState().currentUploads[uploadID]) {
        this._removeUpload(uploadID);
  
        return Promise.reject(new Error('Nonexistent upload'));
      }
  
      return this._runUpload(uploadID);
    }
    /**
     * Create an upload for a bunch of files.
     *
     * @param {Array<string>} fileIDs File IDs to include in this upload.
     * @returns {string} ID of this upload.
     */
    ;
  
    _proto._createUpload = function _createUpload(fileIDs) {
      var _extends4;
  
      var _this$getState4 = this.getState(),
          allowNewUpload = _this$getState4.allowNewUpload,
          currentUploads = _this$getState4.currentUploads;
  
      if (!allowNewUpload) {
        throw new Error('Cannot create a new upload: already uploading.');
      }
  
      var uploadID = cuid();
      this.emit('upload', {
        id: uploadID,
        fileIDs: fileIDs
      });
      this.setState({
        allowNewUpload: this.opts.allowMultipleUploads !== false,
        currentUploads: _extends({}, currentUploads, (_extends4 = {}, _extends4[uploadID] = {
          fileIDs: fileIDs,
          step: 0,
          result: {}
        }, _extends4))
      });
      return uploadID;
    };
  
    _proto._getUpload = function _getUpload(uploadID) {
      var _this$getState5 = this.getState(),
          currentUploads = _this$getState5.currentUploads;
  
      return currentUploads[uploadID];
    }
    /**
     * Add data to an upload's result object.
     *
     * @param {string} uploadID The ID of the upload.
     * @param {object} data Data properties to add to the result object.
     */
    ;
  
    _proto.addResultData = function addResultData(uploadID, data) {
      var _extends5;
  
      if (!this._getUpload(uploadID)) {
        this.log("Not setting result for an upload that has been removed: " + uploadID);
        return;
      }
  
      var currentUploads = this.getState().currentUploads;
  
      var currentUpload = _extends({}, currentUploads[uploadID], {
        result: _extends({}, currentUploads[uploadID].result, data)
      });
  
      this.setState({
        currentUploads: _extends({}, currentUploads, (_extends5 = {}, _extends5[uploadID] = currentUpload, _extends5))
      });
    }
    /**
     * Remove an upload, eg. if it has been canceled or completed.
     *
     * @param {string} uploadID The ID of the upload.
     */
    ;
  
    _proto._removeUpload = function _removeUpload(uploadID) {
      var currentUploads = _extends({}, this.getState().currentUploads);
  
      delete currentUploads[uploadID];
      this.setState({
        currentUploads: currentUploads
      });
    }
    /**
     * Run an upload. This picks up where it left off in case the upload is being restored.
     *
     * @private
     */
    ;
  
    _proto._runUpload = function _runUpload(uploadID) {
      var _this9 = this;
  
      var uploadData = this.getState().currentUploads[uploadID];
      var restoreStep = uploadData.step;
      var steps = [].concat(this.preProcessors, this.uploaders, this.postProcessors);
      var lastStep = Promise.resolve();
      steps.forEach(function (fn, step) {
        // Skip this step if we are restoring and have already completed this step before.
        if (step < restoreStep) {
          return;
        }
  
        lastStep = lastStep.then(function () {
          var _extends6;
  
          var _this9$getState = _this9.getState(),
              currentUploads = _this9$getState.currentUploads;
  
          var currentUpload = currentUploads[uploadID];
  
          if (!currentUpload) {
            return;
          }
  
          var updatedUpload = _extends({}, currentUpload, {
            step: step
          });
  
          _this9.setState({
            currentUploads: _extends({}, currentUploads, (_extends6 = {}, _extends6[uploadID] = updatedUpload, _extends6))
          }); // TODO give this the `updatedUpload` object as its only parameter maybe?
          // Otherwise when more metadata may be added to the upload this would keep getting more parameters
  
  
          return fn(updatedUpload.fileIDs, uploadID);
        }).then(function (result) {
          return null;
        });
      }); // Not returning the `catch`ed promise, because we still want to return a rejected
      // promise from this method if the upload failed.
  
      lastStep.catch(function (err) {
        _this9.emit('error', err, uploadID);
  
        _this9._removeUpload(uploadID);
      });
      return lastStep.then(function () {
        // Set result data.
        var _this9$getState2 = _this9.getState(),
            currentUploads = _this9$getState2.currentUploads;
  
        var currentUpload = currentUploads[uploadID];
  
        if (!currentUpload) {
          return;
        }
  
        var files = currentUpload.fileIDs.map(function (fileID) {
          return _this9.getFile(fileID);
        });
        var successful = files.filter(function (file) {
          return !file.error;
        });
        var failed = files.filter(function (file) {
          return file.error;
        });
  
        _this9.addResultData(uploadID, {
          successful: successful,
          failed: failed,
          uploadID: uploadID
        });
      }).then(function () {
        // Emit completion events.
        // This is in a separate function so that the `currentUploads` variable
        // always refers to the latest state. In the handler right above it refers
        // to an outdated object without the `.result` property.
        var _this9$getState3 = _this9.getState(),
            currentUploads = _this9$getState3.currentUploads;
  
        if (!currentUploads[uploadID]) {
          return;
        }
  
        var currentUpload = currentUploads[uploadID];
        var result = currentUpload.result;
  
        _this9.emit('complete', result);
  
        _this9._removeUpload(uploadID);
  
        return result;
      }).then(function (result) {
        if (result == null) {
          _this9.log("Not setting result for an upload that has been removed: " + uploadID);
        }
  
        return result;
      });
    }
    /**
     * Start an upload for all the files that are not currently being uploaded.
     *
     * @returns {Promise}
     */
    ;
  
    _proto.upload = function upload() {
      var _this10 = this;
  
      if (!this.plugins.uploader) {
        this.log('No uploader type plugins are used', 'warning');
      }
  
      var files = this.getState().files;
      var onBeforeUploadResult = this.opts.onBeforeUpload(files);
  
      if (onBeforeUploadResult === false) {
        return Promise.reject(new Error('Not starting the upload because onBeforeUpload returned false'));
      }
  
      if (onBeforeUploadResult && typeof onBeforeUploadResult === 'object') {
        files = onBeforeUploadResult;
      }
  
      return Promise.resolve().then(function () {
        return _this10._checkMinNumberOfFiles(files);
      }).then(function () {
        var _this10$getState = _this10.getState(),
            currentUploads = _this10$getState.currentUploads; // get a list of files that are currently assigned to uploads
  
  
        var currentlyUploadingFiles = Object.keys(currentUploads).reduce(function (prev, curr) {
          return prev.concat(currentUploads[curr].fileIDs);
        }, []);
        var waitingFileIDs = [];
        Object.keys(files).forEach(function (fileID) {
          var file = _this10.getFile(fileID); // if the file hasn't started uploading and hasn't already been assigned to an upload..
  
  
          if (!file.progress.uploadStarted && currentlyUploadingFiles.indexOf(fileID) === -1) {
            waitingFileIDs.push(file.id);
          }
        });
  
        var uploadID = _this10._createUpload(waitingFileIDs);
  
        return _this10._runUpload(uploadID);
      }).catch(function (err) {
        _this10._showOrLogErrorAndThrow(err);
      });
    };
  
    _createClass(Uppy, [{
      key: "state",
      get: function get() {
        return this.getState();
      }
    }]);
  
    return Uppy;
  }();
  
  Uppy.VERSION = "1.5.1";
  
  module.exports = function (opts) {
    return new Uppy(opts);
  }; // Expose class constructor.
  
  
  module.exports.Uppy = Uppy;
  module.exports.Plugin = Plugin;
  module.exports.debugLogger = debugLogger;
  },{"./Plugin":8,"./loggers":10,"./supportsUploadProgress":11,"@uppy/store-default":12,"@uppy/utils/lib/Translator":16,"@uppy/utils/lib/generateFileID":19,"@uppy/utils/lib/getFileNameAndExtension":20,"@uppy/utils/lib/getFileType":21,"@uppy/utils/lib/prettyBytes":27,"cuid":30,"lodash.throttle":34,"mime-match":35,"namespace-emitter":36}],10:[function(require,module,exports){
  var getTimeStamp = require('@uppy/utils/lib/getTimeStamp'); // Swallow logs, default if logger is not set or debug: false
  
  
  var nullLogger = {
    debug: function debug() {},
    warn: function warn() {},
    error: function error() {} // Print logs to console with namespace + timestamp,
    // set by logger: Uppy.debugLogger or debug: true
  
  };
  var debugLogger = {
    debug: function debug() {
      // IE 10 doesn’t support console.debug
      var debug = console.debug || console.log;
  
      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }
  
      debug.call.apply(debug, [console, "[Uppy] [" + getTimeStamp() + "]"].concat(args));
    },
    warn: function warn() {
      var _console;
  
      for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
        args[_key2] = arguments[_key2];
      }
  
      return (_console = console).warn.apply(_console, ["[Uppy] [" + getTimeStamp() + "]"].concat(args));
    },
    error: function error() {
      var _console2;
  
      for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
        args[_key3] = arguments[_key3];
      }
  
      return (_console2 = console).error.apply(_console2, ["[Uppy] [" + getTimeStamp() + "]"].concat(args));
    }
  };
  module.exports = {
    nullLogger: nullLogger,
    debugLogger: debugLogger
  };
  },{"@uppy/utils/lib/getTimeStamp":23}],11:[function(require,module,exports){
  // Edge 15.x does not fire 'progress' events on uploads.
  // See https://github.com/transloadit/uppy/issues/945
  // And https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/12224510/
  module.exports = function supportsUploadProgress(userAgent) {
    // Allow passing in userAgent for tests
    if (userAgent == null) {
      userAgent = typeof navigator !== 'undefined' ? navigator.userAgent : null;
    } // Assume it works because basically everything supports progress events.
  
  
    if (!userAgent) return true;
    var m = /Edge\/(\d+\.\d+)/.exec(userAgent);
    if (!m) return true;
    var edgeVersion = m[1];
  
    var _edgeVersion$split = edgeVersion.split('.'),
        major = _edgeVersion$split[0],
        minor = _edgeVersion$split[1];
  
    major = parseInt(major, 10);
    minor = parseInt(minor, 10); // Worked before:
    // Edge 40.15063.0.0
    // Microsoft EdgeHTML 15.15063
  
    if (major < 15 || major === 15 && minor < 15063) {
      return true;
    } // Fixed in:
    // Microsoft EdgeHTML 18.18218
  
  
    if (major > 18 || major === 18 && minor >= 18218) {
      return true;
    } // other versions don't work.
  
  
    return false;
  };
  },{}],12:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  /**
   * Default store that keeps state in a simple object.
   */
  var DefaultStore =
  /*#__PURE__*/
  function () {
    function DefaultStore() {
      this.state = {};
      this.callbacks = [];
    }
  
    var _proto = DefaultStore.prototype;
  
    _proto.getState = function getState() {
      return this.state;
    };
  
    _proto.setState = function setState(patch) {
      var prevState = _extends({}, this.state);
  
      var nextState = _extends({}, this.state, patch);
  
      this.state = nextState;
  
      this._publish(prevState, nextState, patch);
    };
  
    _proto.subscribe = function subscribe(listener) {
      var _this = this;
  
      this.callbacks.push(listener);
      return function () {
        // Remove the listener.
        _this.callbacks.splice(_this.callbacks.indexOf(listener), 1);
      };
    };
  
    _proto._publish = function _publish() {
      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }
  
      this.callbacks.forEach(function (listener) {
        listener.apply(void 0, args);
      });
    };
  
    return DefaultStore;
  }();
  
  DefaultStore.VERSION = "1.2.0";
  
  module.exports = function defaultStore() {
    return new DefaultStore();
  };
  },{}],13:[function(require,module,exports){
  /**
   * Create a wrapper around an event emitter with a `remove` method to remove
   * all events that were added using the wrapped emitter.
   */
  module.exports =
  /*#__PURE__*/
  function () {
    function EventTracker(emitter) {
      this._events = [];
      this._emitter = emitter;
    }
  
    var _proto = EventTracker.prototype;
  
    _proto.on = function on(event, fn) {
      this._events.push([event, fn]);
  
      return this._emitter.on(event, fn);
    };
  
    _proto.remove = function remove() {
      var _this = this;
  
      this._events.forEach(function (_ref) {
        var event = _ref[0],
            fn = _ref[1];
  
        _this._emitter.off(event, fn);
      });
    };
  
    return EventTracker;
  }();
  },{}],14:[function(require,module,exports){
  /**
   * Helper to abort upload requests if there has not been any progress for `timeout` ms.
   * Create an instance using `timer = new ProgressTimeout(10000, onTimeout)`
   * Call `timer.progress()` to signal that there has been progress of any kind.
   * Call `timer.done()` when the upload has completed.
   */
  var ProgressTimeout =
  /*#__PURE__*/
  function () {
    function ProgressTimeout(timeout, timeoutHandler) {
      this._timeout = timeout;
      this._onTimedOut = timeoutHandler;
      this._isDone = false;
      this._aliveTimer = null;
      this._onTimedOut = this._onTimedOut.bind(this);
    }
  
    var _proto = ProgressTimeout.prototype;
  
    _proto.progress = function progress() {
      // Some browsers fire another progress event when the upload is
      // cancelled, so we have to ignore progress after the timer was
      // told to stop.
      if (this._isDone) return;
  
      if (this._timeout > 0) {
        if (this._aliveTimer) clearTimeout(this._aliveTimer);
        this._aliveTimer = setTimeout(this._onTimedOut, this._timeout);
      }
    };
  
    _proto.done = function done() {
      if (this._aliveTimer) {
        clearTimeout(this._aliveTimer);
        this._aliveTimer = null;
      }
  
      this._isDone = true;
    };
  
    return ProgressTimeout;
  }();
  
  module.exports = ProgressTimeout;
  },{}],15:[function(require,module,exports){
  module.exports =
  /*#__PURE__*/
  function () {
    function RateLimitedQueue(limit) {
      if (typeof limit !== 'number' || limit === 0) {
        this.limit = Infinity;
      } else {
        this.limit = limit;
      }
  
      this.activeRequests = 0;
      this.queuedHandlers = [];
    }
  
    var _proto = RateLimitedQueue.prototype;
  
    _proto._call = function _call(fn) {
      var _this = this;
  
      this.activeRequests += 1;
      var _done = false;
      var cancelActive;
  
      try {
        cancelActive = fn();
      } catch (err) {
        this.activeRequests -= 1;
        throw err;
      }
  
      return {
        abort: function abort() {
          if (_done) return;
          _done = true;
          _this.activeRequests -= 1;
          cancelActive();
  
          _this._queueNext();
        },
        done: function done() {
          if (_done) return;
          _done = true;
          _this.activeRequests -= 1;
  
          _this._queueNext();
        }
      };
    };
  
    _proto._queueNext = function _queueNext() {
      var _this2 = this;
  
      // Do it soon but not immediately, this allows clearing out the entire queue synchronously
      // one by one without continuously _advancing_ it (and starting new tasks before immediately
      // aborting them)
      Promise.resolve().then(function () {
        _this2._next();
      });
    };
  
    _proto._next = function _next() {
      if (this.activeRequests >= this.limit) {
        return;
      }
  
      if (this.queuedHandlers.length === 0) {
        return;
      } // Dispatch the next request, and update the abort/done handlers
      // so that cancelling it does the Right Thing (and doesn't just try
      // to dequeue an already-running request).
  
  
      var next = this.queuedHandlers.shift();
  
      var handler = this._call(next.fn);
  
      next.abort = handler.abort;
      next.done = handler.done;
    };
  
    _proto._queue = function _queue(fn) {
      var _this3 = this;
  
      var handler = {
        fn: fn,
        abort: function abort() {
          _this3._dequeue(handler);
        },
        done: function done() {
          throw new Error('Cannot mark a queued request as done: this indicates a bug');
        }
      };
      this.queuedHandlers.push(handler);
      return handler;
    };
  
    _proto._dequeue = function _dequeue(handler) {
      var index = this.queuedHandlers.indexOf(handler);
  
      if (index !== -1) {
        this.queuedHandlers.splice(index, 1);
      }
    };
  
    _proto.run = function run(fn) {
      if (this.activeRequests < this.limit) {
        return this._call(fn);
      }
  
      return this._queue(fn);
    };
  
    _proto.wrapPromiseFunction = function wrapPromiseFunction(fn) {
      var _this4 = this;
  
      return function () {
        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }
  
        return new Promise(function (resolve, reject) {
          var queuedRequest = _this4.run(function () {
            var cancelError;
            fn.apply(void 0, args).then(function (result) {
              if (cancelError) {
                reject(cancelError);
              } else {
                queuedRequest.done();
                resolve(result);
              }
            }, function (err) {
              if (cancelError) {
                reject(cancelError);
              } else {
                queuedRequest.done();
                reject(err);
              }
            });
            return function () {
              cancelError = new Error('Cancelled');
            };
          });
        });
      };
    };
  
    return RateLimitedQueue;
  }();
  },{}],16:[function(require,module,exports){
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  var has = require('./hasProperty');
  /**
   * Translates strings with interpolation & pluralization support.
   * Extensible with custom dictionaries and pluralization functions.
   *
   * Borrows heavily from and inspired by Polyglot https://github.com/airbnb/polyglot.js,
   * basically a stripped-down version of it. Differences: pluralization functions are not hardcoded
   * and can be easily added among with dictionaries, nested objects are used for pluralization
   * as opposed to `||||` delimeter
   *
   * Usage example: `translator.translate('files_chosen', {smart_count: 3})`
   */
  
  
  module.exports =
  /*#__PURE__*/
  function () {
    /**
     * @param {object|Array<object>} locales - locale or list of locales.
     */
    function Translator(locales) {
      var _this = this;
  
      this.locale = {
        strings: {},
        pluralize: function pluralize(n) {
          if (n === 1) {
            return 0;
          }
  
          return 1;
        }
      };
  
      if (Array.isArray(locales)) {
        locales.forEach(function (locale) {
          return _this._apply(locale);
        });
      } else {
        this._apply(locales);
      }
    }
  
    var _proto = Translator.prototype;
  
    _proto._apply = function _apply(locale) {
      if (!locale || !locale.strings) {
        return;
      }
  
      var prevLocale = this.locale;
      this.locale = _extends({}, prevLocale, {
        strings: _extends({}, prevLocale.strings, locale.strings)
      });
      this.locale.pluralize = locale.pluralize || prevLocale.pluralize;
    }
    /**
     * Takes a string with placeholder variables like `%{smart_count} file selected`
     * and replaces it with values from options `{smart_count: 5}`
     *
     * @license https://github.com/airbnb/polyglot.js/blob/master/LICENSE
     * taken from https://github.com/airbnb/polyglot.js/blob/master/lib/polyglot.js#L299
     *
     * @param {string} phrase that needs interpolation, with placeholders
     * @param {object} options with values that will be used to replace placeholders
     * @returns {string} interpolated
     */
    ;
  
    _proto.interpolate = function interpolate(phrase, options) {
      var _String$prototype = String.prototype,
          split = _String$prototype.split,
          replace = _String$prototype.replace;
      var dollarRegex = /\$/g;
      var dollarBillsYall = '$$$$';
      var interpolated = [phrase];
  
      for (var arg in options) {
        if (arg !== '_' && has(options, arg)) {
          // Ensure replacement value is escaped to prevent special $-prefixed
          // regex replace tokens. the "$$$$" is needed because each "$" needs to
          // be escaped with "$" itself, and we need two in the resulting output.
          var replacement = options[arg];
  
          if (typeof replacement === 'string') {
            replacement = replace.call(options[arg], dollarRegex, dollarBillsYall);
          } // We create a new `RegExp` each time instead of using a more-efficient
          // string replace so that the same argument can be replaced multiple times
          // in the same phrase.
  
  
          interpolated = insertReplacement(interpolated, new RegExp('%\\{' + arg + '\\}', 'g'), replacement);
        }
      }
  
      return interpolated;
  
      function insertReplacement(source, rx, replacement) {
        var newParts = [];
        source.forEach(function (chunk) {
          split.call(chunk, rx).forEach(function (raw, i, list) {
            if (raw !== '') {
              newParts.push(raw);
            } // Interlace with the `replacement` value
  
  
            if (i < list.length - 1) {
              newParts.push(replacement);
            }
          });
        });
        return newParts;
      }
    }
    /**
     * Public translate method
     *
     * @param {string} key
     * @param {object} options with values that will be used later to replace placeholders in string
     * @returns {string} translated (and interpolated)
     */
    ;
  
    _proto.translate = function translate(key, options) {
      return this.translateArray(key, options).join('');
    }
    /**
     * Get a translation and return the translated and interpolated parts as an array.
     *
     * @param {string} key
     * @param {object} options with values that will be used to replace placeholders
     * @returns {Array} The translated and interpolated parts, in order.
     */
    ;
  
    _proto.translateArray = function translateArray(key, options) {
      if (options && typeof options.smart_count !== 'undefined') {
        var plural = this.locale.pluralize(options.smart_count);
        return this.interpolate(this.locale.strings[key][plural], options);
      }
  
      return this.interpolate(this.locale.strings[key], options);
    };
  
    return Translator;
  }();
  },{"./hasProperty":24}],17:[function(require,module,exports){
  var throttle = require('lodash.throttle');
  
  function _emitSocketProgress(uploader, progressData, file) {
    var progress = progressData.progress,
        bytesUploaded = progressData.bytesUploaded,
        bytesTotal = progressData.bytesTotal;
  
    if (progress) {
      uploader.uppy.log("Upload progress: " + progress);
      uploader.uppy.emit('upload-progress', file, {
        uploader: uploader,
        bytesUploaded: bytesUploaded,
        bytesTotal: bytesTotal
      });
    }
  }
  
  module.exports = throttle(_emitSocketProgress, 300, {
    leading: true,
    trailing: true
  });
  },{"lodash.throttle":34}],18:[function(require,module,exports){
  var isDOMElement = require('./isDOMElement');
  /**
   * Find a DOM element.
   *
   * @param {Node|string} element
   * @returns {Node|null}
   */
  
  
  module.exports = function findDOMElement(element, context) {
    if (context === void 0) {
      context = document;
    }
  
    if (typeof element === 'string') {
      return context.querySelector(element);
    }
  
    if (typeof element === 'object' && isDOMElement(element)) {
      return element;
    }
  };
  },{"./isDOMElement":25}],19:[function(require,module,exports){
  /**
   * Takes a file object and turns it into fileID, by converting file.name to lowercase,
   * removing extra characters and adding type, size and lastModified
   *
   * @param {object} file
   * @returns {string} the fileID
   *
   */
  module.exports = function generateFileID(file) {
    // filter is needed to not join empty values with `-`
    return ['uppy', file.name ? encodeFilename(file.name.toLowerCase()) : '', file.type, file.meta && file.meta.relativePath ? encodeFilename(file.meta.relativePath.toLowerCase()) : '', file.data.size, file.data.lastModified].filter(function (val) {
      return val;
    }).join('-');
  };
  
  function encodeFilename(name) {
    var suffix = '';
    return name.replace(/[^A-Z0-9]/ig, function (character) {
      suffix += '-' + encodeCharacter(character);
      return '/';
    }) + suffix;
  }
  
  function encodeCharacter(character) {
    return character.charCodeAt(0).toString(32);
  }
  },{}],20:[function(require,module,exports){
  /**
   * Takes a full filename string and returns an object {name, extension}
   *
   * @param {string} fullFileName
   * @returns {object} {name, extension}
   */
  module.exports = function getFileNameAndExtension(fullFileName) {
    var re = /(?:\.([^.]+))?$/;
    var fileExt = re.exec(fullFileName)[1];
    var fileName = fullFileName.replace('.' + fileExt, '');
    return {
      name: fileName,
      extension: fileExt
    };
  };
  },{}],21:[function(require,module,exports){
  var getFileNameAndExtension = require('./getFileNameAndExtension');
  
  var mimeTypes = require('./mimeTypes');
  
  module.exports = function getFileType(file) {
    var fileExtension = file.name ? getFileNameAndExtension(file.name).extension : null;
    fileExtension = fileExtension ? fileExtension.toLowerCase() : null;
  
    if (file.type) {
      // if mime type is set in the file object already, use that
      return file.type;
    } else if (fileExtension && mimeTypes[fileExtension]) {
      // else, see if we can map extension to a mime type
      return mimeTypes[fileExtension];
    } else {
      // if all fails, fall back to a generic byte stream type
      return 'application/octet-stream';
    }
  };
  },{"./getFileNameAndExtension":20,"./mimeTypes":26}],22:[function(require,module,exports){
  module.exports = function getSocketHost(url) {
    // get the host domain
    var regex = /^(?:https?:\/\/|\/\/)?(?:[^@\n]+@)?(?:www\.)?([^\n]+)/i;
    var host = regex.exec(url)[1];
    var socketProtocol = /^http:\/\//i.test(url) ? 'ws' : 'wss';
    return socketProtocol + "://" + host;
  };
  },{}],23:[function(require,module,exports){
  /**
   * Returns a timestamp in the format of `hours:minutes:seconds`
   */
  module.exports = function getTimeStamp() {
    var date = new Date();
    var hours = pad(date.getHours().toString());
    var minutes = pad(date.getMinutes().toString());
    var seconds = pad(date.getSeconds().toString());
    return hours + ':' + minutes + ':' + seconds;
  };
  /**
   * Adds zero to strings shorter than two characters
   */
  
  
  function pad(str) {
    return str.length !== 2 ? 0 + str : str;
  }
  },{}],24:[function(require,module,exports){
  module.exports = function has(object, key) {
    return Object.prototype.hasOwnProperty.call(object, key);
  };
  },{}],25:[function(require,module,exports){
  /**
   * Check if an object is a DOM element. Duck-typing based on `nodeType`.
   *
   * @param {*} obj
   */
  module.exports = function isDOMElement(obj) {
    return obj && typeof obj === 'object' && obj.nodeType === Node.ELEMENT_NODE;
  };
  },{}],26:[function(require,module,exports){
  // ___Why not add the mime-types package?
  //    It's 19.7kB gzipped, and we only need mime types for well-known extensions (for file previews).
  // ___Where to take new extensions from?
  //    https://github.com/jshttp/mime-db/blob/master/db.json
  module.exports = {
    md: 'text/markdown',
    markdown: 'text/markdown',
    mp4: 'video/mp4',
    mp3: 'audio/mp3',
    svg: 'image/svg+xml',
    jpg: 'image/jpeg',
    png: 'image/png',
    gif: 'image/gif',
    heic: 'image/heic',
    heif: 'image/heif',
    yaml: 'text/yaml',
    yml: 'text/yaml',
    csv: 'text/csv',
    avi: 'video/x-msvideo',
    mks: 'video/x-matroska',
    mkv: 'video/x-matroska',
    mov: 'video/quicktime',
    doc: 'application/msword',
    docm: 'application/vnd.ms-word.document.macroenabled.12',
    docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    dot: 'application/msword',
    dotm: 'application/vnd.ms-word.template.macroenabled.12',
    dotx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
    xla: 'application/vnd.ms-excel',
    xlam: 'application/vnd.ms-excel.addin.macroenabled.12',
    xlc: 'application/vnd.ms-excel',
    xlf: 'application/x-xliff+xml',
    xlm: 'application/vnd.ms-excel',
    xls: 'application/vnd.ms-excel',
    xlsb: 'application/vnd.ms-excel.sheet.binary.macroenabled.12',
    xlsm: 'application/vnd.ms-excel.sheet.macroenabled.12',
    xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    xlt: 'application/vnd.ms-excel',
    xltm: 'application/vnd.ms-excel.template.macroenabled.12',
    xltx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
    xlw: 'application/vnd.ms-excel',
    txt: 'text/plain',
    text: 'text/plain',
    conf: 'text/plain',
    log: 'text/plain',
    pdf: 'application/pdf'
  };
  },{}],27:[function(require,module,exports){
  // Adapted from https://github.com/Flet/prettier-bytes/
  // Changing 1000 bytes to 1024, so we can keep uppercase KB vs kB
  // ISC License (c) Dan Flettre https://github.com/Flet/prettier-bytes/blob/master/LICENSE
  module.exports = prettierBytes;
  
  function prettierBytes(num) {
    if (typeof num !== 'number' || isNaN(num)) {
      throw new TypeError('Expected a number, got ' + typeof num);
    }
  
    var neg = num < 0;
    var units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  
    if (neg) {
      num = -num;
    }
  
    if (num < 1) {
      return (neg ? '-' : '') + num + ' B';
    }
  
    var exponent = Math.min(Math.floor(Math.log(num) / Math.log(1024)), units.length - 1);
    num = Number(num / Math.pow(1024, exponent));
    var unit = units[exponent];
  
    if (num >= 10 || num % 1 === 0) {
      // Do not show decimals when the number is two-digit, or if the number has no
      // decimal component.
      return (neg ? '-' : '') + num.toFixed(0) + ' ' + unit;
    } else {
      return (neg ? '-' : '') + num.toFixed(1) + ' ' + unit;
    }
  }
  },{}],28:[function(require,module,exports){
  module.exports = function settle(promises) {
    var resolutions = [];
    var rejections = [];
  
    function resolved(value) {
      resolutions.push(value);
    }
  
    function rejected(error) {
      rejections.push(error);
    }
  
    var wait = Promise.all(promises.map(function (promise) {
      return promise.then(resolved, rejected);
    }));
    return wait.then(function () {
      return {
        successful: resolutions,
        failed: rejections
      };
    });
  };
  },{}],29:[function(require,module,exports){
  var _class, _temp;
  
  function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }
  
  function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }
  
  function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
  
  var _require = require('@uppy/core'),
      Plugin = _require.Plugin;
  
  var cuid = require('cuid');
  
  var Translator = require('@uppy/utils/lib/Translator');
  
  var _require2 = require('@uppy/companion-client'),
      Provider = _require2.Provider,
      RequestClient = _require2.RequestClient,
      Socket = _require2.Socket;
  
  var emitSocketProgress = require('@uppy/utils/lib/emitSocketProgress');
  
  var getSocketHost = require('@uppy/utils/lib/getSocketHost');
  
  var settle = require('@uppy/utils/lib/settle');
  
  var EventTracker = require('@uppy/utils/lib/EventTracker');
  
  var ProgressTimeout = require('@uppy/utils/lib/ProgressTimeout');
  
  var RateLimitedQueue = require('@uppy/utils/lib/RateLimitedQueue');
  
  function buildResponseError(xhr, error) {
    // No error message
    if (!error) error = new Error('Upload error'); // Got an error message string
  
    if (typeof error === 'string') error = new Error(error); // Got something else
  
    if (!(error instanceof Error)) {
      error = _extends(new Error('Upload error'), {
        data: error
      });
    }
  
    error.request = xhr;
    return error;
  }
  /**
   * Set `data.type` in the blob to `file.meta.type`,
   * because we might have detected a more accurate file type in Uppy
   * https://stackoverflow.com/a/50875615
   *
   * @param {object} file File object with `data`, `size` and `meta` properties
   * @returns {object} blob updated with the new `type` set from `file.meta.type`
   */
  
  
  function setTypeInBlob(file) {
    var dataWithUpdatedType = file.data.slice(0, file.data.size, file.meta.type);
    return dataWithUpdatedType;
  }
  
  module.exports = (_temp = _class =
  /*#__PURE__*/
  function (_Plugin) {
    _inheritsLoose(XHRUpload, _Plugin);
  
    function XHRUpload(uppy, opts) {
      var _this;
  
      _this = _Plugin.call(this, uppy, opts) || this;
      _this.type = 'uploader';
      _this.id = _this.opts.id || 'XHRUpload';
      _this.title = 'XHRUpload';
      _this.defaultLocale = {
        strings: {
          timedOut: 'Upload stalled for %{seconds} seconds, aborting.'
        } // Default options
  
      };
      var defaultOptions = {
        formData: true,
        fieldName: 'files[]',
        method: 'post',
        metaFields: null,
        responseUrlFieldName: 'url',
        bundle: false,
        headers: {},
        timeout: 30 * 1000,
        limit: 0,
        withCredentials: false,
        responseType: '',
  
        /**
         * @typedef respObj
         * @property {string} responseText
         * @property {number} status
         * @property {string} statusText
         * @property {object.<string, string>} headers
         *
         * @param {string} responseText the response body string
         * @param {XMLHttpRequest | respObj} response the response object (XHR or similar)
         */
        getResponseData: function getResponseData(responseText, response) {
          var parsedResponse = {};
  
          try {
            parsedResponse = JSON.parse(responseText);
          } catch (err) {
            console.log(err);
          }
  
          return parsedResponse;
        },
  
        /**
         *
         * @param {string} responseText the response body string
         * @param {XMLHttpRequest | respObj} response the response object (XHR or similar)
         */
        getResponseError: function getResponseError(responseText, response) {
          return new Error('Upload error');
        },
  
        /**
         * @param {number} status the response status code
         * @param {string} responseText the response body string
         * @param {XMLHttpRequest | respObj} response the response object (XHR or similar)
         */
        validateStatus: function validateStatus(status, responseText, response) {
          return status >= 200 && status < 300;
        }
      }; // Merge default options with the ones set by user
  
      _this.opts = _extends({}, defaultOptions, opts); // i18n
  
      _this.translator = new Translator([_this.defaultLocale, _this.uppy.locale, _this.opts.locale]);
      _this.i18n = _this.translator.translate.bind(_this.translator);
      _this.i18nArray = _this.translator.translateArray.bind(_this.translator);
      _this.handleUpload = _this.handleUpload.bind(_assertThisInitialized(_this)); // Simultaneous upload limiting is shared across all uploads with this plugin.
      // __queue is for internal Uppy use only!
  
      if (_this.opts.__queue instanceof RateLimitedQueue) {
        _this.requests = _this.opts.__queue;
      } else {
        _this.requests = new RateLimitedQueue(_this.opts.limit);
      }
  
      if (_this.opts.bundle && !_this.opts.formData) {
        throw new Error('`opts.formData` must be true when `opts.bundle` is enabled.');
      }
  
      _this.uploaderEvents = Object.create(null);
      return _this;
    }
  
    var _proto = XHRUpload.prototype;
  
    _proto.getOptions = function getOptions(file) {
      var overrides = this.uppy.getState().xhrUpload;
  
      var opts = _extends({}, this.opts, {}, overrides || {}, {}, file.xhrUpload || {}, {
        headers: {}
      });
  
      _extends(opts.headers, this.opts.headers);
  
      if (overrides) {
        _extends(opts.headers, overrides.headers);
      }
  
      if (file.xhrUpload) {
        _extends(opts.headers, file.xhrUpload.headers);
      }
  
      return opts;
    };
  
    _proto.addMetadata = function addMetadata(formData, meta, opts) {
      var metaFields = Array.isArray(opts.metaFields) ? opts.metaFields // Send along all fields by default.
      : Object.keys(meta);
      metaFields.forEach(function (item) {
        formData.append(item, meta[item]);
      });
    };
  
    _proto.createFormDataUpload = function createFormDataUpload(file, opts) {
      var formPost = new FormData();
      this.addMetadata(formPost, file.meta, opts);
      var dataWithUpdatedType = setTypeInBlob(file);
  
      if (file.name) {
        formPost.append(opts.fieldName, dataWithUpdatedType, file.meta.name);
      } else {
        formPost.append(opts.fieldName, dataWithUpdatedType);
      }
  
      return formPost;
    };
  
    _proto.createBundledUpload = function createBundledUpload(files, opts) {
      var _this2 = this;
  
      var formPost = new FormData();
  
      var _this$uppy$getState = this.uppy.getState(),
          meta = _this$uppy$getState.meta;
  
      this.addMetadata(formPost, meta, opts);
      files.forEach(function (file) {
        var opts = _this2.getOptions(file);
  
        var dataWithUpdatedType = setTypeInBlob(file);
  
        if (file.name) {
          formPost.append(opts.fieldName, dataWithUpdatedType, file.name);
        } else {
          formPost.append(opts.fieldName, dataWithUpdatedType);
        }
      });
      return formPost;
    };
  
    _proto.createBareUpload = function createBareUpload(file, opts) {
      return file.data;
    };
  
    _proto.upload = function upload(file, current, total) {
      var _this3 = this;
  
      var opts = this.getOptions(file);
      this.uppy.log("uploading " + current + " of " + total);
      return new Promise(function (resolve, reject) {
        _this3.uppy.emit('upload-started', file);
  
        var data = opts.formData ? _this3.createFormDataUpload(file, opts) : _this3.createBareUpload(file, opts);
        var timer = new ProgressTimeout(opts.timeout, function () {
          xhr.abort();
          var error = new Error(_this3.i18n('timedOut', {
            seconds: Math.ceil(opts.timeout / 1000)
          }));
  
          _this3.uppy.emit('upload-error', file, error);
  
          reject(error);
        });
        var xhr = new XMLHttpRequest();
        _this3.uploaderEvents[file.id] = new EventTracker(_this3.uppy);
        var id = cuid();
        xhr.upload.addEventListener('loadstart', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " started");
        });
        xhr.upload.addEventListener('progress', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " progress: " + ev.loaded + " / " + ev.total); // Begin checking for timeouts when progress starts, instead of loading,
          // to avoid timing out requests on browser concurrency queue
  
  
          timer.progress();
  
          if (ev.lengthComputable) {
            _this3.uppy.emit('upload-progress', file, {
              uploader: _this3,
              bytesUploaded: ev.loaded,
              bytesTotal: ev.total
            });
          }
        });
        xhr.addEventListener('load', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " finished");
  
          timer.done();
          queuedRequest.done();
  
          if (_this3.uploaderEvents[file.id]) {
            _this3.uploaderEvents[file.id].remove();
  
            _this3.uploaderEvents[file.id] = null;
          }
  
          if (opts.validateStatus(ev.target.status, xhr.responseText, xhr)) {
            var body = opts.getResponseData(xhr.responseText, xhr);
            var uploadURL = body[opts.responseUrlFieldName];
            var uploadResp = {
              status: ev.target.status,
              body: body,
              uploadURL: uploadURL
            };
  
            _this3.uppy.emit('upload-success', file, uploadResp);
  
            if (uploadURL) {
              _this3.uppy.log("Download " + file.name + " from " + uploadURL);
            }
  
            return resolve(file);
          } else {
            var _body = opts.getResponseData(xhr.responseText, xhr);
  
            var error = buildResponseError(xhr, opts.getResponseError(xhr.responseText, xhr));
            var response = {
              status: ev.target.status,
              body: _body
            };
  
            _this3.uppy.emit('upload-error', file, error, response);
  
            return reject(error);
          }
        });
        xhr.addEventListener('error', function (ev) {
          _this3.uppy.log("[XHRUpload] " + id + " errored");
  
          timer.done();
          queuedRequest.done();
  
          if (_this3.uploaderEvents[file.id]) {
            _this3.uploaderEvents[file.id].remove();
  
            _this3.uploaderEvents[file.id] = null;
          }
  
          var error = buildResponseError(xhr, opts.getResponseError(xhr.responseText, xhr));
  
          _this3.uppy.emit('upload-error', file, error);
  
          return reject(error);
        });
        xhr.open(opts.method.toUpperCase(), opts.endpoint, true); // IE10 does not allow setting `withCredentials` and `responseType`
        // before `open()` is called.
  
        xhr.withCredentials = opts.withCredentials;
  
        if (opts.responseType !== '') {
          xhr.responseType = opts.responseType;
        }
  
        Object.keys(opts.headers).forEach(function (header) {
          xhr.setRequestHeader(header, opts.headers[header]);
        });
  
        var queuedRequest = _this3.requests.run(function () {
          xhr.send(data);
          return function () {
            timer.done();
            xhr.abort();
          };
        });
  
        _this3.onFileRemove(file.id, function () {
          queuedRequest.abort();
          reject(new Error('File removed'));
        });
  
        _this3.onCancelAll(file.id, function () {
          queuedRequest.abort();
          reject(new Error('Upload cancelled'));
        });
      });
    };
  
    _proto.uploadRemote = function uploadRemote(file, current, total) {
      var _this4 = this;
  
      var opts = this.getOptions(file);
      return new Promise(function (resolve, reject) {
        _this4.uppy.emit('upload-started', file);
  
        var fields = {};
        var metaFields = Array.isArray(opts.metaFields) ? opts.metaFields // Send along all fields by default.
        : Object.keys(file.meta);
        metaFields.forEach(function (name) {
          fields[name] = file.meta[name];
        });
        var Client = file.remote.providerOptions.provider ? Provider : RequestClient;
        var client = new Client(_this4.uppy, file.remote.providerOptions);
        client.post(file.remote.url, _extends({}, file.remote.body, {
          endpoint: opts.endpoint,
          size: file.data.size,
          fieldname: opts.fieldName,
          metadata: fields,
          headers: opts.headers
        })).then(function (res) {
          var token = res.token;
          var host = getSocketHost(file.remote.companionUrl);
          var socket = new Socket({
            target: host + "/api/" + token,
            autoOpen: false
          });
          _this4.uploaderEvents[file.id] = new EventTracker(_this4.uppy);
  
          _this4.onFileRemove(file.id, function () {
            socket.send('pause', {});
            queuedRequest.abort();
            resolve("upload " + file.id + " was removed");
          });
  
          _this4.onCancelAll(file.id, function () {
            socket.send('pause', {});
            queuedRequest.abort();
            resolve("upload " + file.id + " was canceled");
          });
  
          _this4.onRetry(file.id, function () {
            socket.send('pause', {});
            socket.send('resume', {});
          });
  
          _this4.onRetryAll(file.id, function () {
            socket.send('pause', {});
            socket.send('resume', {});
          });
  
          socket.on('progress', function (progressData) {
            return emitSocketProgress(_this4, progressData, file);
          });
          socket.on('success', function (data) {
            var body = opts.getResponseData(data.response.responseText, data.response);
            var uploadURL = body[opts.responseUrlFieldName];
            var uploadResp = {
              status: data.response.status,
              body: body,
              uploadURL: uploadURL
            };
  
            _this4.uppy.emit('upload-success', file, uploadResp);
  
            queuedRequest.done();
  
            if (_this4.uploaderEvents[file.id]) {
              _this4.uploaderEvents[file.id].remove();
  
              _this4.uploaderEvents[file.id] = null;
            }
  
            return resolve();
          });
          socket.on('error', function (errData) {
            var resp = errData.response;
            var error = resp ? opts.getResponseError(resp.responseText, resp) : _extends(new Error(errData.error.message), {
              cause: errData.error
            });
  
            _this4.uppy.emit('upload-error', file, error);
  
            queuedRequest.done();
  
            if (_this4.uploaderEvents[file.id]) {
              _this4.uploaderEvents[file.id].remove();
  
              _this4.uploaderEvents[file.id] = null;
            }
  
            reject(error);
          });
  
          var queuedRequest = _this4.requests.run(function () {
            socket.open();
  
            if (file.isPaused) {
              socket.send('pause', {});
            }
  
            return function () {
              return socket.close();
            };
          });
        });
      });
    };
  
    _proto.uploadBundle = function uploadBundle(files) {
      var _this5 = this;
  
      return new Promise(function (resolve, reject) {
        var endpoint = _this5.opts.endpoint;
        var method = _this5.opts.method;
  
        var optsFromState = _this5.uppy.getState().xhrUpload;
  
        var formData = _this5.createBundledUpload(files, _extends({}, _this5.opts, {}, optsFromState || {}));
  
        var xhr = new XMLHttpRequest();
        var timer = new ProgressTimeout(_this5.opts.timeout, function () {
          xhr.abort();
          var error = new Error(_this5.i18n('timedOut', {
            seconds: Math.ceil(_this5.opts.timeout / 1000)
          }));
          emitError(error);
          reject(error);
        });
  
        var emitError = function emitError(error) {
          files.forEach(function (file) {
            _this5.uppy.emit('upload-error', file, error);
          });
        };
  
        xhr.upload.addEventListener('loadstart', function (ev) {
          _this5.uppy.log('[XHRUpload] started uploading bundle');
  
          timer.progress();
        });
        xhr.upload.addEventListener('progress', function (ev) {
          timer.progress();
          if (!ev.lengthComputable) return;
          files.forEach(function (file) {
            _this5.uppy.emit('upload-progress', file, {
              uploader: _this5,
              bytesUploaded: ev.loaded / ev.total * file.size,
              bytesTotal: file.size
            });
          });
        });
        xhr.addEventListener('load', function (ev) {
          timer.done();
  
          if (_this5.opts.validateStatus(ev.target.status, xhr.responseText, xhr)) {
            var body = _this5.opts.getResponseData(xhr.responseText, xhr);
  
            var uploadResp = {
              status: ev.target.status,
              body: body
            };
            files.forEach(function (file) {
              _this5.uppy.emit('upload-success', file, uploadResp);
            });
            return resolve();
          }
  
          var error = _this5.opts.getResponseError(xhr.responseText, xhr) || new Error('Upload error');
          error.request = xhr;
          emitError(error);
          return reject(error);
        });
        xhr.addEventListener('error', function (ev) {
          timer.done();
          var error = _this5.opts.getResponseError(xhr.responseText, xhr) || new Error('Upload error');
          emitError(error);
          return reject(error);
        });
  
        _this5.uppy.on('cancel-all', function () {
          timer.done();
          xhr.abort();
        });
  
        xhr.open(method.toUpperCase(), endpoint, true); // IE10 does not allow setting `withCredentials` and `responseType`
        // before `open()` is called.
  
        xhr.withCredentials = _this5.opts.withCredentials;
  
        if (_this5.opts.responseType !== '') {
          xhr.responseType = _this5.opts.responseType;
        }
  
        Object.keys(_this5.opts.headers).forEach(function (header) {
          xhr.setRequestHeader(header, _this5.opts.headers[header]);
        });
        xhr.send(formData);
        files.forEach(function (file) {
          _this5.uppy.emit('upload-started', file);
        });
      });
    };
  
    _proto.uploadFiles = function uploadFiles(files) {
      var _this6 = this;
  
      var promises = files.map(function (file, i) {
        var current = parseInt(i, 10) + 1;
        var total = files.length;
  
        if (file.error) {
          return Promise.reject(new Error(file.error));
        } else if (file.isRemote) {
          return _this6.uploadRemote(file, current, total);
        } else {
          return _this6.upload(file, current, total);
        }
      });
      return settle(promises);
    };
  
    _proto.onFileRemove = function onFileRemove(fileID, cb) {
      this.uploaderEvents[fileID].on('file-removed', function (file) {
        if (fileID === file.id) cb(file.id);
      });
    };
  
    _proto.onRetry = function onRetry(fileID, cb) {
      this.uploaderEvents[fileID].on('upload-retry', function (targetFileID) {
        if (fileID === targetFileID) {
          cb();
        }
      });
    };
  
    _proto.onRetryAll = function onRetryAll(fileID, cb) {
      var _this7 = this;
  
      this.uploaderEvents[fileID].on('retry-all', function (filesToRetry) {
        if (!_this7.uppy.getFile(fileID)) return;
        cb();
      });
    };
  
    _proto.onCancelAll = function onCancelAll(fileID, cb) {
      var _this8 = this;
  
      this.uploaderEvents[fileID].on('cancel-all', function () {
        if (!_this8.uppy.getFile(fileID)) return;
        cb();
      });
    };
  
    _proto.handleUpload = function handleUpload(fileIDs) {
      var _this9 = this;
  
      if (fileIDs.length === 0) {
        this.uppy.log('[XHRUpload] No files to upload!');
        return Promise.resolve();
      }
  
      if (this.opts.limit === 0) {
        this.uppy.log('[XHRUpload] When uploading multiple files at once, consider setting the `limit` option (to `10` for example), to limit the number of concurrent uploads, which helps prevent memory and network issues: https://uppy.io/docs/xhr-upload/#limit-0', 'warning');
      }
  
      this.uppy.log('[XHRUpload] Uploading...');
      var files = fileIDs.map(function (fileID) {
        return _this9.uppy.getFile(fileID);
      });
  
      if (this.opts.bundle) {
        // if bundle: true, we don’t support remote uploads
        var isSomeFileRemote = files.some(function (file) {
          return file.isRemote;
        });
  
        if (isSomeFileRemote) {
          throw new Error('Can’t upload remote files when bundle: true option is set');
        }
  
        return this.uploadBundle(files);
      }
  
      return this.uploadFiles(files).then(function () {
        return null;
      });
    };
  
    _proto.install = function install() {
      if (this.opts.bundle) {
        var _this$uppy$getState2 = this.uppy.getState(),
            capabilities = _this$uppy$getState2.capabilities;
  
        this.uppy.setState({
          capabilities: _extends({}, capabilities, {
            individualCancellation: false
          })
        });
      }
  
      this.uppy.addUploader(this.handleUpload);
    };
  
    _proto.uninstall = function uninstall() {
      if (this.opts.bundle) {
        var _this$uppy$getState3 = this.uppy.getState(),
            capabilities = _this$uppy$getState3.capabilities;
  
        this.uppy.setState({
          capabilities: _extends({}, capabilities, {
            individualCancellation: true
          })
        });
      }
  
      this.uppy.removeUploader(this.handleUpload);
    };
  
    return XHRUpload;
  }(Plugin), _class.VERSION = "1.3.2", _temp);
  },{"@uppy/companion-client":6,"@uppy/core":9,"@uppy/utils/lib/EventTracker":13,"@uppy/utils/lib/ProgressTimeout":14,"@uppy/utils/lib/RateLimitedQueue":15,"@uppy/utils/lib/Translator":16,"@uppy/utils/lib/emitSocketProgress":17,"@uppy/utils/lib/getSocketHost":22,"@uppy/utils/lib/settle":28,"cuid":30}],30:[function(require,module,exports){
  /**
   * cuid.js
   * Collision-resistant UID generator for browsers and node.
   * Sequential for fast db lookups and recency sorting.
   * Safe for element IDs and server-side lookups.
   *
   * Extracted from CLCTR
   *
   * Copyright (c) Eric Elliott 2012
   * MIT License
   */
  
  var fingerprint = require('./lib/fingerprint.js');
  var pad = require('./lib/pad.js');
  var getRandomValue = require('./lib/getRandomValue.js');
  
  var c = 0,
    blockSize = 4,
    base = 36,
    discreteValues = Math.pow(base, blockSize);
  
  function randomBlock () {
    return pad((getRandomValue() *
      discreteValues << 0)
      .toString(base), blockSize);
  }
  
  function safeCounter () {
    c = c < discreteValues ? c : 0;
    c++; // this is not subliminal
    return c - 1;
  }
  
  function cuid () {
    // Starting with a lowercase letter makes
    // it HTML element ID friendly.
    var letter = 'c', // hard-coded allows for sequential access
  
      // timestamp
      // warning: this exposes the exact date and time
      // that the uid was created.
      timestamp = (new Date().getTime()).toString(base),
  
      // Prevent same-machine collisions.
      counter = pad(safeCounter().toString(base), blockSize),
  
      // A few chars to generate distinct ids for different
      // clients (so different computers are far less
      // likely to generate the same id)
      print = fingerprint(),
  
      // Grab some more chars from Math.random()
      random = randomBlock() + randomBlock();
  
    return letter + timestamp + counter + print + random;
  }
  
  cuid.slug = function slug () {
    var date = new Date().getTime().toString(36),
      counter = safeCounter().toString(36).slice(-4),
      print = fingerprint().slice(0, 1) +
        fingerprint().slice(-1),
      random = randomBlock().slice(-2);
  
    return date.slice(-2) +
      counter + print + random;
  };
  
  cuid.isCuid = function isCuid (stringToCheck) {
    if (typeof stringToCheck !== 'string') return false;
    if (stringToCheck.startsWith('c')) return true;
    return false;
  };
  
  cuid.isSlug = function isSlug (stringToCheck) {
    if (typeof stringToCheck !== 'string') return false;
    var stringLength = stringToCheck.length;
    if (stringLength >= 7 && stringLength <= 10) return true;
    return false;
  };
  
  cuid.fingerprint = fingerprint;
  
  module.exports = cuid;
  
  },{"./lib/fingerprint.js":31,"./lib/getRandomValue.js":32,"./lib/pad.js":33}],31:[function(require,module,exports){
  var pad = require('./pad.js');
  
  var env = typeof window === 'object' ? window : self;
  var globalCount = Object.keys(env).length;
  var mimeTypesLength = navigator.mimeTypes ? navigator.mimeTypes.length : 0;
  var clientId = pad((mimeTypesLength +
    navigator.userAgent.length).toString(36) +
    globalCount.toString(36), 4);
  
  module.exports = function fingerprint () {
    return clientId;
  };
  
  },{"./pad.js":33}],32:[function(require,module,exports){
  
  var getRandomValue;
  
  var crypto = window.crypto || window.msCrypto;
  
  if (crypto) {
      var lim = Math.pow(2, 32) - 1;
      getRandomValue = function () {
          return Math.abs(crypto.getRandomValues(new Uint32Array(1))[0] / lim);
      };
  } else {
      getRandomValue = Math.random;
  }
  
  module.exports = getRandomValue;
  
  },{}],33:[function(require,module,exports){
  module.exports = function pad (num, size) {
    var s = '000000000' + num;
    return s.substr(s.length - size);
  };
  
  },{}],34:[function(require,module,exports){
  (function (global){
  /**
   * lodash (Custom Build) <https://lodash.com/>
   * Build: `lodash modularize exports="npm" -o ./`
   * Copyright jQuery Foundation and other contributors <https://jquery.org/>
   * Released under MIT license <https://lodash.com/license>
   * Based on Underscore.js 1.8.3 <http://underscorejs.org/LICENSE>
   * Copyright Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
   */
  
  /** Used as the `TypeError` message for "Functions" methods. */
  var FUNC_ERROR_TEXT = 'Expected a function';
  
  /** Used as references for various `Number` constants. */
  var NAN = 0 / 0;
  
  /** `Object#toString` result references. */
  var symbolTag = '[object Symbol]';
  
  /** Used to match leading and trailing whitespace. */
  var reTrim = /^\s+|\s+$/g;
  
  /** Used to detect bad signed hexadecimal string values. */
  var reIsBadHex = /^[-+]0x[0-9a-f]+$/i;
  
  /** Used to detect binary string values. */
  var reIsBinary = /^0b[01]+$/i;
  
  /** Used to detect octal string values. */
  var reIsOctal = /^0o[0-7]+$/i;
  
  /** Built-in method references without a dependency on `root`. */
  var freeParseInt = parseInt;
  
  /** Detect free variable `global` from Node.js. */
  var freeGlobal = typeof global == 'object' && global && global.Object === Object && global;
  
  /** Detect free variable `self`. */
  var freeSelf = typeof self == 'object' && self && self.Object === Object && self;
  
  /** Used as a reference to the global object. */
  var root = freeGlobal || freeSelf || Function('return this')();
  
  /** Used for built-in method references. */
  var objectProto = Object.prototype;
  
  /**
   * Used to resolve the
   * [`toStringTag`](http://ecma-international.org/ecma-262/7.0/#sec-object.prototype.tostring)
   * of values.
   */
  var objectToString = objectProto.toString;
  
  /* Built-in method references for those with the same name as other `lodash` methods. */
  var nativeMax = Math.max,
      nativeMin = Math.min;
  
  /**
   * Gets the timestamp of the number of milliseconds that have elapsed since
   * the Unix epoch (1 January 1970 00:00:00 UTC).
   *
   * @static
   * @memberOf _
   * @since 2.4.0
   * @category Date
   * @returns {number} Returns the timestamp.
   * @example
   *
   * _.defer(function(stamp) {
   *   console.log(_.now() - stamp);
   * }, _.now());
   * // => Logs the number of milliseconds it took for the deferred invocation.
   */
  var now = function() {
    return root.Date.now();
  };
  
  /**
   * Creates a debounced function that delays invoking `func` until after `wait`
   * milliseconds have elapsed since the last time the debounced function was
   * invoked. The debounced function comes with a `cancel` method to cancel
   * delayed `func` invocations and a `flush` method to immediately invoke them.
   * Provide `options` to indicate whether `func` should be invoked on the
   * leading and/or trailing edge of the `wait` timeout. The `func` is invoked
   * with the last arguments provided to the debounced function. Subsequent
   * calls to the debounced function return the result of the last `func`
   * invocation.
   *
   * **Note:** If `leading` and `trailing` options are `true`, `func` is
   * invoked on the trailing edge of the timeout only if the debounced function
   * is invoked more than once during the `wait` timeout.
   *
   * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
   * until to the next tick, similar to `setTimeout` with a timeout of `0`.
   *
   * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
   * for details over the differences between `_.debounce` and `_.throttle`.
   *
   * @static
   * @memberOf _
   * @since 0.1.0
   * @category Function
   * @param {Function} func The function to debounce.
   * @param {number} [wait=0] The number of milliseconds to delay.
   * @param {Object} [options={}] The options object.
   * @param {boolean} [options.leading=false]
   *  Specify invoking on the leading edge of the timeout.
   * @param {number} [options.maxWait]
   *  The maximum time `func` is allowed to be delayed before it's invoked.
   * @param {boolean} [options.trailing=true]
   *  Specify invoking on the trailing edge of the timeout.
   * @returns {Function} Returns the new debounced function.
   * @example
   *
   * // Avoid costly calculations while the window size is in flux.
   * jQuery(window).on('resize', _.debounce(calculateLayout, 150));
   *
   * // Invoke `sendMail` when clicked, debouncing subsequent calls.
   * jQuery(element).on('click', _.debounce(sendMail, 300, {
   *   'leading': true,
   *   'trailing': false
   * }));
   *
   * // Ensure `batchLog` is invoked once after 1 second of debounced calls.
   * var debounced = _.debounce(batchLog, 250, { 'maxWait': 1000 });
   * var source = new EventSource('/stream');
   * jQuery(source).on('message', debounced);
   *
   * // Cancel the trailing debounced invocation.
   * jQuery(window).on('popstate', debounced.cancel);
   */
  function debounce(func, wait, options) {
    var lastArgs,
        lastThis,
        maxWait,
        result,
        timerId,
        lastCallTime,
        lastInvokeTime = 0,
        leading = false,
        maxing = false,
        trailing = true;
  
    if (typeof func != 'function') {
      throw new TypeError(FUNC_ERROR_TEXT);
    }
    wait = toNumber(wait) || 0;
    if (isObject(options)) {
      leading = !!options.leading;
      maxing = 'maxWait' in options;
      maxWait = maxing ? nativeMax(toNumber(options.maxWait) || 0, wait) : maxWait;
      trailing = 'trailing' in options ? !!options.trailing : trailing;
    }
  
    function invokeFunc(time) {
      var args = lastArgs,
          thisArg = lastThis;
  
      lastArgs = lastThis = undefined;
      lastInvokeTime = time;
      result = func.apply(thisArg, args);
      return result;
    }
  
    function leadingEdge(time) {
      // Reset any `maxWait` timer.
      lastInvokeTime = time;
      // Start the timer for the trailing edge.
      timerId = setTimeout(timerExpired, wait);
      // Invoke the leading edge.
      return leading ? invokeFunc(time) : result;
    }
  
    function remainingWait(time) {
      var timeSinceLastCall = time - lastCallTime,
          timeSinceLastInvoke = time - lastInvokeTime,
          result = wait - timeSinceLastCall;
  
      return maxing ? nativeMin(result, maxWait - timeSinceLastInvoke) : result;
    }
  
    function shouldInvoke(time) {
      var timeSinceLastCall = time - lastCallTime,
          timeSinceLastInvoke = time - lastInvokeTime;
  
      // Either this is the first call, activity has stopped and we're at the
      // trailing edge, the system time has gone backwards and we're treating
      // it as the trailing edge, or we've hit the `maxWait` limit.
      return (lastCallTime === undefined || (timeSinceLastCall >= wait) ||
        (timeSinceLastCall < 0) || (maxing && timeSinceLastInvoke >= maxWait));
    }
  
    function timerExpired() {
      var time = now();
      if (shouldInvoke(time)) {
        return trailingEdge(time);
      }
      // Restart the timer.
      timerId = setTimeout(timerExpired, remainingWait(time));
    }
  
    function trailingEdge(time) {
      timerId = undefined;
  
      // Only invoke if we have `lastArgs` which means `func` has been
      // debounced at least once.
      if (trailing && lastArgs) {
        return invokeFunc(time);
      }
      lastArgs = lastThis = undefined;
      return result;
    }
  
    function cancel() {
      if (timerId !== undefined) {
        clearTimeout(timerId);
      }
      lastInvokeTime = 0;
      lastArgs = lastCallTime = lastThis = timerId = undefined;
    }
  
    function flush() {
      return timerId === undefined ? result : trailingEdge(now());
    }
  
    function debounced() {
      var time = now(),
          isInvoking = shouldInvoke(time);
  
      lastArgs = arguments;
      lastThis = this;
      lastCallTime = time;
  
      if (isInvoking) {
        if (timerId === undefined) {
          return leadingEdge(lastCallTime);
        }
        if (maxing) {
          // Handle invocations in a tight loop.
          timerId = setTimeout(timerExpired, wait);
          return invokeFunc(lastCallTime);
        }
      }
      if (timerId === undefined) {
        timerId = setTimeout(timerExpired, wait);
      }
      return result;
    }
    debounced.cancel = cancel;
    debounced.flush = flush;
    return debounced;
  }
  
  /**
   * Creates a throttled function that only invokes `func` at most once per
   * every `wait` milliseconds. The throttled function comes with a `cancel`
   * method to cancel delayed `func` invocations and a `flush` method to
   * immediately invoke them. Provide `options` to indicate whether `func`
   * should be invoked on the leading and/or trailing edge of the `wait`
   * timeout. The `func` is invoked with the last arguments provided to the
   * throttled function. Subsequent calls to the throttled function return the
   * result of the last `func` invocation.
   *
   * **Note:** If `leading` and `trailing` options are `true`, `func` is
   * invoked on the trailing edge of the timeout only if the throttled function
   * is invoked more than once during the `wait` timeout.
   *
   * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
   * until to the next tick, similar to `setTimeout` with a timeout of `0`.
   *
   * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
   * for details over the differences between `_.throttle` and `_.debounce`.
   *
   * @static
   * @memberOf _
   * @since 0.1.0
   * @category Function
   * @param {Function} func The function to throttle.
   * @param {number} [wait=0] The number of milliseconds to throttle invocations to.
   * @param {Object} [options={}] The options object.
   * @param {boolean} [options.leading=true]
   *  Specify invoking on the leading edge of the timeout.
   * @param {boolean} [options.trailing=true]
   *  Specify invoking on the trailing edge of the timeout.
   * @returns {Function} Returns the new throttled function.
   * @example
   *
   * // Avoid excessively updating the position while scrolling.
   * jQuery(window).on('scroll', _.throttle(updatePosition, 100));
   *
   * // Invoke `renewToken` when the click event is fired, but not more than once every 5 minutes.
   * var throttled = _.throttle(renewToken, 300000, { 'trailing': false });
   * jQuery(element).on('click', throttled);
   *
   * // Cancel the trailing throttled invocation.
   * jQuery(window).on('popstate', throttled.cancel);
   */
  function throttle(func, wait, options) {
    var leading = true,
        trailing = true;
  
    if (typeof func != 'function') {
      throw new TypeError(FUNC_ERROR_TEXT);
    }
    if (isObject(options)) {
      leading = 'leading' in options ? !!options.leading : leading;
      trailing = 'trailing' in options ? !!options.trailing : trailing;
    }
    return debounce(func, wait, {
      'leading': leading,
      'maxWait': wait,
      'trailing': trailing
    });
  }
  
  /**
   * Checks if `value` is the
   * [language type](http://www.ecma-international.org/ecma-262/7.0/#sec-ecmascript-language-types)
   * of `Object`. (e.g. arrays, functions, objects, regexes, `new Number(0)`, and `new String('')`)
   *
   * @static
   * @memberOf _
   * @since 0.1.0
   * @category Lang
   * @param {*} value The value to check.
   * @returns {boolean} Returns `true` if `value` is an object, else `false`.
   * @example
   *
   * _.isObject({});
   * // => true
   *
   * _.isObject([1, 2, 3]);
   * // => true
   *
   * _.isObject(_.noop);
   * // => true
   *
   * _.isObject(null);
   * // => false
   */
  function isObject(value) {
    var type = typeof value;
    return !!value && (type == 'object' || type == 'function');
  }
  
  /**
   * Checks if `value` is object-like. A value is object-like if it's not `null`
   * and has a `typeof` result of "object".
   *
   * @static
   * @memberOf _
   * @since 4.0.0
   * @category Lang
   * @param {*} value The value to check.
   * @returns {boolean} Returns `true` if `value` is object-like, else `false`.
   * @example
   *
   * _.isObjectLike({});
   * // => true
   *
   * _.isObjectLike([1, 2, 3]);
   * // => true
   *
   * _.isObjectLike(_.noop);
   * // => false
   *
   * _.isObjectLike(null);
   * // => false
   */
  function isObjectLike(value) {
    return !!value && typeof value == 'object';
  }
  
  /**
   * Checks if `value` is classified as a `Symbol` primitive or object.
   *
   * @static
   * @memberOf _
   * @since 4.0.0
   * @category Lang
   * @param {*} value The value to check.
   * @returns {boolean} Returns `true` if `value` is a symbol, else `false`.
   * @example
   *
   * _.isSymbol(Symbol.iterator);
   * // => true
   *
   * _.isSymbol('abc');
   * // => false
   */
  function isSymbol(value) {
    return typeof value == 'symbol' ||
      (isObjectLike(value) && objectToString.call(value) == symbolTag);
  }
  
  /**
   * Converts `value` to a number.
   *
   * @static
   * @memberOf _
   * @since 4.0.0
   * @category Lang
   * @param {*} value The value to process.
   * @returns {number} Returns the number.
   * @example
   *
   * _.toNumber(3.2);
   * // => 3.2
   *
   * _.toNumber(Number.MIN_VALUE);
   * // => 5e-324
   *
   * _.toNumber(Infinity);
   * // => Infinity
   *
   * _.toNumber('3.2');
   * // => 3.2
   */
  function toNumber(value) {
    if (typeof value == 'number') {
      return value;
    }
    if (isSymbol(value)) {
      return NAN;
    }
    if (isObject(value)) {
      var other = typeof value.valueOf == 'function' ? value.valueOf() : value;
      value = isObject(other) ? (other + '') : other;
    }
    if (typeof value != 'string') {
      return value === 0 ? value : +value;
    }
    value = value.replace(reTrim, '');
    var isBinary = reIsBinary.test(value);
    return (isBinary || reIsOctal.test(value))
      ? freeParseInt(value.slice(2), isBinary ? 2 : 8)
      : (reIsBadHex.test(value) ? NAN : +value);
  }
  
  module.exports = throttle;
  
  }).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
  },{}],35:[function(require,module,exports){
  var wildcard = require('wildcard');
  var reMimePartSplit = /[\/\+\.]/;
  
  /**
    # mime-match
  
    A simple function to checker whether a target mime type matches a mime-type
    pattern (e.g. image/jpeg matches image/jpeg OR image/*).
  
    ## Example Usage
  
    <<< example.js
  
  **/
  module.exports = function(target, pattern) {
    function test(pattern) {
      var result = wildcard(pattern, target, reMimePartSplit);
  
      // ensure that we have a valid mime type (should have two parts)
      return result && result.length >= 2;
    }
  
    return pattern ? test(pattern.split(';')[0]) : test;
  };
  
  },{"wildcard":38}],36:[function(require,module,exports){
  /**
  * Create an event emitter with namespaces
  * @name createNamespaceEmitter
  * @example
  * var emitter = require('./index')()
  *
  * emitter.on('*', function () {
  *   console.log('all events emitted', this.event)
  * })
  *
  * emitter.on('example', function () {
  *   console.log('example event emitted')
  * })
  */
  module.exports = function createNamespaceEmitter () {
    var emitter = {}
    var _fns = emitter._fns = {}
  
    /**
    * Emit an event. Optionally namespace the event. Handlers are fired in the order in which they were added with exact matches taking precedence. Separate the namespace and event with a `:`
    * @name emit
    * @param {String} event – the name of the event, with optional namespace
    * @param {...*} data – up to 6 arguments that are passed to the event listener
    * @example
    * emitter.emit('example')
    * emitter.emit('demo:test')
    * emitter.emit('data', { example: true}, 'a string', 1)
    */
    emitter.emit = function emit (event, arg1, arg2, arg3, arg4, arg5, arg6) {
      var toEmit = getListeners(event)
  
      if (toEmit.length) {
        emitAll(event, toEmit, [arg1, arg2, arg3, arg4, arg5, arg6])
      }
    }
  
    /**
    * Create en event listener.
    * @name on
    * @param {String} event
    * @param {Function} fn
    * @example
    * emitter.on('example', function () {})
    * emitter.on('demo', function () {})
    */
    emitter.on = function on (event, fn) {
      if (!_fns[event]) {
        _fns[event] = []
      }
  
      _fns[event].push(fn)
    }
  
    /**
    * Create en event listener that fires once.
    * @name once
    * @param {String} event
    * @param {Function} fn
    * @example
    * emitter.once('example', function () {})
    * emitter.once('demo', function () {})
    */
    emitter.once = function once (event, fn) {
      function one () {
        fn.apply(this, arguments)
        emitter.off(event, one)
      }
      this.on(event, one)
    }
  
    /**
    * Stop listening to an event. Stop all listeners on an event by only passing the event name. Stop a single listener by passing that event handler as a callback.
    * You must be explicit about what will be unsubscribed: `emitter.off('demo')` will unsubscribe an `emitter.on('demo')` listener,
    * `emitter.off('demo:example')` will unsubscribe an `emitter.on('demo:example')` listener
    * @name off
    * @param {String} event
    * @param {Function} [fn] – the specific handler
    * @example
    * emitter.off('example')
    * emitter.off('demo', function () {})
    */
    emitter.off = function off (event, fn) {
      var keep = []
  
      if (event && fn) {
        var fns = this._fns[event]
        var i = 0
        var l = fns ? fns.length : 0
  
        for (i; i < l; i++) {
          if (fns[i] !== fn) {
            keep.push(fns[i])
          }
        }
      }
  
      keep.length ? this._fns[event] = keep : delete this._fns[event]
    }
  
    function getListeners (e) {
      var out = _fns[e] ? _fns[e] : []
      var idx = e.indexOf(':')
      var args = (idx === -1) ? [e] : [e.substring(0, idx), e.substring(idx + 1)]
  
      var keys = Object.keys(_fns)
      var i = 0
      var l = keys.length
  
      for (i; i < l; i++) {
        var key = keys[i]
        if (key === '*') {
          out = out.concat(_fns[key])
        }
  
        if (args.length === 2 && args[0] === key) {
          out = out.concat(_fns[key])
          break
        }
      }
  
      return out
    }
  
    function emitAll (e, fns, args) {
      var i = 0
      var l = fns.length
  
      for (i; i < l; i++) {
        if (!fns[i]) break
        fns[i].event = e
        fns[i].apply(fns[i], args)
      }
    }
  
    return emitter
  }
  
  },{}],37:[function(require,module,exports){
  !function() {
      'use strict';
      function VNode() {}
      function h(nodeName, attributes) {
          var lastSimple, child, simple, i, children = EMPTY_CHILDREN;
          for (i = arguments.length; i-- > 2; ) stack.push(arguments[i]);
          if (attributes && null != attributes.children) {
              if (!stack.length) stack.push(attributes.children);
              delete attributes.children;
          }
          while (stack.length) if ((child = stack.pop()) && void 0 !== child.pop) for (i = child.length; i--; ) stack.push(child[i]); else {
              if ('boolean' == typeof child) child = null;
              if (simple = 'function' != typeof nodeName) if (null == child) child = ''; else if ('number' == typeof child) child = String(child); else if ('string' != typeof child) simple = !1;
              if (simple && lastSimple) children[children.length - 1] += child; else if (children === EMPTY_CHILDREN) children = [ child ]; else children.push(child);
              lastSimple = simple;
          }
          var p = new VNode();
          p.nodeName = nodeName;
          p.children = children;
          p.attributes = null == attributes ? void 0 : attributes;
          p.key = null == attributes ? void 0 : attributes.key;
          if (void 0 !== options.vnode) options.vnode(p);
          return p;
      }
      function extend(obj, props) {
          for (var i in props) obj[i] = props[i];
          return obj;
      }
      function cloneElement(vnode, props) {
          return h(vnode.nodeName, extend(extend({}, vnode.attributes), props), arguments.length > 2 ? [].slice.call(arguments, 2) : vnode.children);
      }
      function enqueueRender(component) {
          if (!component.__d && (component.__d = !0) && 1 == items.push(component)) (options.debounceRendering || defer)(rerender);
      }
      function rerender() {
          var p, list = items;
          items = [];
          while (p = list.pop()) if (p.__d) renderComponent(p);
      }
      function isSameNodeType(node, vnode, hydrating) {
          if ('string' == typeof vnode || 'number' == typeof vnode) return void 0 !== node.splitText;
          if ('string' == typeof vnode.nodeName) return !node._componentConstructor && isNamedNode(node, vnode.nodeName); else return hydrating || node._componentConstructor === vnode.nodeName;
      }
      function isNamedNode(node, nodeName) {
          return node.__n === nodeName || node.nodeName.toLowerCase() === nodeName.toLowerCase();
      }
      function getNodeProps(vnode) {
          var props = extend({}, vnode.attributes);
          props.children = vnode.children;
          var defaultProps = vnode.nodeName.defaultProps;
          if (void 0 !== defaultProps) for (var i in defaultProps) if (void 0 === props[i]) props[i] = defaultProps[i];
          return props;
      }
      function createNode(nodeName, isSvg) {
          var node = isSvg ? document.createElementNS('http://www.w3.org/2000/svg', nodeName) : document.createElement(nodeName);
          node.__n = nodeName;
          return node;
      }
      function removeNode(node) {
          var parentNode = node.parentNode;
          if (parentNode) parentNode.removeChild(node);
      }
      function setAccessor(node, name, old, value, isSvg) {
          if ('className' === name) name = 'class';
          if ('key' === name) ; else if ('ref' === name) {
              if (old) old(null);
              if (value) value(node);
          } else if ('class' === name && !isSvg) node.className = value || ''; else if ('style' === name) {
              if (!value || 'string' == typeof value || 'string' == typeof old) node.style.cssText = value || '';
              if (value && 'object' == typeof value) {
                  if ('string' != typeof old) for (var i in old) if (!(i in value)) node.style[i] = '';
                  for (var i in value) node.style[i] = 'number' == typeof value[i] && !1 === IS_NON_DIMENSIONAL.test(i) ? value[i] + 'px' : value[i];
              }
          } else if ('dangerouslySetInnerHTML' === name) {
              if (value) node.innerHTML = value.__html || '';
          } else if ('o' == name[0] && 'n' == name[1]) {
              var useCapture = name !== (name = name.replace(/Capture$/, ''));
              name = name.toLowerCase().substring(2);
              if (value) {
                  if (!old) node.addEventListener(name, eventProxy, useCapture);
              } else node.removeEventListener(name, eventProxy, useCapture);
              (node.__l || (node.__l = {}))[name] = value;
          } else if ('list' !== name && 'type' !== name && !isSvg && name in node) {
              setProperty(node, name, null == value ? '' : value);
              if (null == value || !1 === value) node.removeAttribute(name);
          } else {
              var ns = isSvg && name !== (name = name.replace(/^xlink:?/, ''));
              if (null == value || !1 === value) if (ns) node.removeAttributeNS('http://www.w3.org/1999/xlink', name.toLowerCase()); else node.removeAttribute(name); else if ('function' != typeof value) if (ns) node.setAttributeNS('http://www.w3.org/1999/xlink', name.toLowerCase(), value); else node.setAttribute(name, value);
          }
      }
      function setProperty(node, name, value) {
          try {
              node[name] = value;
          } catch (e) {}
      }
      function eventProxy(e) {
          return this.__l[e.type](options.event && options.event(e) || e);
      }
      function flushMounts() {
          var c;
          while (c = mounts.pop()) {
              if (options.afterMount) options.afterMount(c);
              if (c.componentDidMount) c.componentDidMount();
          }
      }
      function diff(dom, vnode, context, mountAll, parent, componentRoot) {
          if (!diffLevel++) {
              isSvgMode = null != parent && void 0 !== parent.ownerSVGElement;
              hydrating = null != dom && !('__preactattr_' in dom);
          }
          var ret = idiff(dom, vnode, context, mountAll, componentRoot);
          if (parent && ret.parentNode !== parent) parent.appendChild(ret);
          if (!--diffLevel) {
              hydrating = !1;
              if (!componentRoot) flushMounts();
          }
          return ret;
      }
      function idiff(dom, vnode, context, mountAll, componentRoot) {
          var out = dom, prevSvgMode = isSvgMode;
          if (null == vnode || 'boolean' == typeof vnode) vnode = '';
          if ('string' == typeof vnode || 'number' == typeof vnode) {
              if (dom && void 0 !== dom.splitText && dom.parentNode && (!dom._component || componentRoot)) {
                  if (dom.nodeValue != vnode) dom.nodeValue = vnode;
              } else {
                  out = document.createTextNode(vnode);
                  if (dom) {
                      if (dom.parentNode) dom.parentNode.replaceChild(out, dom);
                      recollectNodeTree(dom, !0);
                  }
              }
              out.__preactattr_ = !0;
              return out;
          }
          var vnodeName = vnode.nodeName;
          if ('function' == typeof vnodeName) return buildComponentFromVNode(dom, vnode, context, mountAll);
          isSvgMode = 'svg' === vnodeName ? !0 : 'foreignObject' === vnodeName ? !1 : isSvgMode;
          vnodeName = String(vnodeName);
          if (!dom || !isNamedNode(dom, vnodeName)) {
              out = createNode(vnodeName, isSvgMode);
              if (dom) {
                  while (dom.firstChild) out.appendChild(dom.firstChild);
                  if (dom.parentNode) dom.parentNode.replaceChild(out, dom);
                  recollectNodeTree(dom, !0);
              }
          }
          var fc = out.firstChild, props = out.__preactattr_, vchildren = vnode.children;
          if (null == props) {
              props = out.__preactattr_ = {};
              for (var a = out.attributes, i = a.length; i--; ) props[a[i].name] = a[i].value;
          }
          if (!hydrating && vchildren && 1 === vchildren.length && 'string' == typeof vchildren[0] && null != fc && void 0 !== fc.splitText && null == fc.nextSibling) {
              if (fc.nodeValue != vchildren[0]) fc.nodeValue = vchildren[0];
          } else if (vchildren && vchildren.length || null != fc) innerDiffNode(out, vchildren, context, mountAll, hydrating || null != props.dangerouslySetInnerHTML);
          diffAttributes(out, vnode.attributes, props);
          isSvgMode = prevSvgMode;
          return out;
      }
      function innerDiffNode(dom, vchildren, context, mountAll, isHydrating) {
          var j, c, f, vchild, child, originalChildren = dom.childNodes, children = [], keyed = {}, keyedLen = 0, min = 0, len = originalChildren.length, childrenLen = 0, vlen = vchildren ? vchildren.length : 0;
          if (0 !== len) for (var i = 0; i < len; i++) {
              var _child = originalChildren[i], props = _child.__preactattr_, key = vlen && props ? _child._component ? _child._component.__k : props.key : null;
              if (null != key) {
                  keyedLen++;
                  keyed[key] = _child;
              } else if (props || (void 0 !== _child.splitText ? isHydrating ? _child.nodeValue.trim() : !0 : isHydrating)) children[childrenLen++] = _child;
          }
          if (0 !== vlen) for (var i = 0; i < vlen; i++) {
              vchild = vchildren[i];
              child = null;
              var key = vchild.key;
              if (null != key) {
                  if (keyedLen && void 0 !== keyed[key]) {
                      child = keyed[key];
                      keyed[key] = void 0;
                      keyedLen--;
                  }
              } else if (!child && min < childrenLen) for (j = min; j < childrenLen; j++) if (void 0 !== children[j] && isSameNodeType(c = children[j], vchild, isHydrating)) {
                  child = c;
                  children[j] = void 0;
                  if (j === childrenLen - 1) childrenLen--;
                  if (j === min) min++;
                  break;
              }
              child = idiff(child, vchild, context, mountAll);
              f = originalChildren[i];
              if (child && child !== dom && child !== f) if (null == f) dom.appendChild(child); else if (child === f.nextSibling) removeNode(f); else dom.insertBefore(child, f);
          }
          if (keyedLen) for (var i in keyed) if (void 0 !== keyed[i]) recollectNodeTree(keyed[i], !1);
          while (min <= childrenLen) if (void 0 !== (child = children[childrenLen--])) recollectNodeTree(child, !1);
      }
      function recollectNodeTree(node, unmountOnly) {
          var component = node._component;
          if (component) unmountComponent(component); else {
              if (null != node.__preactattr_ && node.__preactattr_.ref) node.__preactattr_.ref(null);
              if (!1 === unmountOnly || null == node.__preactattr_) removeNode(node);
              removeChildren(node);
          }
      }
      function removeChildren(node) {
          node = node.lastChild;
          while (node) {
              var next = node.previousSibling;
              recollectNodeTree(node, !0);
              node = next;
          }
      }
      function diffAttributes(dom, attrs, old) {
          var name;
          for (name in old) if ((!attrs || null == attrs[name]) && null != old[name]) setAccessor(dom, name, old[name], old[name] = void 0, isSvgMode);
          for (name in attrs) if (!('children' === name || 'innerHTML' === name || name in old && attrs[name] === ('value' === name || 'checked' === name ? dom[name] : old[name]))) setAccessor(dom, name, old[name], old[name] = attrs[name], isSvgMode);
      }
      function collectComponent(component) {
          var name = component.constructor.name;
          (components[name] || (components[name] = [])).push(component);
      }
      function createComponent(Ctor, props, context) {
          var inst, list = components[Ctor.name];
          if (Ctor.prototype && Ctor.prototype.render) {
              inst = new Ctor(props, context);
              Component.call(inst, props, context);
          } else {
              inst = new Component(props, context);
              inst.constructor = Ctor;
              inst.render = doRender;
          }
          if (list) for (var i = list.length; i--; ) if (list[i].constructor === Ctor) {
              inst.__b = list[i].__b;
              list.splice(i, 1);
              break;
          }
          return inst;
      }
      function doRender(props, state, context) {
          return this.constructor(props, context);
      }
      function setComponentProps(component, props, opts, context, mountAll) {
          if (!component.__x) {
              component.__x = !0;
              if (component.__r = props.ref) delete props.ref;
              if (component.__k = props.key) delete props.key;
              if (!component.base || mountAll) {
                  if (component.componentWillMount) component.componentWillMount();
              } else if (component.componentWillReceiveProps) component.componentWillReceiveProps(props, context);
              if (context && context !== component.context) {
                  if (!component.__c) component.__c = component.context;
                  component.context = context;
              }
              if (!component.__p) component.__p = component.props;
              component.props = props;
              component.__x = !1;
              if (0 !== opts) if (1 === opts || !1 !== options.syncComponentUpdates || !component.base) renderComponent(component, 1, mountAll); else enqueueRender(component);
              if (component.__r) component.__r(component);
          }
      }
      function renderComponent(component, opts, mountAll, isChild) {
          if (!component.__x) {
              var rendered, inst, cbase, props = component.props, state = component.state, context = component.context, previousProps = component.__p || props, previousState = component.__s || state, previousContext = component.__c || context, isUpdate = component.base, nextBase = component.__b, initialBase = isUpdate || nextBase, initialChildComponent = component._component, skip = !1;
              if (isUpdate) {
                  component.props = previousProps;
                  component.state = previousState;
                  component.context = previousContext;
                  if (2 !== opts && component.shouldComponentUpdate && !1 === component.shouldComponentUpdate(props, state, context)) skip = !0; else if (component.componentWillUpdate) component.componentWillUpdate(props, state, context);
                  component.props = props;
                  component.state = state;
                  component.context = context;
              }
              component.__p = component.__s = component.__c = component.__b = null;
              component.__d = !1;
              if (!skip) {
                  rendered = component.render(props, state, context);
                  if (component.getChildContext) context = extend(extend({}, context), component.getChildContext());
                  var toUnmount, base, childComponent = rendered && rendered.nodeName;
                  if ('function' == typeof childComponent) {
                      var childProps = getNodeProps(rendered);
                      inst = initialChildComponent;
                      if (inst && inst.constructor === childComponent && childProps.key == inst.__k) setComponentProps(inst, childProps, 1, context, !1); else {
                          toUnmount = inst;
                          component._component = inst = createComponent(childComponent, childProps, context);
                          inst.__b = inst.__b || nextBase;
                          inst.__u = component;
                          setComponentProps(inst, childProps, 0, context, !1);
                          renderComponent(inst, 1, mountAll, !0);
                      }
                      base = inst.base;
                  } else {
                      cbase = initialBase;
                      toUnmount = initialChildComponent;
                      if (toUnmount) cbase = component._component = null;
                      if (initialBase || 1 === opts) {
                          if (cbase) cbase._component = null;
                          base = diff(cbase, rendered, context, mountAll || !isUpdate, initialBase && initialBase.parentNode, !0);
                      }
                  }
                  if (initialBase && base !== initialBase && inst !== initialChildComponent) {
                      var baseParent = initialBase.parentNode;
                      if (baseParent && base !== baseParent) {
                          baseParent.replaceChild(base, initialBase);
                          if (!toUnmount) {
                              initialBase._component = null;
                              recollectNodeTree(initialBase, !1);
                          }
                      }
                  }
                  if (toUnmount) unmountComponent(toUnmount);
                  component.base = base;
                  if (base && !isChild) {
                      var componentRef = component, t = component;
                      while (t = t.__u) (componentRef = t).base = base;
                      base._component = componentRef;
                      base._componentConstructor = componentRef.constructor;
                  }
              }
              if (!isUpdate || mountAll) mounts.unshift(component); else if (!skip) {
                  if (component.componentDidUpdate) component.componentDidUpdate(previousProps, previousState, previousContext);
                  if (options.afterUpdate) options.afterUpdate(component);
              }
              if (null != component.__h) while (component.__h.length) component.__h.pop().call(component);
              if (!diffLevel && !isChild) flushMounts();
          }
      }
      function buildComponentFromVNode(dom, vnode, context, mountAll) {
          var c = dom && dom._component, originalComponent = c, oldDom = dom, isDirectOwner = c && dom._componentConstructor === vnode.nodeName, isOwner = isDirectOwner, props = getNodeProps(vnode);
          while (c && !isOwner && (c = c.__u)) isOwner = c.constructor === vnode.nodeName;
          if (c && isOwner && (!mountAll || c._component)) {
              setComponentProps(c, props, 3, context, mountAll);
              dom = c.base;
          } else {
              if (originalComponent && !isDirectOwner) {
                  unmountComponent(originalComponent);
                  dom = oldDom = null;
              }
              c = createComponent(vnode.nodeName, props, context);
              if (dom && !c.__b) {
                  c.__b = dom;
                  oldDom = null;
              }
              setComponentProps(c, props, 1, context, mountAll);
              dom = c.base;
              if (oldDom && dom !== oldDom) {
                  oldDom._component = null;
                  recollectNodeTree(oldDom, !1);
              }
          }
          return dom;
      }
      function unmountComponent(component) {
          if (options.beforeUnmount) options.beforeUnmount(component);
          var base = component.base;
          component.__x = !0;
          if (component.componentWillUnmount) component.componentWillUnmount();
          component.base = null;
          var inner = component._component;
          if (inner) unmountComponent(inner); else if (base) {
              if (base.__preactattr_ && base.__preactattr_.ref) base.__preactattr_.ref(null);
              component.__b = base;
              removeNode(base);
              collectComponent(component);
              removeChildren(base);
          }
          if (component.__r) component.__r(null);
      }
      function Component(props, context) {
          this.__d = !0;
          this.context = context;
          this.props = props;
          this.state = this.state || {};
      }
      function render(vnode, parent, merge) {
          return diff(merge, vnode, {}, !1, parent, !1);
      }
      var options = {};
      var stack = [];
      var EMPTY_CHILDREN = [];
      var defer = 'function' == typeof Promise ? Promise.resolve().then.bind(Promise.resolve()) : setTimeout;
      var IS_NON_DIMENSIONAL = /acit|ex(?:s|g|n|p|$)|rph|ows|mnc|ntw|ine[ch]|zoo|^ord/i;
      var items = [];
      var mounts = [];
      var diffLevel = 0;
      var isSvgMode = !1;
      var hydrating = !1;
      var components = {};
      extend(Component.prototype, {
          setState: function(state, callback) {
              var s = this.state;
              if (!this.__s) this.__s = extend({}, s);
              extend(s, 'function' == typeof state ? state(s, this.props) : state);
              if (callback) (this.__h = this.__h || []).push(callback);
              enqueueRender(this);
          },
          forceUpdate: function(callback) {
              if (callback) (this.__h = this.__h || []).push(callback);
              renderComponent(this, 2);
          },
          render: function() {}
      });
      var preact = {
          h: h,
          createElement: h,
          cloneElement: cloneElement,
          Component: Component,
          render: render,
          rerender: rerender,
          options: options
      };
      if ('undefined' != typeof module) module.exports = preact; else self.preact = preact;
  }();
  
  },{}],38:[function(require,module,exports){
  /* jshint node: true */
  'use strict';
  
  /**
    # wildcard
  
    Very simple wildcard matching, which is designed to provide the same
    functionality that is found in the
    [eve](https://github.com/adobe-webplatform/eve) eventing library.
  
    ## Usage
  
    It works with strings:
  
    <<< examples/strings.js
  
    Arrays:
  
    <<< examples/arrays.js
  
    Objects (matching against keys):
  
    <<< examples/objects.js
  
    While the library works in Node, if you are are looking for file-based
    wildcard matching then you should have a look at:
  
    <https://github.com/isaacs/node-glob>
  **/
  
  function WildcardMatcher(text, separator) {
    this.text = text = text || '';
    this.hasWild = ~text.indexOf('*');
    this.separator = separator;
    this.parts = text.split(separator);
  }
  
  WildcardMatcher.prototype.match = function(input) {
    var matches = true;
    var parts = this.parts;
    var ii;
    var partsCount = parts.length;
    var testParts;
  
    if (typeof input == 'string' || input instanceof String) {
      if (!this.hasWild && this.text != input) {
        matches = false;
      } else {
        testParts = (input || '').split(this.separator);
        for (ii = 0; matches && ii < partsCount; ii++) {
          if (parts[ii] === '*')  {
            continue;
          } else if (ii < testParts.length) {
            matches = parts[ii] === testParts[ii];
          } else {
            matches = false;
          }
        }
  
        // If matches, then return the component parts
        matches = matches && testParts;
      }
    }
    else if (typeof input.splice == 'function') {
      matches = [];
  
      for (ii = input.length; ii--; ) {
        if (this.match(input[ii])) {
          matches[matches.length] = input[ii];
        }
      }
    }
    else if (typeof input == 'object') {
      matches = {};
  
      for (var key in input) {
        if (this.match(key)) {
          matches[key] = input[key];
        }
      }
    }
  
    return matches;
  };
  
  module.exports = function(text, test, separator) {
    var matcher = new WildcardMatcher(text, separator || /[\/\.]/);
    if (typeof test != 'undefined') {
      return matcher.match(test);
    }
  
    return matcher;
  };
  
  },{}]},{},[1]);
  