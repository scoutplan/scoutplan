class Components::EventCategoryBadge < Phlex::HTML
  def initialize(event:)
    super()
    @event = event
  end

  def view_template
    div(class: "text-xs font-medium uppercase tracking-wider flex items-center gap-1 text-paper-600") do
      i(class: "fa-solid fa-circle fa-xs", style: "color: #{@event&.category&.color}")
      render @event.category_name
    end
  end
end
