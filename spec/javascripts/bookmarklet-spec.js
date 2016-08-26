describe("bookmarklet", function(){
  var fakeUrl = "http://pod.example.com/bookmarklet";

  it("opens a popup window", function(){
    spyOn(window, "open").and.returnValue(true);
    bookmarklet(fakeUrl, 800, 600);
    jasmine.clock().tick(1);
    expect(window.open).toHaveBeenCalled();
  });

  it("shortens the GET string to less than 2000 characters", function(){
    var url,
        selTxt = new Array(1000).join("abcdefghijklmnopqrstuvwxyz1234567890");

    spyOn(window, "open").and.callFake(function(_url){
      url = _url;
      return true;
    });
    spyOn(window, "getSelection").and.returnValue(selTxt);

    bookmarklet(fakeUrl, 800, 600);
    jasmine.clock().tick(1);
    expect(url.length).toBeLessThan(2000);
  });
});
