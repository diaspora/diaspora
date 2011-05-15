/* http://www.JSON.org/json2.js 2009-09-29 Public Domain. NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK. See http://www.JSON.org/js.html */
if(!this.JSON){this.JSON={}}(function(){function l(c){return c<10?'0'+c:c}if(typeof Date.prototype.toJSON!=='function'){Date.prototype.toJSON=function(c){return isFinite(this.valueOf())?this.getUTCFullYear()+'-'+l(this.getUTCMonth()+1)+'-'+l(this.getUTCDate())+'T'+l(this.getUTCHours())+':'+l(this.getUTCMinutes())+':'+l(this.getUTCSeconds())+'Z':null};String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(c){return this.valueOf()}}var o=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,p=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,h,m,r={'\b':'\\b','\t':'\\t','\n':'\\n','\f':'\\f','\r':'\\r','"':'\\"','\\':'\\\\'},j;function q(a){p.lastIndex=0;return p.test(a)?'"'+a.replace(p,function(c){var f=r[c];return typeof f==='string'?f:'\\u'+('0000'+c.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+a+'"'}function n(c,f){var a,e,d,i,k=h,g,b=f[c];if(b&&typeof b==='object'&&typeof b.toJSON==='function'){b=b.toJSON(c)}if(typeof j==='function'){b=j.call(f,c,b)}switch(typeof b){case'string':return q(b);case'number':return isFinite(b)?String(b):'null';case'boolean':case'null':return String(b);case'object':if(!b){return'null'}h+=m;g=[];if(Object.prototype.toString.apply(b)==='[object Array]'){i=b.length;for(a=0;a<i;a+=1){g[a]=n(a,b)||'null'}d=g.length===0?'[]':h?'[\n'+h+g.join(',\n'+h)+'\n'+k+']':'['+g.join(',')+']';h=k;return d}if(j&&typeof j==='object'){i=j.length;for(a=0;a<i;a+=1){e=j[a];if(typeof e==='string'){d=n(e,b);if(d){g.push(q(e)+(h?': ':':')+d)}}}}else{for(e in b){if(Object.hasOwnProperty.call(b,e)){d=n(e,b);if(d){g.push(q(e)+(h?': ':':')+d)}}}}d=g.length===0?'{}':h?'{\n'+h+g.join(',\n'+h)+'\n'+k+'}':'{'+g.join(',')+'}';h=k;return d}}if(typeof JSON.stringify!=='function'){JSON.stringify=function(c,f,a){var e;h='';m='';if(typeof a==='number'){for(e=0;e<a;e+=1){m+=' '}}else if(typeof a==='string'){m=a}j=f;if(f&&typeof f!=='function'&&(typeof f!=='object'||typeof f.length!=='number')){throw new Error('JSON.stringify');}return n('',{'':c})}}if(typeof JSON.parse!=='function'){JSON.parse=function(i,k){var g;function b(c,f){var a,e,d=c[f];if(d&&typeof d==='object'){for(a in d){if(Object.hasOwnProperty.call(d,a)){e=b(d,a);if(e!==undefined){d[a]=e}else{delete d[a]}}}}return k.call(c,f,d)}o.lastIndex=0;if(o.test(i)){i=i.replace(o,function(c){return'\\u'+('0000'+c.charCodeAt(0).toString(16)).slice(-4)})}if(/^[\],:{}\s]*$/.test(i.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,'@').replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,']').replace(/(?:^|:|,)(?:\s*\[)+/g,''))){g=eval('('+i+')');return typeof k==='function'?b({'':g},''):g}throw new SyntaxError('JSON.parse');}}}());

// jXHR.js (JSON-P XHR) | v0.1 (c) Kyle Simpson | MIT License
(function(c){var b=c.setTimeout,d=c.document,a=0;c.jXHR=function(){var e,g,n,h,m=null;function l(){try{h.parentNode.removeChild(h)}catch(o){}}function k(){g=false;e="";l();h=null;i(0)}function f(p){try{m.onerror.call(m,p,e)}catch(o){throw new Error(p)}}function j(){if((this.readyState&&this.readyState!=="complete"&&this.readyState!=="loaded")||g){return}this.onload=this.onreadystatechange=null;g=true;if(m.readyState!==4){f("Script failed to load ["+e+"].")}l()}function i(o,p){p=p||[];m.readyState=o;if(typeof m.onreadystatechange==="function"){m.onreadystatechange.apply(m,p)}}m={onerror:null,onreadystatechange:null,readyState:0,open:function(p,o){k();internal_callback="cb"+(a++);(function(q){c.jXHR[q]=function(){try{i.call(m,4,arguments)}catch(r){m.readyState=-1;f("Script failed to run ["+e+"].")}c.jXHR[q]=null}})(internal_callback);e=o.replace(/=\?/,"=jXHR."+internal_callback);i(1)},send:function(){b(function(){h=d.createElement("script");h.setAttribute("type","text/javascript");h.onload=h.onreadystatechange=function(){j.call(h)};h.setAttribute("src",e);d.getElementsByTagName("head")[0].appendChild(h)},0);i(2)},setRequestHeader:function(){},getResponseHeader:function(){return""},getAllResponseHeaders:function(){return[]}};k();return m}})(window);

function getTwitterFeed(success, user, count, replies) {
  feed = new jXHR();
  feed.onerror = function (msg,url) { alert(msg); }
  feed.onreadystatechange = function(data){
    if (feed.readyState === 4) {
      var tweets = new Array();
      for (i in data){
        if(tweets.length < count){
          if(replies || data[i].in_reply_to_user_id == null){
            tweets.push(data[i]);
          }
        }
      }
      success(tweets);
    }
  };
  feed.open("GET","http://twitter.com/statuses/user_timeline/"+user+".json?trim_user=true&count="+parseInt(count)+25+"&callback=?");
  feed.send();
}

getTwitterFeed(showTwitterFeed, twitter_user, tweet_count, show_replies);

function showTwitterFeed(tweets){
  var timeline = document.getElementById('tweets');
  timeline.innerHTML='';
  for (t in tweets){
    timeline.innerHTML+='<li>'+'<p>'+linkifyTweet(tweets[t].text)+'<a href="http://twitter.com/'+twitter_user+'/status/'+tweets[t].id_str+'">'+prettyDate(tweets[t].created_at)+'</a></p>'+'</li>';
  }
}
function linkifyTweet(text){
  return text.replace(/(https?:\/\/[\w\-:;?&=+.%#\/]+)/gi, '<a href="$1">$1</a>')
    .replace(/(^|\W)@(\w+)/g, '$1<a href="http://twitter.com/$2">@$2</a>')
    .replace(/(^|\W)#(\w+)/g, '$1#<a href="http://search.twitter.com/search?q=%23$2">$2</a>');
}

function prettyDate(date_str){
  var time_formats = [
    [60, 'just now', 1], // 60
    [120, '1 min', '1 minute from now'], // 60*2
    [3600, 'mins', 60], // 60*60, 60
    [7200, '1 hour', '1 hour from now'], // 60*60*2
    [86400, 'hours', 3600], // 60*60*24, 60*60
    [172800, '1 day', 'tomorrow'], // 60*60*24*2
    [2903040000, 'days', 86400], // 60*60*24*7, 60*60*24
  ];
  var time = ('' + date_str).replace(/-/g,"/").replace(/[TZ]/g," ").replace(/^\s\s*/, '').replace(/\s\s*$/, '');
  if(time.substr(time.length-4,1)==".") time =time.substr(0,time.length-4);
  var seconds = (new Date - new Date(time)) / 1000;
  var token = 'ago', list_choice = 1;
  if (seconds < 0) {
    seconds = Math.abs(seconds);
    token = 'from now';
    list_choice = 2;
  }
  var i = 0, format;
  while (format = time_formats[i++])
    if (seconds < format[0]) {
      if (typeof format[2] == 'string')
        return format[list_choice];
      else
        return Math.floor(seconds / format[2]) + ' ' + format[1];
    }
    return time;
};
