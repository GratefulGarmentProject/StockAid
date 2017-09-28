require "set"

namespace :exceptions do
  task list: :environment do
    Rails.application.eager_load!
    exceptions = []

    ObjectSpace.each_object(Class) do |k|
      exceptions << k if k.ancestors.include?(Exception)
    end

    puts exceptions.sort { |a, b| a.to_s <=> b.to_s }.join("\n")
  end

  task list_custom: :environment do
    existing = Set.new
    exceptions = []

    ObjectSpace.each_object(Class) do |k|
      existing << k if k.ancestors.include?(Exception)
    end

    Rails.application.eager_load!

    ObjectSpace.each_object(Class) do |k|
      exceptions << k if k.ancestors.include?(Exception) && !existing.include?(k)
    end

    puts exceptions.sort { |a, b| a.to_s <=> b.to_s }.join("\n")
  end
end
