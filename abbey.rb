require 'pathname'
require 'colored'

def attention(text); $stdout.puts(text.to_s.green.bold.rjust(10)); end

@run_after_bundler = []
def after_bundler(&block)
  @run_after_bundler << block
end

temple      = Pathname.new(File.expand_path(File.dirname(__FILE__)))
app         = Pathname.new(File.expand_path(Dir.pwd))

mysql       = File.exists?(File.join(app, 'config/database.yml'))
prototype   = File.exists?(File.join(app, 'public/javascripts/prototype.js'))
testunit    = File.exists?(File.join(app, 'test/test_helper.rb'))

# Ask some questions
mongodb     = yes?('Would you like to use MongoDB?') unless mysql
haml        = yes?('Would you like to use haml?')

# ============================================================================
# Remove unnecessary files
# ============================================================================
files = ['README', 'public/index.html', 'public/favicon.ico', 'public/images/rails.png']
files.each { |f| run "rm #{f}" }
attention "Removed unnecessary files."

# ============================================================================
# Create and move
# ============================================================================
run "cp config/database.yml config/database.yml.example" if mysql
run "touch Readme.mkd"
run "mkdir -p app/views/shared"

attention "Recreated the readme file using markdown."
attention "Created app/views/shared directory"

# ============================================================================
# Setup the gitignore file
# ============================================================================
run "rm .gitignore"
file '.gitignore', <<-FILE
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
public/uploads
gems/*
!gems/cache
!gems/bundler
public/assets
public/system
coverage/*
.sass-cache
.bundle-cache
*.swo
*.swp
vendor/ruby
FILE

attention "Updated the gitignore file."

# ============================================================================
# Adding Gems
# ============================================================================
attention "Adding gems to Gemfile."

if !mysql && !mongodb
  gem 'sqlite3',          '~> 1.3.3'
end

gem 'colored',            '~> 1.2'

# Add development Gems for when using Rails Console
gem 'hirb',               '~> 0.4.0',                 :group => [:development]
gem 'wirble',             '~> 0.1.3',                 :group => [:development]
gem 'interactive_editor', '~> 0.0.7',                 :group => [:development]
gem 'utility_belt',       '~> 1.1.0',                 :group => [:development]
gem 'rails3-generators',  '~> 0.17.4',                :group => [:development]
gem 'rocco',              '~> 0.6',                   :group => [:development]
gem 'ZenTest',            '~> 4.5.0',                 :group => [:development, :test]
gem 'autotest',           '~> 4.4.6',                 :group => [:development, :test]
gem 'database_cleaner',   '~> 0.6.6',                 :group => [:development, :test]
gem 'factory_girl_rails', '~> 1.1.beta1',             :group => [:test]

unless testunit
  attention "Setting up rspec and rspec related gems."
  gem 'capybara',         '~> 0.4.1.2',               :group => [:test]
  gem 'launchy',          '~> 0.4.0',                 :group => [:test]
  gem 'rspec-rails',      '~> 2.5.0',                 :group => [:development, :test]
end


# Will Pagination, StateFlow, and Site Meta
attention 'Setting up Will Pagination, StateFlow, and Site Meta'

gem 'simple_form',        '~> 1.3.1'
gem 'haml',               '~> 3.0.25'
gem 'compass',            '~> 0.10.6'
gem 'fancy-buttons',      '~> 1.0.6'
gem 'kaminari',           '~> 0.10.4'
gem 'stateflow',          '~> 0.4.1'
gem 'site_meta',          '~> 1.0.0'
gem 'devise',             '~> 1.1.8'
gem 'devise_invitable',   '~> 0.3.6'

if haml
  attention 'Setting up HAML'
  gem "ruby_parser",      '~> 2.0.6'
  gem "hpricot",          '~> 0.8.4'
  gem "haml-rails",       '~> 0.3.4'
end

if mongodb
  attention 'Setting up MongoDB'
  gem "bson",             '~> 1.2.4'
  gem 'bson_ext',         '~> 1.2.4'
  gem 'mongoid',          '~> 2.0.0.rc.8'
end

run "bundle install --path vendor"
run "bundle package"

# ============================================================================
# Adding the seed system
# ============================================================================
run 'mkdir -p db/seeds'
run 'rm db/seeds.rb'
file 'db/seeds.rb', <<-RUBY
require 'colored'
def attention(text); $stdout.puts(text.to_s.green.bold.rjust(10)); end
Dir[Rails.root.join("db/seeds/**/*.rb")].each {|f| require f}
RUBY

