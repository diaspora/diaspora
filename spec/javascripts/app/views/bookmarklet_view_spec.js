
describe('app.views.Bookmarklet', function() {
  var test_data = {
    url: 'https://www.youtube.com/watch?v=0Bmhjf0rKe8',
    title: 'Surprised Kitty',
    notes: 'cute kitty'
  };
  var evil_test_data = _.extend({}, {
    notes: "**love** This is such a\n\n great \"cute kitty\" '''blabla''' %28%29\\"
  }, test_data);

  var init_bookmarklet = function(data) {
    app.bookmarklet = new app.views.Bookmarklet(
      _.extend({el: $('#bookmarklet')}, data)
    ).render();
  };

  beforeEach(function() {
    app.stream = null;  // avoid rendering posts
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    spec.loadFixture('bookmarklet');
  });

  it('initializes a standalone publisher', function() {
    new app.views.Bookmarklet();
    expect(app.publisher).not.toBeNull();
    expect(app.publisher.standalone).toBeTruthy();
  });

  it('prefills the publisher', function() {
    init_bookmarklet(test_data);

    expect($.trim(app.publisher.el_input.val())).not.toEqual('');
    expect($.trim(app.publisher.el_hiddenInput.val())).not.toEqual('');
  });

  it('handles dirty input well', function() {
    init_bookmarklet(evil_test_data);

    expect($.trim(app.publisher.el_input.val())).not.toEqual('');
    expect($.trim(app.publisher.el_hiddenInput.val())).not.toEqual('');
  });

  it('allows changing a prefilled publisher', function() {
    init_bookmarklet(test_data);
    app.publisher.setText(app.publisher.el_input.val()+'A');

    expect(app.publisher.el_hiddenInput.val()).toMatch(/.+A$/);
  });

  it('keeps the publisher disabled after successful post creation', function() {
    jasmine.Ajax.install();

    init_bookmarklet(test_data);
    spec.content().find('form').submit();

    jasmine.Ajax.requests.mostRecent().response({
      status: 200,  // success!
      responseText: "{}"
    });

    expect(app.publisher.disabled).toBeTruthy();
  });
});
