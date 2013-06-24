describe("app.Pages.PostViewer", function(){
  describe("postRenderTemplate", function(){
    beforeEach(function(){
      app.setPreload('post', factory.post({frame_name : "note"}).attributes);
      this.page = new app.pages.PostViewer({id : 2});
    })
    it('translates post title from Markdown to plain text and pushes it in document.title', function () {
      this.page.model.set({title : "### My [Markdown](url) *title*" });
      this.page.postRenderTemplate();
      expect(document.title).toEqual("My Markdown title");
    })
  })
});

