describe("app.views.Search", function() {
  beforeEach(function(){
    spec.content().html('<form action="#" id="search_people_form"></form>');
    this.view = new app.views.Search({ el: '#search_people_form' });
  });
  describe("parse", function() {
    it("escapes a persons name", function() {
      var person = { 'name': '</script><script>alert("xss");</script' };
      this.view.context = this.view;
      var result = this.view.parse([$.extend({}, person)]);
      expect(result[0].data.name).not.toEqual(person.name);
    });
  });
});
