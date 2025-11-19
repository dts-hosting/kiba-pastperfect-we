# frozen_string_literal: true

class Reports < Thor
  namespace :reports

  desc "no_assoc_items", "writes report"
  def no_assoc_items
    Ppwe::Reports::NoAssocItems.call
  end
end
