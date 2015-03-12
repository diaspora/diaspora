describe("app.views.SearchBar", function() {
  beforeEach(function(){
    this.view = new app.views.SearchBar({ el: '#search_people_form' });
  });
  describe("parse", function() {
    it("escapes a persons name", function() {
      $("#jasmine_content").html('<form action="#" id="searchForm"></form>');

      var person = { 'name': '</script><script>alert("xss");</script' };
      var result = this.view.search.parse([$.extend({}, person)]);
      expect(result[0].data.name).not.toEqual(person.name);
    });
  });
});
