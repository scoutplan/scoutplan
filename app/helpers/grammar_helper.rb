# frozen_string_literal: true

module GrammarHelper
  # grammatical_list("Garth") => "Garth"
  # grammatical_list("Ebony", "Ivory") => "Ebony and Ivory"
  # grammatical_list("Red", "White", "Blue") => "Red, White, and Blue"
  # And, yes, we use Oxford commas. Accept it.
  def grammatical_list(things, conjunction = "and")
    return things unless things.is_a?(Array)
    return "" if things.count.zero?
    return things.first if things.count == 1

    [things[0..-2].join(", "), "#{things.count > 2 ? ',' : ''}", " #{conjunction} ", things.last].join
  end
end
