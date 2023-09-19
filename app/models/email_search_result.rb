# frozen_string_literal: true

class EmailSearchResult
  delegate_missing_to :@result

  def initialize(result)
    @result = result
  end

  def key
    "abc"
  end

  def self.to_a(results)
    results.map { |r| EmailSearchResult.new(r) }
  end
end
