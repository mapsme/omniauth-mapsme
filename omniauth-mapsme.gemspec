# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-mapsme/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-mapsme"
  spec.version       = Omniauth::Mapsme::VERSION
  spec.authors       = ["Ilya Zverev"]
  spec.email         = ["ilya@zverev.info"]

  spec.summary       = %q{MAPS.ME passport strategy for OmniAuth}
  spec.description   = %q{MAPS.ME passport strategy for OmniAuth. Uses provided access token.}
  spec.homepage      = "http://maps.me"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth-oauth2", ">= 1.1.1"
end
