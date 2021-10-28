# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "include-generated"
  spec.version       = "1.0.0"
  spec.authors       = ["Kristoffer Richardsson"]
  spec.homepage      = "https://github.com/bitcraze/docker-web-builder"

  spec.summary       = "Include plugin for Jekyll"
  spec.license       = "MIT"

  spec.files         = ["include-generated.rb"]
  spec.require_paths = ["."]

  spec.add_dependency "jekyll", ">= 4.0", "< 5.0"
end
