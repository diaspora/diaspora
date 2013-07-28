describe("app.Pages.PostViewer", function(){
  describe("postRenderTemplate", function(){
    beforeEach(function(){
      this.view = new app.pages.PostViewer({id : 4});
    })
    it('translates post title from Markdown to plain text and pushes it in document.title', function () {
      this.view.model.set({title : "### My [Markdown](url) *title*" });
      this.view.postRenderTemplate();
      expect(document.title).toEqual("My Markdown title");
    })
  })
});
