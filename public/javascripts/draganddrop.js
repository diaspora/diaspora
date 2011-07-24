$(document).ready(function(){
  var hoverCard = Diaspora.widgets.get("hoverCard");

  $('.draggable_person:not(.self)').draggable({
    'cursorAt': { 'left': -5, 'top': -5 },
    'cursor': 'move',
    'start': function(event) {
      hoverCard.startDragging($(this));
    },
    'stop': function() {
      hoverCard.stopDragging();
    },
    'helper': function(evt){
      return hoverCard.hoverCard.tip;
    },
    'delay': 50,
  });

  $('.droppable_aspect').droppable({
    'accept': '.draggable_person',
    'hoverClass': 'drophover',
    'tolerance': 'pointer',
    'drop': function(event, ui){
      var droppable = $(this);
      var person_id = ui.draggable.attr('data-person_id'),
          aspect_id = droppable.attr('data-aspect_id');

      var loadingIndicator = function() {
        this.self = this;
        this.dom = droppable.find('#loading');

        this.pendingRequests = function() {
          return parseInt(self.dom.attr('pending'));
        };

        this.init = function() {
          if(self.dom.length==0){
            self.dom = $('<img id="loading" pending="1" src="/images/ajax-loader.gif" style="float: right" />');
            self.dom.appendTo(droppable.find('.aspect_selector'));
          }
          else
            self.dom.attr('pending', self.pendingRequests()+1);
        };

        this.onRequestFinished = function() {
          self.dom.attr('pending', self.pendingRequests()-1);

          if(self.pendingRequests()==0)
            self.dom.remove();
        };

        self.init();
        return self;
      }();

      var callback = $.proxy(loadingIndicator.onRequestFinished, loadingIndicator)
      Diaspora.ajax.add_person_to_aspect(person_id, aspect_id).complete(callback);
    },
  });
});
