file 'Gemfile', <<-GEMFILE
source 'http://rubygems.org'

gem 'rails',                      '~> 3.0.3'
gem 'will_paginate',              '~> 3.0.pre2'
gem 'compass'
gem 'haml'
gem 'fancy-buttons'
gem 'simple_form'
gem 'devise'
gem 'devise_invitable'
gem 'stateflow'
gem 'site_meta'


# Reports
# gem 'ruport'
# gem 'ruport-util',                :require => 'ruport/util'

# gem 'hoptoad_notifier'

gem 'bson'
gem 'bson_ext'
gem 'mongo'
gem 'mongoid',      :git => 'git://github.com/mongoid/mongoid.git',         :branch => 'master'
gem 'carrierwave',  :git => "git://github.com/jnicklas/carrierwave.git"
gem 'mini_magick',  :git => 'git://github.com/probablycorey/mini_magick.git'

group :test, :development do
  gem 'rocco'
  gem 'autotest'
  gem 'webrat'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'rails3-generators'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capistrano'
  gem 'colored'
  gem 'steak',                    '~> 1.0.0.rc.4'
  gem 'remarkable',               '~> 4.0.0.alpha4'
  gem 'remarkable_activemodel',   '~> 4.0.0.alpha2', :require => 'remarkable/active_model'

  gem 'mongoid-rspec'
  gem 'remarkable_mongoid', :require => 'remarkable/mongoid'
end
GEMFILE