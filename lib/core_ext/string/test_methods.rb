# frozen_string_literal: true

# monkey-patch String with new method

module CoreExtensions
  module String
    # boolean method(s) additions to String
    module TestMethods
      # rubocop:disable Style/RescueModifier
      # re-open String and add a numeric? method to it
      def numeric?
        true if Float(self) rescue false
      end

      def question?
        self[-1] == "?"
      end
      # rubocop:enable Style/RescueModifier
    end
  end
end
