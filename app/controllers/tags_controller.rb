class TagsController < ApplicationController
  def create
    @taggable_type = params[:taggable_type]
    @tag_name = params[:value]
  end
end
