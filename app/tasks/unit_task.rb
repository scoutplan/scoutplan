# frozen_string_literal: true

# A Task subclass for Units (probably covers most use cases)
class UnitTask < Task
  alias_attribute :unit, :taskable
end
