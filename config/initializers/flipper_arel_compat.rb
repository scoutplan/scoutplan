# frozen_string_literal: true

# Rails main made Arel::Table's initializer keyword-only (`Arel::Table.new(name: ...)`),
# but flipper-active_record still calls `Arel::Table.new(:flipper_features)`, which blows up
# with "wrong number of arguments (given 1, expected 0)" on every request that preloads flags.
#
# Patch #get_all to build the same query from the models' own arel_tables. Remove this file
# once flipper-active_record ships a fix (https://github.com/flippercloud/flipper).
require "flipper/adapters/active_record"

if ::Arel::Table.instance_method(:initialize).parameters.none? { |type, _| [:req, :opt, :rest].include?(type) }
  module Flipper
    module Adapters
      class ActiveRecord
        def get_all(**kwargs)
          with_connection(@feature_class) do |connection|
            # query the gates from the db in a single query
            features = @feature_class.arel_table
            gates = @gate_class.arel_table
            rows_query = features.join(gates, ::Arel::Nodes::OuterJoin)
              .on(features[:key].eq(gates[:feature_key]))
              .project(features[:key].as("feature_key"), gates[:key], gates[:value])
            gates = connection.select_rows(rows_query)

            # group the gates by feature key
            grouped_gates = gates.inject({}) do |hash, (feature_key, key, value)|
              hash[feature_key] ||= []
              hash[feature_key] << [key, value]
              hash
            end

            # build up the result hash
            result = Hash.new { |hash, key| hash[key] = default_config }
            features = grouped_gates.keys.map { |key| Flipper::Feature.new(key, self) }
            features.each do |feature|
              result[feature.key] = result_for_gates(feature, grouped_gates[feature.key])
            end
            result.default_proc = nil
            result
          end
        end
      end
    end
  end
end
