#dispatching
#a class that figures out the markup of an object
class Federated::Presenter
end

#a class that detects the audience of a post
class Federated::Audience
end

#this class dispatchs the post to services, like facebook, twitter, etc
class ServiceDispatcher
  #interacts with a single post, and many provided services
end

#Receiving Phases
  #receive request => check author
  #xml payload
  #decode
  #convert to meta object
    #perfom various validations
  #recieve! <= save object, if applicable
  #after_receive hook


  Ideas:
    Federated objects are delegated stubs of real objects, with converstion constuctors
      - this turns receive to "make model level object from payload"
      - seperate validations and checking with persistance and noticiation layer



    http => deserliaization/decoding/descrypting => meta object => validations => receive => cleanup

