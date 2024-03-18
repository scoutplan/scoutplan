class SettingsController < UnitContextController
  def edit
    @page_title = [@unit.name, "Settings"]
    authorize @unit, policy_class: UnitSettingsPolicy
  end

  def index
    authorize @unit, :edit?
  end

  def automated_messages
    authorize @unit, :edit?
  end

  def documents
    authorize @unit, :edit?
  end

  def test_communications; end
end
