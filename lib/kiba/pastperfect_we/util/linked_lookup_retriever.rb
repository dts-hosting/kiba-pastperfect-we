# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module Util
      class LinkedLookupRetriever
        def initialize(config)
          @config = config.map.with_index { |c, i| finalize_config(c, i) }
          define_lookup_methods
        end

        def call(row)
          val = row[:referringid]
          config.inject(val) { |result, cfg| retrieve(result, cfg) }
        end

        private

        attr_reader :config

        def retrieve(val, cfg)
          send(:"lookup#{cfg[:idx]}")[val]
            &.map { |r| r[cfg[:take]] }
            &.join(Ppwe.delim)
        end

        def define_lookup_methods
          config.each { |hash| define_lookup_method(hash) }
        end

        def define_lookup_method(hash)
          i = hash[:idx]
          self.class.define_method(:"lookup#{i}") do
            if instance_variable_defined?(:"@lookup#{i}")
              return instance_variable_get(:"@lookup#{i}")
            end

            path = Ppwe.registry.resolve(hash[:lkup]).path
            result = Kiba::Extend::Utils::Lookup.csv_to_hash(
              file: path, keycolumn: hash[:lookup_on]
            )
            instance_variable_set(:"@lookup#{i}", result)
            result
          end
        end

        def finalize_config(hash, i)
          hash[:idx] = i

          unless Ppwe.job_output?(hash[:lkup])
            raise "No job output for :#{hash[:lkup]}"
          end

          unless hash.key?(:lookup_on)
            hash[:lookup_on] = Ppwe.lookup_on_for(hash[:lkup])
          end

          unless hash.key?(:take)
            hash[:take] = Ppwe::Splitting.item_type_field
          end
          hash
        end
      end
    end
  end
end
