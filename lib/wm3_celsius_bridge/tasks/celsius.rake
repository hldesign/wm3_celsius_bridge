# frozen_string_literal: true
namespace :celsius do
  desc 'Test rake task'
  task test: :environment do
    puts "Celsius rake task."
  end
end
