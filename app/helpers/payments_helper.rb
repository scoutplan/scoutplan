module PaymentsHelper
  def event_prices(event)
    return "#{number_to_currency(event.cost_youth)} per person" if event.cost_youth == event.cost_adult

    "#{number_to_currency(event.cost_youth)} per youth, #{number_to_currency(event.cost_adult)} per adult"
  end
end
