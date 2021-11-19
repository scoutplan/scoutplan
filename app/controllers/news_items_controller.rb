# frozen_string_literal: true

# News Items feed into weekly newsletters
class NewsItemsController < UnitContextController
  layout 'application_new'
  before_action :find_news_item, only: [ :enqueue ]

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

  def enqueue
    @news_item.status = :queued
    @news_item.save!
  end

  private

  def find_news_item
    @news_item = NewsItem.find(params[:news_item_id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :body, :status)
  end
end
