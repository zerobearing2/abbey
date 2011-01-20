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
