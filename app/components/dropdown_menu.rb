class DropdownMenu < Phlex::HTML
  def initialize(items:)
    super
    @items = items
  end

  def template
    nav(class: "dropdown-menu") do
      @items.each do |item|
        a(item[:label], href: item[:url], class: "dropdown-item")
      end
    end
  end
end
