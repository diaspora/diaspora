ActsAsFerret::define_index( 'post_index',
    :models => {
      Post => {
	:fields => {
	  :text => { :boost => 4, :store => :yes, :via => :ferret_content },
	}
      }
    } )
