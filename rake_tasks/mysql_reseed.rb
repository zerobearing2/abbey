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