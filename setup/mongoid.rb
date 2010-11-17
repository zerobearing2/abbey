generate('mongoid:install')


gsub_file 'config/application.rb', /# Configure the default encoding used in templates for Ruby 1.9./ do
if haml
<<-RUBY
config.generators do |g|
      g.stylesheets         false
      g.orm                 :mongoid
      g.template_engine     :haml
      g.fixture_replacement :factory_girl,  :dir => 'spec/factories'
      g.test_framework      :rspec, :fixture => true, :views => false
    end
RUBY
else
<<-RUBY
config.generators do |g|
      g.stylesheets         false
      g.orm                 :mongoid
      g.fixture_replacement :factory_girl,  :dir => 'spec/factories'
      g.test_framework      :rspec, :fixture => true, :views => false
    end
RUBY
end
end

gsub_file 'config/application.rb', /# require "active_record\/railtie"/ do
<<-RUBY
require 'mongoid/railtie'
RUBY
end