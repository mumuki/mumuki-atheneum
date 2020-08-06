source 'https://rubygems.org'
gemspec

ruby '~> 2.3'

gem 'puma'

gem 'execjs'
gem 'therubyracer', platforms: :ruby
gem 'uglifier', '~> 2.7'

group :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker', '~> 2.2'
  gem 'rake', '~> 12.3'
  gem 'capybara', '~> 2.3.0'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-byebug' unless Gem.win_platform?
  gem 'pry-stack_explorer'
  gem 'binding_of_caller'
  gem 'i18n-tasks', '~> 0.8.3'
  gem 'web-console', '~> 3.7.0'
  gem 'codeclimate-test-reporter', require: nil
end

group :development, :test do
  gem 'coffee-script'
  gem 'teaspoon', '~> 1.1.5'
  gem 'teaspoon-jasmine'
  gem "selenium-webdriver"
end

gem 'mumuki-domain', github: 'mumuki/mumuki-domain', branch: 'feature-send-welcome-email-to-users'
gem 'mumukit-login', github: 'mumuki/mumukit-login', branch: 'accept_verified_email_info_from_providers'
