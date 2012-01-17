describe("app.models.Reshare", function(){
   describe("rootPost", function(){
     beforeEach(function(){
       this.reshare = new app.models.Reshare({root: {a:"namaste", be : "aloha", see : "community"}})
     });

     it("should be the root attrs", function(){
       expect(this.reshare.rootPost().get("be")).toBe("aloha")
     });

     it("should return a post", function(){
       expect(this.reshare.rootPost() instanceof app.models.Post).toBeTruthy()
     });

     it("does not create a new object every time", function(){
       expect(this.reshare.rootPost()).toBe(this.reshare.rootPost())
     });
   });
});

