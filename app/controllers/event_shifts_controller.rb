class EventShiftsController < ApplicationController
  def create
    @event_shift = EventShift.new(event_shift_params)
    @event_shift_counter = params[:event_shift_counter].to_i
  end

  private

  def event_shift_params
    params.require(:event_shift).permit(:name)
  end
end
