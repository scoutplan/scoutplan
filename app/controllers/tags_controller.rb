class TagsController < ApplicationController
  def create
    @tag_name = params[:value]
  end
end
