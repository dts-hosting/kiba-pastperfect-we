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

  desc "to_itemid_config", "list tables needing item id lookup config"
  def to_itemid_config
    trefs = Ppwe::Terms.table_config
      .keys
      .map { |t| Ppwe::Terms.refs_to_terms_in(t).values }
      .flatten
      .reject { |ref| ref.table == "CatalogItem" ||
          ref.field == :catalogitemid ||
          Ppwe::Util::Fk.catalogitemid_field(ref.table) }
    binding.pry
  end
end
