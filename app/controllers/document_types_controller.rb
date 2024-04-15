class DocumentTypesController < EventContextController
  before_action :find_document_type, only: [:show, :edit, :destroy]

  def index
    @document_types = @event.document_types
  end

  def show
  end

  def edit
  end

  def new
    @document_type = DocumentType.new
  end

  def create
    @document_type = @event.document_types.new(document_type_params)
    redirect_to [current_unit, @event], notice: "Document type added" if @document_type.save!
  end

  def destroy
  end

  private

  def document_type_params
    params.require(:document_type).permit(:description, :required)
  end
end
