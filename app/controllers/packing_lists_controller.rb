class PackingListsController < UnitContextController
  before_action :find_packing_list, except: [:index, :new, :create]
  
  def index
  end

  def create
    authorize :packing_list, :create?
    @packing_list = current_unit.packing_lists.new(packing_list_params)
    if @packing_list.save
      redirect_to unit_packing_list_path(current_unit, @packing_list)
    else
      render :new
    end
  end

  def destroy
    authorize @packing_list
    if @packing_list.destroy
      redirect_to unit_packing_lists_path(current_unit)
    else
      render :show
    end
  end

  def new
    @packing_list = PackingList.new
  end

  def show
    @packing_list = current_unit.packing_lists.find(params[:id])
    authorize @packing_list
  end

  private

  def packing_list_params
    params.require(:packing_list).permit(:name)
  end

  def find_packing_list
    @packing_list = current_unit.packing_lists.find(params[:id])
  end
end
