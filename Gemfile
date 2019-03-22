source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.1'

gem 'rails', '~> 5.2.0'
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem "jquery-rails"
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'
gem 'jquery-form-rails'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'slim-rails', '3.1.3'
gem 'devise'
gem 'bootstrap-sass'
gem 'kaminari'
gem "select2-rails"
gem 'miyabi'
gem 'html2slim'
gem 'cocoon'
gem 'carrierwave'
gem 'rmagick'
gem 'fog'
gem "activerecord-import"
gem 'prawn'
gem 'prawn-table'
gem 'exception_notification', :github => 'smartinez87/exception_notification'
gem 'slack-notifier'
gem 'rails-i18n'
gem 'dotenv-rails'
gem 'devise-bootstrap-views'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'ranked-model'
gem 'active_hash'
gem 'deep_cloneable'
gem 'simple_calendar', '~> 2.0'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bullet'
  gem 'rails-erd'
  gem "letter_opener"
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :production do
  gem 'rails_12factor'
end
