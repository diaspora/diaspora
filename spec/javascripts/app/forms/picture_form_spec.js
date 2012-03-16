describe("app.forms.Picture", function(){
  beforeEach(function(){
    $("<meta/>", {
      "name" : "csrf-token",
      "content" : "supersecrettokenlol"
    }).prependTo("head")

    this.form = new app.forms.Picture().render()
  });

  it("sets the authenticity token from the meta tag", function(){
    expect(this.form.$("input[name='authenticity_token']").val()).toBe("supersecrettokenlol")
  });

  describe("selecting a photo", function(){
    it("submits the form", function(){
      var submitSpy = jasmine.createSpy();

      this.form.$("form").submit(function(event){
        event.preventDefault();
        submitSpy();
      });

      this.form.$("input[name='photo[user_file]']").change()
      expect(submitSpy).toHaveBeenCalled();
    })
  });

  describe("when a photo is suceessfully submitted", function(){
    beforeEach(function(){
      this.photoAttrs = { name : "Obama rides a bicycle" }
      this.respond = function() {
        this.form.$(".new_photo").trigger("ajax:complete", {
          responseText : JSON.stringify({success : true, data : this.photoAttrs})
        })
      }
    })

    it("adds a new model to the photos", function(){
      expect(this.form.$(".photos div").length).toBe(0);
      this.respond()
      expect(this.form.$(".photos div").length).toBeGreaterThan(0);
    })
  })

  describe("when a photo is unsuccessfully submitted", function(){
    beforeEach(function(){
      this.response = {responseText : JSON.stringify({success : false, message : "I like to eat basketballs"}) }
    })

    it("adds a new model to the photos", function(){
      spyOn(window, "alert")
      this.form.$(".new_photo").trigger("ajax:complete", this.response)
      expect(window.alert).toHaveBeenCalled();
    })
  })
});