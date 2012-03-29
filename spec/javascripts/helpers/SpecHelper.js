// Add custom matchers here, in a beforeEach block. Example:
//beforeEach(function() {
//  this.addMatchers({
//    toBePlaying: function(expectedSong) {
//      var player = this.actual;
//      return player.currentlyPlayingSong === expectedSong
//          && player.isPlaying;
//    }
//  })
//});

beforeEach(function() {
  $('#jasmine_content').html(spec.readFixture("underscore_templates"));

  // NOTE Commented (as well as in afterEach) to keep the listeners from rails.js alive.
  //spec.clearLiveEventBindings();
  jasmine.Clock.useMock();


  Diaspora.Pages.TestPage = function() {
    var self = this;
    this.subscribe("page/ready", function() {
      self.directionDetector = self.instantiate("DirectionDetector");
    });
  };

  var Page = Diaspora.Pages["TestPage"];
  $.extend(Page.prototype, Diaspora.EventBroker.extend(Diaspora.BaseWidget));

  Diaspora.page = new Page();
  Diaspora.page.publish("page/ready", [$(document.body)])
});

afterEach(function() {
  //spec.clearLiveEventBindings();
  $("#jasmine_content").empty()
  expect(spec.loadFixtureCount).toBeLessThan(2);
  spec.loadFixtureCount = 0;
});

var context = describe;
var spec = {};

window.stubView = function stubView(text){
  var stubClass = Backbone.View.extend({
    render : function(){
      $(this.el).html(text);
      return this
    }
  })

  return new stubClass
}

window.loginAs = function loginAs(attrs){
  return app.currentUser = app.user(factory.userAttrs(attrs))
}

window.logout = function logout(){
  this.app._user = undefined
  return app.currentUser = new app.models.User()
}

spec.clearLiveEventBindings = function() {
  var events = jQuery.data(document, "events");
  for (prop in events) {
    delete events[prop];
  }
};

spec.content = function() {
  return $('#jasmine_content');
};

// Loads fixure markup into the DOM as a child of the jasmine_content div
spec.loadFixture = function(fixtureName) {
  var $destination = $('#jasmine_content');

  // get the markup, inject it into the dom
  $destination.html(spec.fixtureHtml(fixtureName));

  // keep track of fixture count to fail specs that
  // call loadFixture() more than once
  spec.loadFixtureCount++;
};


// Returns fixture markup as a string. Useful for fixtures that
// represent the response text of ajax requests.
spec.readFixture = function(fixtureName) {
  return spec.fixtureHtml(fixtureName);
};

spec.fixtureHtml = function(fixtureName) {
  if (!spec.cachedFixtures[fixtureName]) {
    spec.cachedFixtures[fixtureName] = spec.retrieveFixture(fixtureName);
  }
  return spec.cachedFixtures[fixtureName];
};

spec.retrieveFixture = function(fixtureName) {

  // construct a path to the fixture, including a cache-busting timestamp
  var path = '/tmp/js_dom_fixtures/' + fixtureName + ".fixture.html?" + new Date().getTime();
  var xhr;

  // retrieve the fixture markup via xhr request to jasmine server
  try {
    xhr = new jasmine.XmlHttpRequest();
    xhr.open("GET", path, false);
    xhr.send(null);
  } catch(e) {
    throw new Error("couldn't fetch " + path + ": " + e);
  }
  var regExp = new RegExp(/Couldn\\\'t load \/fixture/);
  if (regExp.test(xhr.responseText)) {
    throw new Error("Couldn't load fixture with key: '" + fixtureName + "'. No such file: '" + path + "'.");
  }

  return xhr.responseText;
};


spec.loadFixtureCount = 0;
spec.cachedFixtures = {};
