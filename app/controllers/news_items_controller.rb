class NewsItemsController < UnitContextController
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

  def new
    @news_item = @current_unit.news_items.new
    respond_to :js
  end

  def create
    @news_item = @current_unit.news_items.new(news_item_params)
    @news_item.save!
  end

  private

  def news_item_params
    params.require(:news_item).permit(:title, :body, :status)
  end
end
