describe("app.models.Reshare", function(){
   beforeEach(function(){
     this.reshare = new app.models.Reshare({root: {a:"namaste", be : "aloha", see : "community"}});
   });

   describe("rootPost", function(){
     it("should be the root attrs", function(){
       expect(this.reshare.rootPost().get("be")).toBe("aloha");
     });

     it("should return a post", function(){
       expect(this.reshare.rootPost() instanceof app.models.Post).toBeTruthy();
     });

     it("does not create a new object every time", function(){
       expect(this.reshare.rootPost()).toBe(this.reshare.rootPost());
     });
   });

   describe(".reshare", function(){
     it("reshares the root post", function(){
       spyOn(this.reshare.rootPost(), "reshare");
       this.reshare.reshare();
       expect(this.reshare.rootPost().reshare).toHaveBeenCalled();
     });
     
     it("returns something", function() {
      expect(this.reshare.reshare()).toBeDefined();
     });
   });
});

