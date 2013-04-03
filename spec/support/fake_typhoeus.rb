class FakeHydra
  def queue(*args); end
  def run;   end
end

class FakeHydraRequest
  def initialize(*args);  end
  def on_complete;  end
end

def disable_typhoeus
  silence_warnings do
    Workers::HttpMulti.const_set('Hydra', FakeHydra)
    Workers::HttpMulti.const_set('Request', FakeHydraRequest)
  end
end
def enable_typhoeus
  silence_warnings do
    Workers::HttpMulti.const_set('Hydra', Typhoeus::Hydra)
    Workers::HttpMulti.const_set('Request', Typhoeus::Request)
  end
end
