
(function(){
  app.helpers.showModal = function(id, statusMessagePath, title){
    $(id).modal();

    var $modalTitle = $(id).find(".modal-title");

    if($('showMentionModal').modal()) {
      if(statusMessagePath){
        if($modalTitle.data("original-title") == null){
          $modalTitle.data("original-title", $modalTitle[0].textContent);
        }

        var modalBody = $(id).find(".modal-body");

        $modalTitle.text(title);
        modalBody.load(statusMessagePath, function(){
          $(id).find("#modalWaiter").remove();
        });
      }
      else{
      	if($modalTitle.data("original-title") != null){
          $modalTitle.text($modalTitle.data("original-title"));
        }
        var profileMention = $(id).find(".modal-body");

        var url = $(id).attr("href");
        profileMention.load(url, function(){
          $(id).find("#modalWaiter").remove();
        });
      }
    }
  };
})();
