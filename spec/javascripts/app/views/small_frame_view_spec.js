describe("app.views.SmallFrame", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {large : "http://tieguy.org/me.jpg"}}),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ]
    })
    this.view = new app.views.SmallFrame({model : this.model})
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    });

    it("should have an image for each photoAttr on the model", function(){

    })
  })

  describe("textClass", function(){
    it("returns and 'text extra-small' with a post with text longer than 140 characters", function(){
      expect(this.view.textClass()).toBe("text extra-small")
    });

    it("returns 'text medium' if if it is less than 500 characters", function(){
      this.view.model.set({text: "ldfkdfdkfkdfjdkjfdkfjdkjfkdfjdkjfkdjfkdjfdkjdfkjdkfjkdjfkdjfkdfkdjf" +
        "dfkjdkfjkdjfkdjfkdjfdkfjdkfjkd;fklas;dfkjsad;kljf ;laskjf;lkajsdf;kljasd;flkjasd;flkjasdf;l" +
        "jasd;fkjasd;lfkja;sdlkjf;alsdkf;lasdjf;alskdfj;alsdkjf;alsdkfja;sdlkj "})
      expect(this.view.textClass()).toBe("text medium")
    });

    it("returns 'text large' if if it is more than 500 characters", function(){
      this.view.model.set({text: "ldfkdfdkfkdfjdkjfdkfjdkjfkdfjdkjfkdjfkdjfdkjdfkjdkfjkdjfkdjfkdfkdjf" +
        "dfkjdkfjkdjfkdjfkdjfdkfjdkfjkd;fklas;dfkjsad;kljf ;laskjf;lkajsdf;kljasd;flkjasd;flkjasdf;l" +
        "jasd;fkjasd;lfkja;sdlkjf;alsdkf;lasdjf;alskdfj;alsdkjf;alsdkfja;sdlkj f;lkajs;dflkjasd;lfkja;sldkjf;alskdjfs" +
        "as;lkdfj;asldfkj;alsdkjf;laksdjf;lasdkjf;lasdkj;lafkja;sldkjf;alsdkjf;laskjf;laskdjf;laksjdf;laksjdf;lk;" +
        "a;dslkf;laskjdf;lakjsdf;lkasd;lfkja;sldkfj;o sdfsdfsdf" +
        "sdfsdfsdfsdfsdfdsdsfsdfsfsdsfdsf;lgkjs;dlkfj;alsdkjf;laksdjf;lkasjdf;lkajsdf;lkjasd;flkjasd;lfkjas;dlkfj;alsdkjf" +
        "as;dlfk;alsdkjf;lkasdf;lkjasd;flkjasd;lfkjasdkl;" +
        "asl;dkfj;asldkfj;alsdkfj;alsdfjk" +
        "askdjf;laksdf;lkdflkjhasldfhoiawufjkhasugfoiwaufaw "})
      expect(this.view.textClass()).toBe("text large")
    })
  })
})