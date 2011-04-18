window.addEvent('domready', function() {
  codeblocks = $$('div.highlight');
  codeblocks.each(addExpander);
});

window.addEvents({
  domready: function(){
    if(twitter_user){
      new Request.Twitter(twitter_user, {
        include_replies: false,
        data: { count: 3 },
        onSuccess: function(tweets){
          $('tweets').empty();
          for (var i = tweets.length; i--; ){
            new Element('li', {
              'class': 'tweet'
              }).adopt(
              new Element('p', { 'html': tweets[i].text+' ' }).adopt(
                new Element('a', {
                  'href': 'http://twitter.com/'+twitter_user+'/status/'+tweets[i].id_str,
                  'text': new Date(tweets[i].created_at).timeDiffInWords()
                }))
            ).inject('tweets', 'top');
          }
        }
      }).send();
    }
    $$('#recent_posts time').each(function(date){
      date.set('text', new Date(date.get('text')).timeDiffInWords());
    });
  },
});


function addExpander(div){
  new Element('span',{
		html: 'expand &raquo;',
		'class': 'pre_expander',
    'events': {
      'click': function(){
        toggleExpander(this);
      }
    }
	}).inject(div, 'top');
}
function toggleExpander(expander){
  var html = '';
  var expanderPos = expander.getPosition().y;
  if($('page').toggleClass('expanded').hasClass('expanded'))
    html = '&laquo; contract';
  else
    html = 'expand &raquo;';
  $$('div.highlight span.pre_expander').each(function(span){
      span.set('html',html);
  });
  fixScroll(expander, expanderPos);
}
function fixScroll(el, position){
  pos = el.getPosition().y - position;
  window.scrollTo(window.getScroll().x ,window.getScroll().y + pos);
}
function enableCompressedLayout(codeblocks){
  if(!codeblocks.length) return;
  new Element('span',{
		html: 'Collapse layout',
		'id': 'collapser',
    'events': {
      'click': function(){
        if($('page').toggleClass('collapsed').hasClass('collapsed'))
          this.set('html','Expand layout');
        else
          this.set('html','Collapse layout');
      }
    }
	}).inject($('main'), 'top');
}
