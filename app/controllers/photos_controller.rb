# frozen_string_literal: true

# https://hashtagjohnt.com/how-to-generage-heic-previews-in-rails-using-activestorage.html

class PhotosController < UnitContextController
  before_action :find_photo, only: [:edit, :update, :destroy]

  def index
    if params[:event_id].present?
      @event = @unit.events.find(params[:event_id])
      @photos = @event.photos.order(created_at: :desc)
      @gallery_title = "#{@event.title} Photos"
    else
      @photos = @unit.photos.order(created_at: :desc)
      @gallery_title = "#{@unit.name} Photo Gallery"
    end
  end

  def edit; end

  def update
    authorize @photo

    params[:photo][:images].each do |image|
      next unless image.is_a?(ActionDispatch::Http::UploadedFile)

      if image.content_type == "image/heic"
        converted = ConvertApi.convert("jpg", { File: image.tempfile.path})
        @photo.images.attach(io: converted.file.io, filename: "#{image.original_filename}.jpg")
      else
        @photo.images.attach(image)
      end
    end
    
    @photo.save!
    flash[:notice] = "Photo updated"
    
    if (event_id = params[:event_id]).present?
      redirect_to unit_event_photos_path(@unit, event_id)
    else
      redirect_to unit_photos_path(@unit)
    end
  end

  def new; end

  def create
    photo = @unit.photos.new
    photo.event_id = params[:unit][:photos][:event_id]
    photo.caption = params[:unit][:photos][:caption]
    photo.description = params[:unit][:photos][:description]
    photo.author = @current_member

    params[:unit][:photos][:image].each do |image|
      next unless image.is_a?(ActionDispatch::Http::UploadedFile)

      if image.content_type == "image/heic"
        converted = ConvertApi.convert("jpg", { File: image.tempfile.path})
        photo.images.attach(io: converted.file.io, filename: "#{image.original_filename}.jpg")
      else
        photo.images.attach(image)
      end
    end
    
    photo.save!

    redirect_to unit_photos_path(@unit)
  end

  def show
    @photo = @unit.photos.find(params[:id])
    authorize @photo

    @next_photo = @unit.photos.where("id > ?", @photo.id)&.first
    @previous_photo = @unit.photos.where("id < ?", @photo.id)&.last
  end

  def destroy
    @photo = @unit.photos.find(params[:id])
    authorize @photo
    @photo.destroy

    redirect_to unit_photos_path(@unit)
  end

  private

  def find_photo
    @photo = @unit.photos.find(params[:id])
  end
end
