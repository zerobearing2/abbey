require 'pathname'
require 'colored'

def attention(text)
  $stdout.puts(text.to_s.green.bold.rjust(10))
end

@add_to_bundler = []
def after_bundler
  @add_to_bundler << block
end

temple  = Pathname.new(File.expand_path(File.dirname(__FILE__)))
app     = Pathname.new(File.expand_path(Dir.pwd))

mysql?      = File.exists?(File.join(app, 'config/database.yml'))
prototype?  = File.exists?(File.join(app, 'public/javascripts/prototype.js'))

mongodb     = yes?('Would you like to use MongoDB?')

# ============================================================================
# Remove unnecessary files
# ============================================================================
files = ['README', 'public/index.html', 'public/favicon.ico', 
         'public/images/rails.png']
file.each { |f| run "rm #{f}" }
attention "Removed unneccessary files."

# ============================================================================
# Create and move
# ============================================================================
run "cp config/database.yml config/database.yml.example" if mysql?
run "touch Readme.mkd"
run "mkdir -p app/views/shared"

attention "Recreated the readme file using markdown."
attention "Created app/views/shared directory"

# ============================================================================
# Setup the gitignore file
# ============================================================================
file '.gitignore', <<-FILE
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
public/uploads/*
gems/*
!gems/cache
!gems/bundler
.rvmrc
public/assets
public/system
coverage/*
.sass-cache
.bundle-cache
FILE

attention "Updated the gitignore file."

# ============================================================================
# Adding the seed system
# ============================================================================
run 'mkdir -p db/seeds'
file 'db/seeds.rb', <<-RUBY
require 'colored'
Dir[Rails.root.join("db/seeds/**/*.rb")].each {|f| require f}
RUBY

attention "Setup the seed system."

# ============================================================================
# Install jQuery
# ============================================================================
if jquery?
  inside "public/javascripts" do
    get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "rails.js"
    get "http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js", "jquery/jquery.js" 
    get "http://ajax.googleapis.com/ajax/libs/jquery/1/jquery-ui.min.js", "jquery/jquery_ui.js"  
    attention "Added jquery, jquery ui, and rails-jquery to the project."
  end
  gsub_file 'config/application.rb', /%w\(\)/, '%w(jquery jquery_ui rails)'
  attention "Updated config/application to autoload jquery, jquery ui, and rails-jquery."
end


# ============================================================================
# Install Modernizr
# ============================================================================
inside "public/javascripts" do 
  get "https://github.com/Modernizr/Modernizr/raw/master/modernizr.js", "modernizr.js"
  attention "Added modernizr to the project."
end


