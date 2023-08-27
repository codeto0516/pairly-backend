# lib/tasks/db.rake

namespace :db do
  desc 'Reset and seed the database'
  task reset_and_seed: [:environment] do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end
end
