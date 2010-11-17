file 'Gemfile', <<-GEMFILE
source 'http://rubygems.org'

gem 'rails',                      '~> 3.0.2'
gem 'compass',                    '~> 0.10.6'
gem 'haml',                       '~> 3.0.24'
gem 'fancy-buttons',              '~> 0.5.5'
gem 'simple_form',                '~> 1.2.2'
gem 'devise',                     '~> 1.1.3'
gem 'will_paginate',              '~> 3.0.pre2'
gem 'stateflow',                  '~> 0.2.3'
gem 'site_meta',                  '~> 1.0.0'

# Reports
gem 'ruport',                     '~> 1.6.3'
gem 'ruport-util',                '~> 0.14.0',    :require => 'ruport/util'

# gem 'hoptoad_notifier',           '~> 2.3.11'

gem 'bson',                       '~> 1.1.2'
gem 'mongo',                      '~> 1.1.2'
gem 'mongoid',    :git => 'http://github.com/mongoid/mongoid.git',  :branch => 'master'

group :test, :development do
  gem 'autotest',                 '~> 4.3.2'
  gem 'webrat',                   '~> 0.7.2'    
  gem 'factory_girl',             '~> 1.3.2'    
  gem 'factory_girl_rails',       '~> 1.0'      
  gem 'database_cleaner',         '~> 0.6.0'    
  gem 'rails3-generators',        '~> 0.14.0'   
  gem 'rspec',                    '~> 2.1.0'    
  gem 'rspec-rails',              '~> 2.1.0'    
  gem 'steak',                    '~> 1.0.0.rc.2'

  gem 'capistrano',               '~> 2.5.19'

  gem 'remarkable',               '~> 4.0.0.alpha4'
  gem 'remarkable_activemodel',   '~> 4.0.0.alpha2', :require => 'remarkable/active_model'

  gem 'mongoid-rspec',            '~> 1.3.2'
  gem 'remarkable_mongoid',       '~> 0.5.0', :require => 'remarkable/mongoid'
end
GEMFILE