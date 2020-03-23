# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "docs-theme"
  spec.version       = "0.1.0"
  spec.authors       = ["Kristoffer Richardsson"]

  spec.summary       = "Simple jekyll theme for docs locally"
  spec.license       = "MIT"

  spec.files         = spec.files = Dir['_includes/*'] + Dir['_layouts/*'] + Dir['assets/*']

  spec.add_runtime_dependency "jekyll", "~> 3.8"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
end
