Gem::Specification.new do |s|
  s.name = 'line-tree'
  s.version = '0.4.3'
  s.summary = 'line-tree'
  s.description = 'Line-tree parses indented lines of text and returns an array representing a tree structure.'
  s.authors = ['James Robertson']
  s.email = ['james@r0bertson.co.uk']
  s.homepage = 'http://github.com/jrobertson/line-tree'
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('rexle', '~> 1.0', '>=1.0.33') 
  s.signing_key = '../privatekeys/line-tree.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/line-tree'
  s.required_ruby_version = '>= 2.1.2'
end
