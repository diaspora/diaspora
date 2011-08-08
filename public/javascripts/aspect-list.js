$(document).ready(function(){
  Diaspora.widgets.subscribe("aspect/personAdded", function(evt, aspectId, personId) {
    $('#aspect_nav [data-aspect_id='+aspectId+'] .contact_count').each(function() {
      var $this = $(this);
          count = parseInt($this.html());
      $this.html(count+1);
    });
  });

  Diaspora.widgets.subscribe("aspect/personRemoved", function(evt, aspectId, personId) {
    $('#aspect_nav [data-aspect_id='+aspectId+'] .contact_count').each(function() {
      var $this = $(this);
          count = parseInt($this.html());
      $this.html(count-1);
    });
  });
});
