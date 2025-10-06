# frozen_string_literal: true

class Terms < Thor
  desc "referring_tables", "list tables using terms"
  def referring_tables
    puts Ppwe::Terms.table_config
      .keys
      .map { |t| Ppwe::Terms.refs_to_terms_in(t).keys }
      .flatten
      .uniq
      .sort
  end
end
