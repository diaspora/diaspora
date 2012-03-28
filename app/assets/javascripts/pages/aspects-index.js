Diaspora.Pages.AspectsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.aspectNavigation = self.instantiate("AspectNavigation", document.find("ul#aspect_nav"));
  });
};
