
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_khipu_integration/version'

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = 'spree_khipu_integration'
  spec.version       = SpreeKhipuIntegration::VERSION
  spec.authors       = ['chinoxchen']
  spec.email         = ['chienfu.udp@gmail.com']

  spec.summary       = 'Spree integration with Khipu'
  spec.description   = 'Spree integration with Khipu'
  spec.homepage      = 'https://github.com/chinoxchen/spree_khipu_integration'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spree_version = '>= 4.0.0', '< 5.0'
  spec.add_dependency 'spree_core', spree_version
  spec.add_dependency 'spree_api', spree_version
  spec.add_dependency 'spree_backend', spree_version
  spec.add_dependency 'spree_extension'

  #spec.add_dependency 'spree_core', '~> 4.1.7'
  #spec.add_dependency 'spree_frontend', '~> 4.1.7'
  #
  spec.add_dependency 'khipu-api-client', '~> 2.9.1'

  #spec.add_development_dependency 'bundler', '>= 2.0'
  #spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'capybara', '~> 2.1'
  spec.add_development_dependency 'coffee-rails'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'ffaker'
  spec.add_development_dependency 'rspec-rails', '~> 4.0.0'
  spec.add_development_dependency 'sass-rails'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'spree_dev_tools'
end
