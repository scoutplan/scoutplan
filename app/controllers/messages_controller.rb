class MessagesController < UnitContextController
  def index
    authorize :message, :index?
    @draft_news_items = @current_unit.news_items.draft
    @queued_news_items = @current_unit.news_items.queued
  end
end
