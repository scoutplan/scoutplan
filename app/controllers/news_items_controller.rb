# frozen_string_literal: true

# News Items feed into digest newsletters
class NewsItemsController < UnitContextController
  layout 'application_new'
  before_action :find_news_item, only: [ :enqueue , :dequeue ]

  def index
    authorize :message, :index?
    @view = params[:mode] || 'drafts'
    if @unit.settings(:communication).digest
      @schedule = IceCube::Schedule.from_yaml(@unit.settings(:communication).digest)
    end
    set_news_items
  end

  def new
    @news_item = @current_unit.news_items.new(status: 'draft')
    @news_item_unit = @current_unit
    respond_to :js
  end

  def create
    @news_item = @current_unit.news_items.new(news_item_params)
    @news_item.save!
    set_news_items
    respond_to :js
  end

  def edit
    @news_item = NewsItem.find(params[:id])
    @current_unit = @unit = @news_item.unit
    @membership = @unit.membership_for(current_user)
    authorize @news_item
    respond_to :js
  end

  def update
    @news_item = NewsItem.find(params[:id])
    @current_unit = @unit = @news_item.unit
    @membership = @unit.membership_for(current_user)
    authorize @news_item
    @news_item.assign_attributes(news_item_params)
    @news_item.save!
    set_news_items
    respond_to :js
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    @current_unit = @unit = @news_item.unit
    @membership = @unit.membership_for(current_user)
    authorize @news_item
    @news_item.destroy
    set_news_items
    respond_to :js
  end

  def enqueue
    @view = 'drafts'
    update_item_status(:queued)
  end

  def dequeue
    @view = 'queued'
    update_item_status(:draft)
  end

  private

  def update_item_status(status)
    @current_unit = @unit = @news_item.unit
    set_news_items
    @news_item.status = status
    @news_item.save!
    set_news_items
    respond_to :js
  end

  def set_news_items
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

  def find_news_item
    @news_item = NewsItem.find(params[:news_item_id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :body, :status)
  end
end
