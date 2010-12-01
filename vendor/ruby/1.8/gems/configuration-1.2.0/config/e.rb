Configuration.for('e'){
  foo 42

  if Send('respond_to?', 'foo')
    bar 'forty-two'
  end

  respond_to = Method('bar')

  if respond_to.call()
    foobar 42.0 
  end
}
