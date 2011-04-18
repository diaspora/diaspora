Request.Twitter = new Class({

  Extends: Request.JSONP,

  options: {
    linkify: true,
    url: 'http://twitter.com/statuses/user_timeline/{term}.json',
    include_replies: true,
    data: {
      count: 5,
      trim_user: true
    }
  },

  initialize: function(term, options){
    this.parent(options);
    if(this.options.include_replies == false){
      this.options.count = this.options.data.count
      this.options.data.count += 30; // adds 30 tweets to request for filtering
    }
    this.options.url = this.options.url.substitute({term: term});
    console.log(this.options.url);
  },

  success: function(args, index){
    if(!this.options.include_replies){
      args[0] = args[0].filter(function(item, index, array){
        return item.in_reply_to_screen_name == null;
      });
      if(args[0].length > this.options.count){ args[0].length = this.options.count; }
    }
    var data = args[0];

    if (this.options.linkify) data.each(function(tweet){
      tweet.text = this.linkify(tweet.text);
    }, this);

    if (data[0]) this.options.data.since_id = data[0].id; // keep subsequent calls newer

    this.parent(args, index);
  },

  linkify: function(text){
    // modified from TwitterGitter by David Walsh (davidwalsh.name)
    // courtesy of Jeremy Parrish (rrish.org)
    return text.replace(/(https?:\/\/[\w\-:;?&=+.%#\/]+)/gi, '<a href="$1">$1</a>')
    .replace(/(^|\W)@(\w+)/g, '$1<a href="http://twitter.com/$2">@$2</a>')
      .replace(/(^|\W)#(\w+)/g, '$1#<a href="http://search.twitter.com/search?q=%23$2">$2</a>');
  }

});

