$(function () {  
  $('#main_stream .pagination a').live('click', function () {  
      $.getScript(this.href);  
      return false;  
    }
  );
});
