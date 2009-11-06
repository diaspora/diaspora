//
// The Octopress Twitter Feed is based on the following work:
// Valerio's javascript framework Mootools: Mootools.net
// David Walsh's Twitter Gitter plugin: http://davidwalsh.name/mootools-twitter-plugin
// Aaron Newton’s JSONP plugin: http://clientcide.com/js
//

var username = 'imathis';
var filter_mentions = true;
var tweet_count = 5;
var tweet_tag = 'p';
var twitter_div = 'twitter_status';
var tweet_cookie = 'the_tweets_' + username;

window.addEvent('domready',function() {
	getTwitterStatus();
});

function showTweets(the_tweets, from_cookie){
  if(from_cookie){
    the_tweets = the_tweets.split('^!^!^!^!^');
  }
  $(twitter_div).set('html', '');
  the_tweets.each(function(tweet){
    new Element(tweet_tag,{
  		html: tweet
  	}).inject(twitter_div);
  });
}

function getTwitterStatus(){
  $(twitter_div).set('html', 'Fetching tweets...');
  if(!Cookie.read(tweet_cookie)) {
  	var myTwitterGitter = new TwitterGitter(username,{
  	  count: ((!filter_mentions) ? tweet_count : 15 + tweet_count),
  		onComplete: function(tweets,user) {
        the_tweets = Array();
  			tweets.each(function(tweet,i) {
  			  if((tweet.in_reply_to_status_id && !filter_mentions) || !tweet.in_reply_to_status_id){
  			    if(the_tweets.length == tweet_count) return;
  			    tweet.text = tweet.text.replace(/\n/gi, '<br/>');
    			  the_tweets.push(tweet.text);
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