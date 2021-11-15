class NewsItemsController < UnitContextController
  def index
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
