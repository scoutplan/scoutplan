class WikiPagesController < UnitContextController
  before_action :find_page, only: [:show, :edit, :update, :destroy, :history]
  skip_before_action :authenticate_user!, only: [:index, :show]
  layout :select_layout

  def index
    @pages = find_pages
    @tags = @pages.collect(&:wiki_page_tags).flatten.uniq
  end

  def new
    @page = current_unit.wiki_pages.new
    authorize @page
  end

  def create
    @page = current_unit.wiki_pages.new(wiki_page_params)
    authorize @page
    if @page.save
      redirect_to unit_wiki_pages_path(current_unit)
    else
      render :action => :new
    end
  end

  def show
    authorize @page
  end

  def edit
    authorize @page
  end

  def update
    authorize @page
    if @page.update!(wiki_page_params)
      redirect_to unit_wiki_pages_path(current_unit)
    else
      render :action => :edit
    end
  end

  def history
    authorize @page
  end

  private

  def wiki_page_params
    params.require(:wiki_page).permit(:title, :body, :wiki_page_tag_list, :visibility)
  end

  def find_page
    @page = current_unit.wiki_pages.find(params[:id] || params[:wiki_page_id])
  end

  def find_pages
    return current_unit.wiki_pages.anyone unless user_signed_in?

    return current_unit.wiki_pages.anyone | current_unit_wiki_pages.members_only unless current_member.admin?

    current_unit.wiki_pages
  end


  def select_layout
    return "application" if user_signed_in?

    "public"
  end
end
