class EventPresenter < BasePresenter
  def base_hash
    {
      event_id: id,
      post_id: status_message.id,
      event_name: name,
      event_date: format_event_date(date),
      event_time: formate_event_time(date),
      event_location: location
    }
   end

   private

   def format_event_date(date)
     date.strftime("%B %e %Y")
   end

   def formate_event_time(date)
     date.strftime("%l:%M %P")
   end
end
