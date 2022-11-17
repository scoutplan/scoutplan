class PackingListItemsController < UnitContextController
  before_action :find_packing_list

  def create
    @packing_list_item = @packing_list.packing_list_items.create(packing_list_item_params)
  end

  def new
    @packing_list_item = @packing_list.packing_list_items.new
  end

  private

  def find_packing_list
    @packing_list = @unit.packing_lists.find(params[:packing_list_id])
  end

  def packing_list_item_params
    params.require(:packing_list_item).permit(:name)
  end
end
