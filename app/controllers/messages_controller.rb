class MessagesController < UnitContextController
  layout 'application_new'

  def index
    authorize :message, :index?
    @view = params[:mode] || 'drafts'

    @news_items = case @view
                  when 'queued'
                    @current_unit.news_items.queued
                  when 'sent'
                    @current_unit.news_items.sent
                  else
                    @current_unit.news_items.draft
                  end
  end
end