attention "The seed system is all setup."

# ============================================================================
# Install jQuery
# ============================================================================
if !prototype
  inside "public/javascripts" do
    get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js",      "rails.js"
    get "http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js",      "jquery.js"
    get "http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js", "jquery_ui.js"
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
      
      def support_email
        'support@email.com'
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
        read_build_file
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
        puts "Previous Version: \#{version} - New Version: \#{new_version}".green
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
  
  task :support_email => :environment do
    puts "Support Email: \#{App::Project.support_email}"
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
# Autotest, Webrat, Factory Girl, Rails3 Generators
# ============================================================================
attention 'Setting up Autotest, ZenTest, Database Cleaner, Webrat, Factory Girl, and Rails 3 Generators.'

attention "Setting up .autotest file."
file '.autotest', <<-EOF
require 'autotest/fsevent'
require 'autotest/growl'
EOF

# ============================================================================
# Git initial checking
# ============================================================================
attention "Checking everything into git."
git :init
git :add    => '.'
git :commit => "-am 'Initial commit of a clean rails application.'"


# ============================================================================
# Rspec && Cucumber
# ============================================================================
unless testunit
  attention 'Setting up Cucumber and Rspec.'

  after_bundler do 
    generate 'rspec:install'
  end

  file "lib/tasks/db.rake", <<-CODE
namespace :db do
  namespace :test do
    task :prepare do
    end
  end
end
  CODE
end


# ============================================================================
# SimpleForm Setup
# ============================================================================
attention 'Adding Simple Form'

after_bundler do
  generate 'simple_form:install'
end



# ============================================================================
# Sass, Compass, Fancy Buttons
# ============================================================================
attention 'Setting up Sass, Compass and Fancy Buttons.'

after_bundler do
  run 'compass init rails --css-dir=public/stylesheets --sass-dir=app/stylesheets --syntax sass'
end


# ============================================================================
# Devise
# ============================================================================
attention "Setting up Devise."

after_bundler do
  generate 'devise:install'
  generate 'devise:views'
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
# Setup the Generator initializer
# ============================================================================
attention 'Setting up the config/initializers/generator.rb file.'
template_engine = haml ? "g.template_engine      :haml" : "g.template_engine      :erb"

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
  g.stylesheets          false
  #{template_engine}
  g.fixture_replacement  :factory_girl,  :dir => 'spec/factories'
end
RUBY

attention 'Adding rspec to the generators.rb file.'
unless testunit
  inject_into_file 'config/initializers/generators.rb', :after => "g.template_engine      :erb\n" do
    'g.test_framework       :rspec, :fixture => true, :views => false'
  end
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

  after_bundler do
    generate 'mongoid:config'
    generate 'mongoid:install'
  end

  inject_into_file "config/initializers/generators.rb", :after => "g.stylesheets          false\n" do
    "    g.orm                  :mongoid\n"
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
attention 'Running Bundler various tasks queued up for after bundler installs gems. Following the principle of "vendor everything".'
run "bundle install --path vendor"
run "bundle package"
@run_after_bundler.each { |b| b.call unless b.nil? }

# ============================================================================
# Doing the final Git Check-in
# ============================================================================
attention 'Checking in all of our changes.'
git :add => '.'
git :commit => "-am 'Added compass, sass, devise.'"
