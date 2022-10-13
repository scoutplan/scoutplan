# frozen_string_literal: true

# monkey-patch String with new method

module CoreExtensions
  module String
    # boolean method(s) additions to String
    module CaseMethods
      # re-open String and add a sentence_case method to it
      def sentence_case
        substr(0, 1).upcase + substr(1, length - 1)
      end
    end
  end
end
