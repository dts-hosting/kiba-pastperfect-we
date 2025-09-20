# frozen_string_literal: true

class Splits < Thor
  namespace :split

  desc "job KEY", "splits the specified job"
  def job(key)
    Ppwe::SplitByType::Job.call(key).either(
      ->(success) {
        puts success
        exit(0)
      },
      ->(failure) {
        puts failure
        exit(1)
      }
    )
  end
end
