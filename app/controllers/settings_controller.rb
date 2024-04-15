class SettingsController < UnitContextController
  def edit
    @page_title = [current_unit.name, "Settings"]
    authorize current_unit, policy_class: UnitSettingsPolicy
  end

  def index
    authorize current_unit, :edit?
  end

  def automated_messages
    authorize current_unit, :edit?
  end

  def documents
    authorize current_unit, :edit?
  end

  def test_communications; end
end
