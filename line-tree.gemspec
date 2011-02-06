Gem::Specification.new do |s|
  s.name = 'line-tree'
  s.version = '0.3.2'
  s.summary = 'line-tree'
  s.description = 'Line-tree parses indented lines of text and returns an array representing a tree structure.'
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('rexle')
end
