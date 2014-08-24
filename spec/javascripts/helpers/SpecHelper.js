// for docs, see http://jasmine.github.io

var realXMLHttpRequest = window.XMLHttpRequest;

beforeEach(function() {
  $('#jasmine_content').html(spec.readFixture("underscore_templates"));

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

  Diaspora.I18n.load({}, 'en', {});

  Diaspora.page = new Page();
  Diaspora.page.publish("page/ready", [$(document.body)]);

  // add custom matchers for flash messages
  jasmine.addMatchers(customMatchers);
});

afterEach(function() {
  //spec.clearLiveEventBindings();

  jasmine.clock().uninstall();
  jasmine.Ajax.uninstall();

  $("#jasmine_content").empty()
  expect(spec.loadFixtureCount).toBeLessThan(2);
  spec.loadFixtureCount = 0;
});


// matches flash messages with success/error and contained text
var flashMatcher = function(flash, id, text) {
  textContained = true;
  if( text ) {
    textContained = (flash.text().indexOf(text) !== -1);
  }

  return flash.is(id) &&
          flash.hasClass('expose') &&
          textContained;
};

var context = describe;
var spec = {};
var customMatchers = {
  toBeSuccessFlashMessage: function(util) {
    return {
      compare: function(actual, expected) {
        var result = {};
        result.pass = flashMatcher(actual, '#flash_notice', expected);
        return result;
      }
    };
  },
  toBeErrorFlashMessage: function(util) {
    return {
      compare: function(actual, expected) {
        var result = {};
        result.pass = flashMatcher(actual, '#flash_error', expected);
        return result;
      }
    };
  }
};

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

window.hipsterIpsumFourParagraphs = "Mcsweeney's mumblecore irony fugiat, ex iphone brunch helvetica eiusmod retro" +
  " sustainable mlkshk. Pop-up gentrify velit readymade ad exercitation 3 wolf moon. Vinyl aute laboris artisan irony, " +
  "farm-to-table beard. Messenger bag trust fund pork belly commodo tempor street art, nihil excepteur PBR lomo laboris." +
  " Cosby sweater american apparel occupy, locavore odio put a bird on it fixie kale chips. Pariatur semiotics flexitarian " +
  "veniam, irure freegan irony tempor. Consectetur sriracha pour-over vice, umami exercitation farm-to-table master " +
  "cleanse art party." + "\n" +

  "Quinoa nostrud street art helvetica et single-origin coffee, stumptown bushwick selvage skateboard enim godard " +
  "before they sold out tumblr. Portland aesthetic freegan pork belly, truffaut occupy assumenda banksy 3 wolf moon " +
  "irure forage terry richardson nulla. Anim nostrud selvage sartorial organic. Consequat pariatur aute fugiat qui, " +
  "organic marfa sunt gluten-free mcsweeney's elit hella whatever wayfarers. Leggings pariatur chambray, ullamco " +
  "flexitarian esse sed iphone pinterest messenger bag Austin cred DIY. Duis enim squid mcsweeney's, nisi lo-fi " +
  "sapiente. Small batch vegan thundercats locavore williamsburg, non aesthetic trust fund put a bird on it gluten-free " +
  "consectetur." + "\n" +

  "Viral reprehenderit iphone sapiente exercitation. Enim nostrud letterpress, tempor typewriter dreamcatcher tattooed." +
  " Ex godard pariatur voluptate est, polaroid hoodie ea nulla umami pickled tempor portland. Nostrud food truck" +
  "single-origin coffee skateboard. Fap enim tumblr retro, nihil twee trust fund pinterest non jean shorts veniam " +
  "fingerstache small batch. Cred whatever photo booth sed, et dolore gastropub duis freegan. Authentic quis butcher, " +
  "fanny pack art party cupidatat readymade semiotics kogi consequat polaroid shoreditch ad four loko." + "\n" +

  "PBR gluten-free ullamco exercitation narwhal in godard occaecat bespoke street art veniam aesthetic jean shorts " +
  "mlkshk assumenda. Typewriter terry richardson pork belly, cupidatat tempor craft beer tofu sunt qui gentrify eiusmod " +
  "id. Letterpress pitchfork wayfarers, eu sunt lomo helvetica pickled dreamcatcher bicycle rights. Aliqua banksy " +
  "cliche, sapiente anim chambray williamsburg vinyl cardigan. Pork belly mcsweeney's anim aliqua. DIY vice portland " +
  "thundercats est vegan etsy, gastropub helvetica aliqua. Artisan jean shorts american apparel duis esse trust fund."

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
