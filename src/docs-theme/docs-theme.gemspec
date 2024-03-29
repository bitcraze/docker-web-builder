# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "docs-theme"
  spec.version       = "0.2.0"
  spec.authors       = ["Kristoffer Richardsson"]

  spec.summary       = "Simple jekyll theme for docs locally"
  spec.license       = "MIT"

  spec.files         = spec.files = Dir['_includes/*'] + Dir['_layouts/*'] + Dir['assets/*']

  spec.add_runtime_dependency "jekyll", "~> 3.8"

end
