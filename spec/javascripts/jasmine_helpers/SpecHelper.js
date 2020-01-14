// for docs, see http://jasmine.github.io

var realXMLHttpRequest = window.XMLHttpRequest;

// matches flash messages with success/error and contained text
var flashMatcher = function(flash, klass, text) {
  var textContained = true;
  if(text) {
    textContained = (flash.text().trim().indexOf(text) !== -1);
  }
  return flash.hasClass(klass) && flash.parent().hasClass("expose") && textContained;
};

// information for jshint
/* exported context */
var context = describe;

var spec = {};
var customMatchers = {
  toBeSuccessFlashMessage: function() {
    return {
      compare: function(actual, expected) {
        var result = {};
        result.pass = flashMatcher(actual, "alert-success", expected);
        return result;
      }
    };
  },
  toBeErrorFlashMessage: function() {
    return {
      compare: function(actual, expected) {
        var result = {};
        result.pass = flashMatcher(actual, "alert-danger", expected);
        return result;
      }
    };
  }
};

beforeEach(function() {
  jasmine.clock().install();
  jasmine.Ajax.install();

  Diaspora.Pages.TestPage = function() {
    var self = this;
    this.subscribe("page/ready", function() {
      self.directionDetector = self.instantiate("DirectionDetector");
    });
  };

  var Page = Diaspora.Pages["TestPage"];
  $.extend(Page.prototype, Diaspora.EventBroker.extend(Diaspora.BaseWidget));

  Diaspora.page = new Page();
  Diaspora.page.publish("page/ready", [$(document.body)]);

  // don't change window.location in jasmine tests
  app._changeLocation = function() { /* noop */ };
  Diaspora.Mobile.changeLocation = function() { /* noop */ };

  // add custom matchers for flash messages
  jasmine.addMatchers(customMatchers);

  // PhantomJS 1.9.8 doesn't support bind yet
  // See https://github.com/ariya/phantomjs/issues/10522
  // and https://github.com/colszowka/phantomjs-gem
  /* jshint -W121 */
  Function.prototype.bind = Function.prototype.bind || function (thisp) {
    var fn = this;
    return function () {
      return fn.apply(thisp, arguments);
    };
  };
  /* jshint +W121 */

  // add gon defaults
  window.gon = {
    appConfig: {
      settings: {podname: "MyPod"},
      map: {
        mapbox: {
          enabled: false,
          /* eslint-disable camelcase */
          access_token: null,
          /* eslint-enable camelcase */
          style: "mapbox/streets-v9"
        }
      }
    },
    preloads: {}
  };
});

afterEach(function() {
  jasmine.clock().uninstall();
  jasmine.Ajax.uninstall();

  $(".modal").removeClass("fade").modal("hide");
  $("#jasmine_content").empty();
  expect(spec.loadFixtureCount).toBeLessThan(2);
  expect($(".modal-backdrop").length).toBe(0);
  $(".modal-backdrop").remove();
  spec.loadFixtureCount = 0;
  $(document.body).off();
});


window.stubView = function stubView(text){
  var stubClass = Backbone.View.extend({
    render : function(){
      $(this.el).html(text);
      return this;
    }
  });

  return new stubClass();
};

window.loginAs = function loginAs(attrs){
  app.currentUser = app.user(factory.userAttrs(attrs));
  return app.currentUser;
};

window.logout = function logout(){
  this.app._user = undefined;
  app.currentUser = new app.models.User();
  return app.currentUser;
};

spec.content = function() {
  return $("#jasmine_content");
};

// Loads fixure markup into the DOM as a child of the jasmine_content div
spec.loadFixture = function(fixtureName) {
  var $destination = $("#jasmine_content");

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
  var path = "/tmp/js_dom_fixtures/" + fixtureName + ".fixture.html?" + new Date().getTime();
  var xhr;

  // retrieve the fixture markup via xhr request to jasmine server
  try {
    xhr = new realXMLHttpRequest();
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

spec.defaultLocale = JSON.parse(spec.readFixture("locale_en_javascripts_json"));
Diaspora.I18n.reset(spec.defaultLocale);
