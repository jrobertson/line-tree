Gem::Specification.new do |s|
  s.name = 'line-tree'
  s.version = '0.3.7'
  s.summary = 'line-tree'
  s.description = 'Line-tree parses indented lines of text and returns an array representing a tree structure.'
  s.authors = ['James Robertson']
  s.email = ['james@r0bertson.co.uk']
  s.homepage = 'http://github.com/jrobertson/line-tree'
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('rexle')
end
