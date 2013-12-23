
window.onbeforeunload = function() {
	
	var publisherTextLength = $("#status_message_fake_text").val().length;
	var publisherPhotoCount = $("#photodropzone li").length;
	var locationExists = $("#location").length;

	if(publisherTextLength + publisherPhotoCount + locationExists)
	{
		return 'Unsaved data in publisher';	
	}

	

};