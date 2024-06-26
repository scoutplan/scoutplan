# frozen_string_literal: true

# https://hashtagjohnt.com/how-to-generage-heic-previews-in-rails-using-activestorage.html

class PhotosController < UnitContextController
  before_action :find_photo, only: [:edit, :update, :destroy]
  before_action :find_event, only: [:new]

  def index
    if params[:event_id].present?
      @event = current_unit.events.find(params[:event_id])
      @photos = @event.photos.order(created_at: :desc)
      @gallery_title = "#{@event.title} Photos"
    else
      @photos = current_unit.photos.order(created_at: :desc)
      @gallery_title = "#{current_unit.name} Photo Gallery"
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
      redirect_to unit_event_photos_path(current_unit, event_id)
    else
      redirect_to unit_photos_path(current_unit)
    end
  end

  def new; end

  def create
    photo = current_unit.photos.new
    photo.event_id = params[:unit][:photos][:event_id]
    photo.caption = params[:unit][:photos][:caption]
    photo.description = params[:unit][:photos][:description]
    photo.author = current_member

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

    redirect_to unit_photos_path(current_unit)
  end

  def show
    @photo = current_unit.photos.find(params[:id])
    authorize @photo

    @next_photo = current_unit.photos.where("id > ?", @photo.id)&.first
    @previous_photo = current_unit.photos.where("id < ?", @photo.id)&.last
  end

  def destroy
    @photo = current_unit.photos.find(params[:id])
    authorize @photo
    @photo.destroy

    redirect_to unit_photos_path(current_unit)
  end

  private

  def find_photo
    @photo = current_unit.photos.find(params[:id])
  end

  def find_event
    @event = current_unit.events.find(params[:event_id])
  end
end
