Gem::Specification.new do |g|
  g.name    = 'tractor'
  g.version = '0.0.0'
  g.summary = 'An Erlang-style messaging for Ruby processes.'
  g.authors = ['Anatoly Chernow']

  g.add_dependency 'redis'
  g.add_dependency 'suppress_output'
end
