class SpreadsheetRowsController < UnitContextController
  def create
    @before_event = current_unit.events.find(params[:before])
    @new_event = @before_event.new_event_before
    authorize @new_event, :create?
    @new_event.save!
  end
end
