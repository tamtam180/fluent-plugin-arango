# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-arango"
  gem.version       = File.read("VERSION").strip
  gem.authors       = ["tamtam180"]
  gem.email         = ["kirscheless@gmail.com"]
  gem.description   = %q{ArangoDB plugin for Fluent event collector}
  gem.summary       = %q{ArangoDB plugin for Fluent event collector}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "ashikawa-core"

end
