class TagsController < ApplicationController
  def create
    @taggable = GlobalID::Locator.locate params[:taggable_gid]
    @tag_name = params[:value]
  end
end
