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
$.domReady(function () {
  addDivLines();
  preToTable();
});
