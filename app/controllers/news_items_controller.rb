# frozen_string_literal: true

# News Items feed into digest newsletters
class NewsItemsController < UnitContextController
  before_action :find_news_item, only: [:enqueue, :dequeue]

  def index
    authorize :message, :index?
    @view = params[:mode] || "drafts"
    find_news_items
  end

  def new
    @news_item = @unit.news_items.new
  end

  def create
    @news_item = @current_unit.news_items.new(news_item_params)
    @news_item.save!
    redirect_to unit_news_items_path(@unit)
  end

  def edit
    @news_item = NewsItem.find(params[:id])
    @current_unit = @unit = @news_item.unit
    @membership = @unit.membership_for(current_user)
    authorize @news_item
  end

  def update
    @news_item = NewsItem.find(params[:id])
    @current_unit = @unit = @news_item.unit
    @membership = @unit.membership_for(current_user)
    authorize @news_item
    @news_item.assign_attributes(news_item_params)
    @news_item.save!
    find_news_items
    respond_to :js
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    authorize @news_item
    @news_item.destroy
    redirect_to unit_news_items_path(@unit)
  end

  def enqueue
    @view = "drafts"
    update_item_status(:queued)
  end

  def dequeue
    @view = "queued"
    update_item_status(:draft)
  end

  private

  def update_item_status(status)
    @current_unit = @unit = @news_item.unit
    find_news_items
    @news_item.status = status
    @news_item.save!
    find_news_items
  end

  def find_news_items
    @news_items = case @view = params[:mode] || "drafts"
                  when "queued"
                    @current_unit.news_items.queued
                  when "sent"
                    @current_unit.news_items.sent
                  when "drafts"
                    @current_unit.news_items.draft
                  else
                    []
                  end
  end

  def find_news_item
    @news_item = NewsItem.find(params[:news_item_id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :body, :status)
  end
end
