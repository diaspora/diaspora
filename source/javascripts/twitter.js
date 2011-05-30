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
    timeline.innerHTML+='<li>'+'<p>'+'<a href="http://twitter.com/'+twitter_user+'/status/'+tweets[t].id_str+'"><span>&infin;</span><span>'+prettyDate(tweets[t].created_at)+'</span></a>'+linkifyTweet(tweets[t].text)+'</p>'+'</li>';
  }
}
function linkifyTweet(text){
  return text.replace(/(https?:\/\/)([\w\-:;?&=+.%#\/]+)/gi, '<a href="$1$2">$2</a>')
    .replace(/(^|\W)@(\w+)/g, '$1<a href="http://twitter.com/$2">@$2</a>')
    .replace(/(^|\W)#(\w+)/g, '$1<a href="http://search.twitter.com/search?q=%23$2">#$2</a>');
}

function prettyDate(date_str){
  var time_formats = [
    [60, 'now', 1], // 60
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
