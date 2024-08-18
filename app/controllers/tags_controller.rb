class TagsController < ApplicationController
  def create
    @tag_name = params[:tag][:name]
  end
end
