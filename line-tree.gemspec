Gem::Specification.new do |s|
  s.name = 'line-tree'
  s.version = '0.9.1'
  s.summary = 'line-tree'
  s.description = 'Line-tree parses indented lines of text and returns ' + 
      'an array representing a tree structure.'
  s.authors = ['James Robertson']
  s.email = ['james@jamesrobertson.eu']
  s.homepage = 'http://github.com/jrobertson/line-tree'
  s.files = Dir['lib/line-tree.rb']
  s.add_runtime_dependency('rexle', '~> 1.5', '>=1.5.2') 
  s.signing_key = '../privatekeys/line-tree.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/line-tree'
  s.required_ruby_version = '>= 2.1.2'
end
