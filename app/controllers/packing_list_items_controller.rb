class PackingListItemsController < UnitContextController
  before_action :find_packing_list
  before_action :find_packing_list_item, only: [:show, :edit, :update, :destroy]

  def create
    @packing_list_item = @packing_list.packing_list_items.create(packing_list_item_params)
    redirect_to unit_packing_list_path(@unit, @packing_list)
  end

  def edit; end

  def new
    @packing_list_item = @packing_list.packing_list_items.new
  end

  def update
    @packing_list_item.update(packing_list_item_params)
    redirect_to unit_packing_list_path(@unit, @packing_list)
  end

  private

  def find_packing_list
    @packing_list = @unit.packing_lists.find(params[:packing_list_id])
  end

  def find_packing_list_item
    @packing_list_item = @packing_list.packing_list_items.find(params[:id])
  end

  def packing_list_item_params
    params.require(:packing_list_item).permit(:name)
  end
end
