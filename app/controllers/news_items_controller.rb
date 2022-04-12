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
    redirect_to unit_announcements_path(@unit)
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
    redirect_to unit_announcements_path(@unit)
  end

  def enqueue
    update_item_status(:queued)
  end

  def dequeue
    update_item_status(:draft)
  end

  private

  def update_item_status(new_status)
    @news_item.update!(status: new_status)
    # path = (new_status == :queued ? unit_newsletter_queued_path(@unit) : unit_newsletter_drafts_path(@unit))

    # respond_to do |format|
    #   format.turbo_stream { render turbo_stream: turbo_stream.remove(@news_item) }
    #   format.html { redirect_to path, notice: t("news_items.notices.status_update") }
    # end

    render turbo_stream: [
      turbo_stream.update("newsletter_nav", partial: "news_items/newsletter_nav"),
      turbo_stream.remove(@news_item)
    ]
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
