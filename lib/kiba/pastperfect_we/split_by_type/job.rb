# frozen_string_literal: true

module Kiba
  module PastperfectWe
    module SplitByType
      class Job
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)

        def self.call(jobkey, mode: :single) = new(jobkey, mode: mode).call

        # @return [Symbol]
        attr_reader :jobkey

        # @param jobkey [Symbol] full registry job key for job to split
        # @param mode [:single, :multi]
        def initialize(jobkey, mode: :single)
          @jobkey = jobkey
          @mode = mode
          @item_type_field = Ppwe::Splitting.item_type_field
          @mappings = Ppwe::Splitting.item_type_mapping
          @weaklings = Ppwe::Splitting.weak_targets
        end

        def call
          reg_entry = yield registered_job
          @src_path = reg_entry.path
          _chk_output = yield has_output
          headers = yield has_item_type_field

          Ppwe::SplitByType.set_up_target_dirs if mode == :single

          agg = Ppwe::Splitting.targets
            .map do |target|
              [
                target, {
                  writer: CSV.open(File.join(
                    Ppwe::Splitting.dir_path, target.to_s, file_name(target)
                  ), "w", headers: headers, write_headers: true),
                  ct: 0
                }
              ]
            end.to_h
          _result = yield do_split(agg)

          stats = agg.map { |k, v| "  #{k}: #{v[:ct]} rows" }
            .join("\n")
          msg = "Split #{jobkey}:\n#{stats}\nWrote files to "\
            "#{Ppwe::Splitting.dir_path} subdirectories"
          Success(msg)
        end

        private

        attr_reader :mode, :item_type_field, :mappings, :weaklings, :src_path

        def file_name(target)
          "#{File.basename(src_path, ".csv")}_#{target}.csv"
        end

        def do_split(agg)
          CSV.foreach(
            src_path, headers: true, header_converters: :symbol
          ) { |row| split_row(row, agg) }
        rescue => err
          Failure("Could not split #{jobkey}\n#{err.message}\n"\
                  "#{err.backtrace.first}")
        else
          Success()
        ensure
          agg.values.each { |h| h[:writer].close }
        end

        def split_row(row, agg)
          val = row[item_type_field]

          determine_targets(val).each do |target|
            write_to_target(target, row, agg)
          end
        end

        def determine_targets(val)
          return [mappings[val]] unless val

          all = val.split(Ppwe.delim)
            .map { |v| mappings[v] }
            .uniq
          return all if all.empty? || all.length == 1
          return all if all.all? { |t| weaklings.include?(t) }

          all - weaklings
        end

        def write_to_target(target, row, agg)
          agg[target][:writer] << row
          agg[target][:ct] += 1
        end

        def registered_job
          reg = Ppwe.registry.resolve(jobkey)
        rescue Dry::Container::KeyError
          Failure("#{jobkey} is not a registered job key")
        else
          Success(reg)
        end

        def has_output
          return Success() if Kiba::Extend::Job.output?(jobkey)

          Failure("No job output to split for #{jobkey}")
        end

        def has_item_type_field
          hdrs = Ppwe.headers_for(jobkey)
          return Success(hdrs) if hdrs.include?(item_type_field)

          Failure("Output of #{jobkey} does not include "\
                  ":#{item_type_field} field needed for splitting")
        end
      end
    end
  end
end
