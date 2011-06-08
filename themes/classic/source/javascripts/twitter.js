// JSON-P Twitter fetcher for Octopress
// (c) Brandon Mathis // MIT Lisence
function getTwitterFeed(user, count, replies) {
  feed = new jXHR();
  feed.onerror = function (msg,url) {
    $('#tweets li.loading').addClass('error').text("Twitter's busted");
  }
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
      showTwitterFeed(tweets, user);
    }
  };
  feed.open("GET","http://twitter.com/statuses/user_timeline/"+user+".json?trim_user=true&count="+(parseInt(count)+60)+"&callback=?");
  feed.send();
}

function showTwitterFeed(tweets, twitter_user){
  var timeline = document.getElementById('tweets');
  timeline.innerHTML='';
  for (t in tweets){
    timeline.innerHTML+='<li>'+'<p>'+'<a href="http://twitter.com/'+twitter_user+'/status/'+tweets[t].id_str+'">'+prettyDate(tweets[t].created_at)+'</a>'+linkifyTweet(tweets[t].text.replace(/\n/g, '<br>'))+'</p>'+'</li>';
  }
}
function linkifyTweet(text){
  return text.replace(/(https?:\/\/)([\w\-:;?&=+.%#\/]+)/gi, '<a href="$1$2">$2</a>')
    .replace(/(^|\W)@(\w+)/g, '$1<a href="http://twitter.com/$2">@$2</a>')
    .replace(/(^|\W)#(\w+)/g, '$1<a href="http://search.twitter.com/search?q=%23$2">#$2</a>');
}



// jXHR.js (JSON-P XHR) | v0.1 (c) Kyle Simpson | MIT License | http://mulletxhr.com/
// uncompressed version available in source/javascripts/libs/jXHR.js
(function(c){var b=c.setTimeout,d=c.document,a=0;c.jXHR=function(){var e,g,n,h,m=null;function l(){try{h.parentNode.removeChild(h)}catch(o){}}function k(){g=false;e="";l();h=null;i(0)}function f(p){try{m.onerror.call(m,p,e)}catch(o){throw new Error(p)}}function j(){if((this.readyState&&this.readyState!=="complete"&&this.readyState!=="loaded")||g){return}this.onload=this.onreadystatechange=null;g=true;if(m.readyState!==4){f("Script failed to load ["+e+"].")}l()}function i(o,p){p=p||[];m.readyState=o;if(typeof m.onreadystatechange==="function"){m.onreadystatechange.apply(m,p)}}m={onerror:null,onreadystatechange:null,readyState:0,open:function(p,o){k();internal_callback="cb"+(a++);(function(q){c.jXHR[q]=function(){try{i.call(m,4,arguments)}catch(r){m.readyState=-1;f("Script failed to run ["+e+"].")}c.jXHR[q]=null}})(internal_callback);e=o.replace(/=\?/,"=jXHR."+internal_callback);i(1)},send:function(){b(function(){h=d.createElement("script");h.setAttribute("type","text/javascript");h.onload=h.onreadystatechange=function(){j.call(h)};h.setAttribute("src",e);d.getElementsByTagName("head")[0].appendChild(h)},0);i(2)},setRequestHeader:function(){},getResponseHeader:function(){return""},getAllResponseHeaders:function(){return[]}};k();return m}})(window);


/* Sky Slavin, Ludopoli. MIT license.  * based on JavaScript Pretty Date * Copyright (c) 2008 John Resig (jquery.com) * Licensed under the MIT license.  */

function prettyDate(time) {
  if (navigator.appName == 'Microsoft Internet Explorer') {
    return "<span>&infin;</span>"; // because IE date parsing isn't fun.
  };

  var say = {};
  say.just_now = " now",
  say.minute_ago = "1m",
  say.minutes_ago = "m",
  say.hour_ago = "1h",
  say.hours_ago = "h",
  say.yesterday = "1d",
  say.days_ago = "d",
  say.weeks_ago = "w"

  var current_date = new Date();
  current_date_time = current_date.getTime();
  current_date_full = current_date_time + (1 * 60000);
  var date = new Date(time);
  var diff = ((current_date_full - date.getTime()) / 1000);
  var day_diff = Math.floor(diff / 86400);

  if (isNaN(day_diff) || day_diff < 0 || day_diff >= 31) return;

  return day_diff == 0 && (
    diff < 60 && say.just_now ||
    diff < 120 && say.minute_ago ||
    diff < 3600 && Math.floor(diff / 60) + say.minutes_ago ||
    diff < 7200 && say.hour_ago ||
    diff < 86400 && Math.floor(diff / 3600) + say.hours_ago) ||
    day_diff == 1 && say.yesterday ||
    day_diff < 7 && day_diff + say.days_ago ||
    day_diff < 31 && Math.ceil(day_diff / 7) + say.weeks_ago;
}
