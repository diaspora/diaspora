window.addEvent('domready', function() {
  codeblocks = $$('div.highlight');
  codeblocks.each(addExpander);
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