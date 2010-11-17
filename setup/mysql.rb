run 'cp config/database.yml config/database.yml.example'
apply temple.join('tasks/reseed.rb')

gsub_file 'config/application.rb', /# Configure the default encoding used in templates for Ruby 1.9./ do
<<-RUBY
config.generators do |g|
      g.stylesheets           false
      g.fixture_replacement   :factory_girl, :dir => 'spec/factories'
      g.test_framework        :rspec, :fixture => true, :views => false
    end
RUBY
end