import py_language

class Given(object):
  def __init__(self, regexp):
    self.regexp = regexp
    
  def __call__(self, f):
    py_language.register_step_def(self.regexp, f)
    return f
  