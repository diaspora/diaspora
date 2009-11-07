//
// The Octopress Twitter Feed is based on the following work:
// Valerio's javascript framework Mootools: Mootools.net
// David Walsh's Twitter Gitter plugin: http://davidwalsh.name/mootools-twitter-plugin
// Aaron Newton’s JSONP plugin: http://clientcide.com/js
// PrettyDate by John Resig at http://ejohn.org/files/pretty.js
//

var tweet_tag = 'p';
var twitter_div = 'twitter_status';

window.addEvent('domready',function() {
	getTwitterStatus(twitter_user);
});

function showTweets(the_tweets, from_cookie){
  if(from_cookie){
    the_tweets = the_tweets.split('^!^!^!^!^');
  }
  $(twitter_div).set('html', '');
  the_tweets.each(function(tweet){
    new Element(tweet_tag,{
  		html: parseTweetDate(tweet)
  	}).inject(twitter_div);
  });
}

function parseTweetDate(tweet){
  tweet = tweet.split('-!-!-!-');
  date = prettyDate(new Date().parse(tweet[1]));
  return tweet[0] + '<span class="pubdate">' + date + '</span>';
}

function prettyDate(time){
	var date = time;
	var diff = (((new Date()).getTime() - date.getTime()) / 1000)
	var day_diff = Math.floor(diff / 86400);
			
	if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
		return;
			
	return day_diff == 0 && (
			diff < 60 && "just now" ||
			diff < 120 && "1 minute ago" ||
			diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
			diff < 7200 && "1 hour ago" ||
			diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
		day_diff == 1 && "1 day ago" ||
		day_diff < 7 && day_diff + " days ago" ||
		day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
}

function getTwitterStatus(twitter_name){
  var tweet_cookie = 'tweets_by_' + twitter_name + tweet_count;
  $(twitter_div).set('html', 'Fetching tweets...');
  if(!Cookie.read(tweet_cookie)) {
  	var myTwitterGitter = new TwitterGitter(twitter_name,{
  	  count: ((show_replies) ? tweet_count : 15 + tweet_count),
  		onComplete: function(tweets,user) {
        the_tweets = Array();
  			tweets.each(function(tweet,i) {
  			  if((tweet.in_reply_to_status_id && show_replies) || !tweet.in_reply_to_status_id){
  			    if(the_tweets.length == tweet_count) return;
  			    tweet.text = tweet.text.replace(/\n/gi, '<br/>');
  			    console.log(tweet);
    			  the_tweets.push(tweet.text + '-!-!-!-' + tweet.created_at);
  				}
  			});
  			Cookie.write(tweet_cookie,the_tweets.join('^!^!^!^!^'), { duration: 1 });
  			showTweets(the_tweets);
  		}
  	}).retrieve();
	} else {
	  showTweets(Cookie.read(tweet_cookie),true);
	}
}

/*
	Plugin:   	TwitterGitter
	Author:   	David Walsh
	Website:    http://davidwalsh.name
	Date:     	2/21/2009
*/

var TwitterGitter = new Class({

	//implements
	Implements: [Options,Events],

	//options
	options: {
		count: 2,
		sinceID: 1,
		link: true,
		onRequest: $empty,
		onComplete: $empty
	},
	
	//initialization
	initialize: function(username,options) {
		//set options
		this.setOptions(options);
		this.info = {};
		this.username = username;
	},
	
	//get it!
	retrieve: function() {
		new JsonP('http://twitter.com/statuses/user_timeline/' + this.username + '.json',{
			data: {
				count: this.options.count,
				since_id: this.options.sinceID
			},
			onRequest: this.fireEvent('request'),
			onComplete: function(data) {
				//linkify?
				if(this.options.link) {
					data.each(function(tweet) { tweet.text = this.linkify(tweet.text); },this);
				}
				//complete!
				this.fireEvent('complete',[data,data[0].user]);
			}.bind(this)
		}).request();
		return this;
	},
	
	//format
	linkify: function(text) {
		//courtesy of Jeremy Parrish (rrish.org)
		return text.replace(/(https?:\/\/\S+)/gi,'<a href="$1">$1</a>').replace(/(^|\s)@(\w+)/g,'$1<a href="http://twitter.com/$2">@$2</a>').replace(/(^|\s)#(\w+)/g,'$1<a href="http://search.twitter.com/search?q=%23$2">#$2</a>');
	}
});
//Compact Jsonp from http://clientcide.com/js
MooTools.More={'version':'1.2.3.1'};var Log=new Class({log:function(){Log.logger.call(this,arguments)}});Log.logged=[];Log.logger=function(){if(window.console&&console.log)console.log.apply(console,arguments);else Log.logged.push(arguments)};Class.refactor=function(original,refactors){$each(refactors,function(item,name){var origin=original.prototype[name];if(origin&&(origin=origin._origin)&&typeof item=='function')original.implement(name,function(){var old=this.previous;this.previous=origin;var value=item.apply(this,arguments);this.previous=old;return value});else original.implement(name,item)});return original};Request.JSONP=new Class({Implements:[Chain,Events,Options,Log],options:{url:'',data:{},retries:0,timeout:0,link:'ignore',callbackKey:'callback',injectScript:document.head},initialize:function(options){this.setOptions(options);this.running=false;this.requests=0;this.triesRemaining=[]},check:function(){if(!this.running)return true;switch(this.options.link){case'cancel':this.cancel();return true;case'chain':this.chain(this.caller.bind(this,arguments));return false}return false},send:function(options){if(!$chk(arguments[1])&&!this.check(options))return this;var type=$type(options),old=this.options,index=$chk(arguments[1])?arguments[1]:this.requests++;if(type=='string'||type=='element')options={data:options};options=$extend({data:old.data,url:old.url},options);if(!$chk(this.triesRemaining[index]))this.triesRemaining[index]=this.options.retries;var remaining=this.triesRemaining[index];(function(){var script=this.getScript(options);this.log('JSONP retrieving script with url: '+script.get('src'));this.fireEvent('request',script);this.running=true;(function(){if(remaining){this.triesRemaining[index]=remaining-1;if(script){script.destroy();this.send(options,index);this.fireEvent('retry',this.triesRemaining[index])}}else if(script&&this.options.timeout){script.destroy();this.cancel();this.fireEvent('failure')}}).delay(this.options.timeout,this)}).delay(Browser.Engine.trident?50:0,this);return this},cancel:function(){if(!this.running)return this;this.running=false;this.fireEvent('cancel');return this},getScript:function(options){var index=Request.JSONP.counter,data;Request.JSONP.counter++;switch($type(options.data)){case'element':data=document.id(options.data).toQueryString();break;case'object':case'hash':data=Hash.toQueryString(options.data)}var src=options.url+(options.url.test('\\?')?'&':'?')+(options.callbackKey||this.options.callbackKey)+'=Request.JSONP.request_map.request_'+index+(data?'&'+data:'');if(src.length>2083)this.log('JSONP '+src+' will fail in Internet Explorer, which enforces a 2083 bytes length limit on URIs');var script=new Element('script',{type:'text/javascript',src:src});Request.JSONP.request_map['request_'+index]=function(data){this.success(data,script)}.bind(this);return script.inject(this.options.injectScript)},success:function(data,script){if(script)script.destroy();this.running=false;this.log('JSONP successfully retrieved: ',data);this.fireEvent('complete',[data]).fireEvent('success',[data]).callChain()}});Request.JSONP.counter=0;Request.JSONP.request_map={};var JsonP=Class.refactor(Request.JSONP,{initialize:function(){var params=Array.link(arguments,{url:String.type,options:Object.type});options=(params.options||{});options.url=options.url||params.url;if(options.callBackKey)options.callbackKey=options.callBackKey;this.previous(options)},getScript:function(options){var queryString=options.queryString||this.options.queryString;if(options.url&&queryString)options.url+=(options.url.indexOf("?")>=0?"&":"?")+queryString;var script=this.previous(options);if($chk(options.globalFunction)){window[options.globalFunction]=function(r){JsonP.requestors[index].handleResults(r)}}return script},request:function(url){this.send({url:url||this.options.url})}});