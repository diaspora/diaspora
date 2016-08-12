describe("app.views.NoPostsInfo", function() {
  describe("render", function() {
    beforeEach(function() {
      this.view = new app.views.NoPostsInfo();
    });

    it("renders the no posts info message", function() {
      expect(this.view.render().$el.text().trim()).toBe(Diaspora.I18n.t("stream.no_posts_yet"));
    });
  });
});
