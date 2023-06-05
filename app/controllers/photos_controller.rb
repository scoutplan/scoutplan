# frozen_string_literal: true

# https://hashtagjohnt.com/how-to-generage-heic-previews-in-rails-using-activestorage.html

class PhotosController < UnitContextController
  def index
    @photos = @unit.photos.order(created_at: :desc)
  end

  def new
  end

  def create
    params[:unit][:photos][:image].each do |image|
      next unless image.is_a?(ActionDispatch::Http::UploadedFile)
      photo = @unit.photos.new
      photo.event_id = params[:unit][:photos][:event_id]
      photo.caption = params[:unit][:photos][:caption]
      photo.description = params[:unit][:photos][:description]

      if image.content_type == "image/heic"
        converted = ConvertApi.convert("jpg", { File: image.tempfile.path})
        photo.image.attach(io: converted.file.io, filename: "#{image.original_filename}.jpg")
      else
        photo.image.attach(image)
      end

      photo.author = @current_member
      photo.save!
    end

    redirect_to unit_photos_path(@unit)
  end

  def show
    @photo = @unit.photos.find(params[:id])

    @next_photo = @unit.photos.where("id > ?", @photo.id)&.first
    @previous_photo = @unit.photos.where("id < ?", @photo.id)&.last
  end
end
