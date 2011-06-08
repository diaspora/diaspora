function getNav(){
  var fieldset = $('body > nav fieldset[role=site-search]').after('<fieldset role="mobile-nav"></fieldset>').next();
  var select = $(fieldset).append('<select></select>').children();
  select.append('<option value="">Navigate&hellip;</option>');
  $($('body > nav ul[role=main-nav] a').concat($('body > nav ul[role=subscription] a'))).each(function(link) {
    select.append('<option value="'+link.href+'">&bull; '+link.text+'</option>')
  });
  select.bind('change', function(event){
    if (select.val()) window.location.href = select.val();
  });
}
function addSidebarToggler() {
  $('#articles').before('<a href="#" class="toggle-sidebar">&raquo;</a>').previous().bind('click', function(e){
    e.preventDefault();
    if($('body').hasClass('collapse-sidebar')){
      $('body').removeClass('collapse-sidebar');
      e.target.innerHTML = '&raquo;';
    } else {
      $('body').addClass('collapse-sidebar');
      e.target.innerHTML = '&laquo;';
    }
  });
}
function testFeatures() {
  var features = ['maskImage'];
  $(features).map(function(feature){
    if (Modernizr.testAllProps(feature)) {
      $('html').addClass(feature);
    } else {
      $('html').addClass('no-'+feature);
    }
  });
  if ("placeholder" in document.createElement("input")) {
    $('html').addClass('placeholder');
  } else {
    $('html').addClass('no-placeholder');
  }
}

function addDivLines(){
  $('div.highlight pre code').each(function(el){
    var content = bonzo(el).html();
    var lines = content.split('\n');
    var count = lines.length;
    bonzo(lines).each(function(line, index){
      if(line == '') line = ' ';
      lines[index] = '<div class="line">' + line + '</div>';
    });
    $(el).html(lines.join(''));
  });
}
function preToTable(){
  $('div.highlight').each(function(code){
    var tableStart = '<table cellpadding="0" cellspacing="0"><tbody><tr><td class="gutter">';
    var lineNumbers = '<pre class="line-numbers">';
    var tableMiddle = '</pre></td><td class="code" width="100%">';
    var tableEnd = '</td></tr></tbody></table>';
    var count = $('div.line', code).length;
    for (i=1;i<=count; i++){
      lineNumbers += '<span class="line">'+i+'</span>\n';
    }
    table = tableStart + lineNumbers + tableMiddle + '<pre>'+$('pre', code).html()+'</pre>' + tableEnd;
    $(code).html(table);
  });
}
$.domReady(function(){
  testFeatures();
  addDivLines();
  preToTable();
  getNav();
  addSidebarToggler();
});

// iOS scaling bug fix
// Rewritten version
// By @mathias, @cheeaun and @jdalton
// Source url: https://gist.github.com/901295
(function(doc) {
  var addEvent = 'addEventListener',
  type = 'gesturestart',
  qsa = 'querySelectorAll',
  scales = [1, 1],
  meta = qsa in doc ? doc[qsa]('meta[name=viewport]') : [];
  function fix() {
    meta.content = 'width=device-width,minimum-scale=' + scales[0] + ',maximum-scale=' + scales[1];
    doc.removeEventListener(type, fix, true);
  }
  if ((meta = meta[meta.length - 1]) && addEvent in doc) {
    fix();
    scales = [.25, 1.6];
    doc[addEvent](type, fix, true);
  }
}(document));
