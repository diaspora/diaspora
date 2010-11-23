var Mobile = {
  initialize : function(){
    $('#aspect_picker').change(Mobile.changeAspect);
  },
  
  changeAspect : function() {
    Mobile.windowLocation('/aspects/' + $('#aspect_picker option:selected').val());
  },
  
  windowLocation : function(url) {
    window.location = url;
  },
};

