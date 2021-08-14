class EventPresenter
  def self.category_to_fa_glyph(category)
    case category
    when 'camping' then
      return 'fas fa-campground'
    when 'troop_meeting' then
      return 'fas fa-users'
    when 'court_of_honor' then
      return 'fas fa-medal'
    end
  end
end
