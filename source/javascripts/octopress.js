window.addEvent('domready', function() {
  $$('div.highlight').each(addExpander);
});

function addExpander(div){
  new Element('span',{
		html: 'expand &raquo;',
		'class': 'pre_expander',
		'styles': {
      'display': 'block'
    },
    'events': {
      'click': function(){
        toggleExpander();
      }
    }
	}).inject(div, 'top');
}
function toggleExpander(){
  var html = '';
  if($('main').toggleClass('expanded').hasClass('expanded')){
    html = '&laquo; contract';
  } else {
    html = 'expand &raquo;';
  }
  $$('div.highlight span.pre_expander').each(function(span){
      span.set('html',html);
  });
}