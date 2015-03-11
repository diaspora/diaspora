// source: https://github.com/kvz/phpjs/blob/master/functions/url/parse_url.js
// commit 4966dea
// 28 Dec 2014

function parse_url(str, component) {
  //       discuss at: http://phpjs.org/functions/parse_url/
  //      original by: Steven Levithan (http://blog.stevenlevithan.com)
  // reimplemented by: Brett Zamir (http://brett-zamir.me)
  //         input by: Lorenzo Pisani
  //         input by: Tony
  //      improved by: Brett Zamir (http://brett-zamir.me)
  //             note: original by http://stevenlevithan.com/demo/parseuri/js/assets/parseuri.js
  //             note: blog post at http://blog.stevenlevithan.com/archives/parseuri
  //             note: demo at http://stevenlevithan.com/demo/parseuri/js/assets/parseuri.js
  //             note: Does not replace invalid characters with '_' as in PHP, nor does it return false with
  //             note: a seriously malformed URL.
  //             note: Besides function name, is essentially the same as parseUri as well as our allowing
  //             note: an extra slash after the scheme/protocol (to allow file:/// as in PHP)
  //        example 1: parse_url('http://username:password@hostname/path?arg=value#anchor');
  //        returns 1: {scheme: 'http', host: 'hostname', user: 'username', pass: 'password', path: '/path', query: 'arg=value', fragment: 'anchor'}
  //        example 2: parse_url('http://en.wikipedia.org/wiki/%22@%22_%28album%29');
  //        returns 2: {scheme: 'http', host: 'en.wikipedia.org', path: '/wiki/%22@%22_%28album%29'}
  //        example 3: parse_url('https://host.domain.tld/a@b.c/folder')
  //        returns 3: {scheme: 'https', host: 'host.domain.tld', path: '/a@b.c/folder'}
  //        example 4: parse_url('https://gooduser:secretpassword@www.example.com/a@b.c/folder?foo=bar');
  //        returns 4: { scheme: 'https', host: 'www.example.com', path: '/a@b.c/folder', query: 'foo=bar', user: 'gooduser', pass: 'secretpassword' }

  try {
    this.php_js = this.php_js || {};
  } catch (e) {
    this.php_js = {};
  }

  var query;
  var ini  = (this.php_js && this.php_js.ini) || {};
  var mode = (ini['phpjs.parse_url.mode'] && ini['phpjs.parse_url.mode'].local_value) || 'php';
  var key  = [
    'source',
    'scheme',
    'authority',
    'userInfo',
    'user',
    'pass',
    'host',
    'port',
    'relative',
    'path',
    'directory',
    'file',
    'query',
    'fragment'
  ];
  var parser = {
    php   : /^(?:([^:\/?#]+):)?(?:\/\/()(?:(?:()(?:([^:@\/]*):?([^:@\/]*))?@)?([^:\/?#]*)(?::(\d*))?))?()(?:(()(?:(?:[^?#\/]*\/)*)()(?:[^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
    strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@\/]*):?([^:@\/]*))?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
    loose : /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/\/?)?((?:(([^:@\/]*):?([^:@\/]*))?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/ // Added one optional slash to post-scheme to catch file:/// (should restrict this)
  };

  var m   = parser[mode].exec(str);
  var uri = {};
  var i   = 14;

  while (i--) {
    if (m[i]) {
      uri[key[i]] = m[i];
    }
  }

  if (component) {
    return uri[component.replace('PHP_URL_', '').toLowerCase()];
  }

  if (mode !== 'php') {
    var name = (ini['phpjs.parse_url.queryKey'] &&
      ini['phpjs.parse_url.queryKey'].local_value) || 'queryKey';
    parser    = /(?:^|&)([^&=]*)=?([^&]*)/g;
    uri[name] = {};
    query     = uri[key[12]] || '';
    query.replace(parser, function ($0, $1, $2) {
      if ($1) {
        uri[name][$1] = $2;
      }
    });
  }

  delete uri.source;
  return uri;
}