# ============================================================================
# Add the app module for project details to the lib folder
# ============================================================================
gsub_file 'config/application.rb', /# Custom directories with classes and modules you want to be autoloadable\./ do
<<-RUBY
config.autoload_paths += %W(\#{config.root}/lib)
RUBY
end

attention "Updated the config.autoload_paths to include the /lib directory."

file 'config/build.version', '0.0.1'
attention "Created config/build.version with version 0.0.1 for application version control."

file 'lib/app.rb', <<-CODE
require 'colored'
module App
  class Project
    class << self
    
      def name
        'Project Name'
      end
    
      def domain
        'Domain Name'
      end
    
      def version
        Version.current
      end
    
    end
  end
  
  class VersionError < StandardError; end

  class Version
    class << self
    
      ##
      # The location of the version number file
      VERSION_CONFIG  = File.expand_path(File.join(File.dirname(__FILE__), "..", "config"))
      VERSION_FILE    = File.expand_path(File.join(VERSION_CONFIG, "build.version"))
      @@releases      = %w[major minor point].freeze
  
  
      # Generate a build.version file to the config/ directory of a rails application.
      def generate_build_file
        
        # create the config directory if it doesn't already exist
        FileUtils.mkdir_p(VERSION_CONFIG) unless File.exists?(VERSION_CONFIG)
        
        # create the build.version file and add the first version, 0.0.1
        File.open(VERSION_FILE, 'w') { |f| f.write '0.0.1' }
        print "Created a build version file (build.version) located at \#{VERSION_FILE.to_s}"
      end
  

      # Return the current version number from the build version file.
      def current
        ver = read_build_file
        "\#{ver}".green
      end
      
      
      # Read the Build File
      def read_build_file
        (File.read(VERSION_FILE).chomp rescue 0)
      end

  
      # Verison up or down for major, minor, and point releases
      def versioning(direction, release)
        version     = read_build_file
        int_ver     = version.split('.').join().to_i
        
        # case to determine versioning release
        new_version = case release
        when :major then update_build_version(int_ver, direction, 100)
        when :minor then update_build_version(int_ver, direction, 10)
        when :point then update_build_version(int_ver, direction, 1)
        else
          raise ArgumentError, "You can only increase the version number by major, minor, or point."
        end
        
        # save the version number to the build version file
        File.open(VERSION_FILE, 'w') { |f| f.write new_version }
        
        # give the user a message that it has completed and show the previous/current version.
        print "Previous Version: \#{version} - New Version: \#{new_version}".green
      end
  
  
      # Method Missing for capturing the Version.up and Version.down
      def method_missing(direction, release)
        raise VersionError.new("You can only version up or down.") unless ['up', 'down'].include?(direction)
        
        # if major/minor/point is requested
        if @@releases.include?(release.to_s.downcase)
          versioning(direction, release)
        else
          super
        end
        
      end
  
  
      private
    
        # Does the actual updating of the version numbers
        def update_build_version(version, direction, points)
          
          # what direction is being requested
          new_version = case direction
          
          # add version points to the current version
          when :up    then ("%03d" % (version + points)).split(//).join('.')
            
          # minus version points from the current version
          when :down  then ("%03d" % (version - points unless version == 0)).split(//).join('.')
          
          else
            
            # the current version
            "%03d" % version
          end
          
          new_version
        end
    end
  end
end
CODE

attention "Added lib/app.rb for project name, domain and versioning control."

# ============================================================================
# Apply the rake tasks associated with App::Project
# ============================================================================
file 'lib/tasks/version.rake', <<-CODE
namespace :project do
  desc "Get the project's version number"
  task :version => :environment do
    puts "\#{App::Project.name}'s version: \#{App::Project.version}."
  end
  
  task :name => :environment do
    puts "Project name: \#{App::Project.name}"
  end
  
  task :domain => :environment do
    puts "Project's domain name: \#{App::Project.domain}"
  end
end

namespace :version do
  desc 'Point Release'
  task :point_release => :environment do
    App::Version.version_it(:up, :point)
  end
  
  desc 'Minor Release'
  task :minor_release => :environment do
    App::Version.version_it(:up, :minor)
  end
  
  desc 'Major Release'
  task :major_release => :environment do
    App::Version.version_it(:up, :major)
  end
  
  
  # Downgrade version
  namespace :down do
    
    desc 'Downgrade Point Release'
    task :point_release => :environment do
      App::Version.version_it(:down, :point)
    end
  
    desc 'Downgrade Minor Release'
    task :minor_release => :environment do
      App::Version.version_it(:down, :minor)
    end
  
    desc 'Downgrade Major Release'
    task :major_release => :environment do
      App::Version.version_it(:down, :major)
    end
  end
end  
CODE

attention "Added rake tasks to easily use the app.rb project management script."

# ============================================================================
# Git initial checking
# ============================================================================
attention "Checking everything into git."
git :init
git :add => '.'
git :commit => "-am 'Initial commit of a clean rails application.'"

# ============================================================================
# Generators
# ============================================================================
initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

# ============================================================================
# Rspec
# ============================================================================
attention 'Setting up rspec.'

gem 'rspec-rails',  :group => [:development, :test]

attention 'Setting up the config/initializers/generator.rb file.'
inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
  "    g.test_framework   :rspec, :fixture => true, :views => false\n"
  "    g.stylesheets      false"
  "    g.template_engine  :erb"
end

after_bundler { generate 'rspec:install' }


# ============================================================================
# Steak
# ============================================================================
attention 'Setting up Steak.'

gem 'steak',        :group => [:development, :test]
gem 'capybara',     :group => [:development, :test]

after_bundler { generate 'steak:install' }


# ============================================================================
# Steak
# ============================================================================
attention 'Setting up Steak.'

gem 'steak',        :group => [:development, :test]
gem 'capybara',     :group => [:development, :test]

after_bundler { generate 'steak:install' }


# ============================================================================
# Autotest, Webrat, Factory Girl, Rails3 Generators
# ============================================================================
attention 'Setting up Autotest, Webrat, Factory Girl, and Rails 3 Generators.'

gem 'autotest',           :group => [:development, :test]
gem 'webrat',             :group => [:development, :test]
gem 'factory_girl_rails', :group => [:development, :test]
gem 'rails3-generators',  :group => [:development, :test]

inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
  "    g.fixture_replacement :factory_girl,  :dir => 'spec/factories'"
end

# ============================================================================
# Sass, Compass, Fancy Buttons
# ============================================================================
attention 'Setting up Sass, Compass and Fancy Buttons.'

gem 'haml'
gem 'compass'
gem 'fancy-buttons'

after_bundler do
  run 'compass init rails --css-dir=public/stylesheets/compiled --sass-dir=app/stylesheets --syntax sass'
end

# ============================================================================
# Will Pagination, StateFlow, and Site Meta
# ============================================================================
attention 'Setting up Will Pagination, StateFlow, and Site Meta'

gem 'will_paginate', '~> 3.0.pre2'
gem 'stateflow'
gem 'site_meta'


# ============================================================================
# Devise
# ============================================================================
attention "Setting up Devise."

gem 'devise'

after_bundler do
  generate 'devise:install'
  generate 'devise:views'
  generate 'devise user'
end

attention 'Setting Devise Mailer in the config/environments/development.rb'

gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '# Devise Mailer Setup'
gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
<<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.perform_deliveries     = false
  config.action_mailer.raise_delivery_errors  = true
  config.action_mailer.default :charset => "utf-8"
RUBY
end

attention 'Setting Devise Mailer in the config/environments/production.rb'

gsub_file 'config/environments/production.rb', /config.i18n.fallbacks = true/ do
<<-RUBY
config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { :host => App::Project.domain }
  ### ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.perform_deliveries     = true
  config.action_mailer.raise_delivery_errors  = false
  config.action_mailer.default :charset => "utf-8"
RUBY
end

attention 'Setting Devise Mailer in the config/environments/test.rb'

gsub_file 'config/environments/test.rb', /# Don't care if the mailer can't send/, '# Devise Mailer Setup'
gsub_file 'config/environments/test.rb', /# Settings specified here will take precedence over those in config\/application.rb/ do
<<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
RUBY
end


# ============================================================================
# Prevent Logging of Passwords
# ============================================================================
attention 'Preventing the logging of passwords.'
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'


# ============================================================================
# MongoDB Setup, if requested
# ============================================================================
if mongodb
  attention 'Setting up tools to use Mongoid for MongoDB.'
  
  gem 'bson'
  gem 'bson_ext'
  gem 'mongoid', '~> 2.0.0.rc.6'
  
  after_bundler do
    generate 'mongoid:config'
    generate 'mongoid:install'
  end

attention 'Adding mongoid to config/initializers/generators.rb.'  
inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
    "    g.orm              :mongoid"
end
  
else
  attention 'Setting up rake db:reseed task'
  file "lib/tasks/reseed.rake", <<-END
    namespace :db do
      desc "Reseed database"
      task :reseed => :environment do
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        Rake::Task['db:seed'].invoke
        Rake::Task['db:test:clone'].invoke
      end
    end
  END
end

# ============================================================================
# Run the after bundler tasks
# ============================================================================
attention 'Running Bundler and various tasks queued up for after bundler installs gems.'
run 'bundler install'
@add_to_bundler.each { |b| b.call }

# ============================================================================
# Doing the final Git Check-in
# ============================================================================
attention 'Checking in all of our changes.'
git :add => '.'
git :commit => "-am 'Added rspec, steak, compass, sass, devise.'"