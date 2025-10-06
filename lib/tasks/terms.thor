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
      .reject do |ref|
        ref.table == "CatalogItem" ||
          Ppwe::Terms.skip_use_tables.include?(ref.table) ||
          Ppwe.lookup_column_for(ref.table) == :catalogitemid ||
          ref.field == :catalogitemid ||
          Ppwe::Util::Fk.catalogitemid_field(ref.table)
      end
      .map(&:table)
      .uniq
      .reject { |t| Ppwe::Terms.itemtype_lookup_config.key?(t) }

    puts trefs.sort
  end
end
