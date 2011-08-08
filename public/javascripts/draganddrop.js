/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

$(document).ready(function(){
  var hoverCard = Diaspora.widgets.get("hoverCard");

  $('.draggable_person:not(.self)').live("mouseenter", function(){
    if(!$(this).data('draggable'))
      $(this).draggable({
      'cursorAt': { 'left': -5, 'top': -5 },
      'cursor': 'move',
      'start': function(event) {
        var $this = $(this),
            person_id = $this.attr('data-person_id');

        hoverCard.startDragging($this);
        AspectFilters.showMembershipIndicators(person_id);
      },
      'stop': function() {
        hoverCard.stopDragging();
        AspectFilters.hideMembershipIndicators();
      },
      'helper': function(evt){
        return hoverCard.hoverCard.tip;
      },
      'delay': 50,
      });

    $('.droppable_aspect:not(:data(draggable))').droppable({
      'accept': '.draggable_person',
      'hoverClass': 'drophover',
      'activeClass': 'acceptDrop',
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

        var callback = $.proxy(loadingIndicator.onRequestFinished, loadingIndicator);
        var showCheck = function() {
          $('<img class="in_aspect" src="/images/icons/monotone_check_yes.png" style="float: right" />').appendTo(droppable.find('.aspect_selector')).fadeOut(750,'swing');
        }
        Diaspora.ajax.add_person_to_aspect(person_id, aspect_id).complete(callback).success(showCheck);
      },
    });
  });
});
