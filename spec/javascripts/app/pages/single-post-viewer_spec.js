describe("app.pages.SinglePostViewer", function(){
  beforeEach(function() {
    window.gon = {};
    gon.post = $.parseJSON(spec.readFixture("post_json"));
    this.view = new app.pages.SinglePostViewer();
  });

  context("#initialize", function() {
    it("uses post-id from gon", function() {
      expect(this.view.model.id).toBe(gon.post.id);
    });
  });
});
