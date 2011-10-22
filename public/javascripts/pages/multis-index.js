Diaspora.Pages.MultisIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.aspectNavigation = self.instantiate("AspectNavigation", document.find("ul#aspect_nav"));
    self.stream = self.instantiate("Stream", document.find("#aspect_stream_container"));
    self.infiniteScroll = self.instantiate("InfiniteScroll");


  $('.indicator').tipsy({fade: true, live:true});
  });
};
