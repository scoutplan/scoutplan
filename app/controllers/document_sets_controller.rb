class DocumentSetsController < UnitContextController
  include ActionView::RecordIdentifier

  def destroy
    @document_set = DocumentSet.new(current_unit, document_ids)
    @document_set.destroy_all
  end

  # params = { :document_set => { :document_date: "2021-10-01", :document_tag => { :name => "tag1", :_destroy => "true" } }
  def update
    @document_set = DocumentSet.new(current_unit, document_ids)
    @document_set.update_all(document_set_params)

    respond_to(&:turbo_stream)

    # respond_to do |format|
    #   format.turbo_stream
    # end
  end

  def new
    @document_set = DocumentSet.new(current_unit, document_ids)
    # rubocop:disable Style/SymbolProc
    respond_to do |format|
      format.turbo_stream
    end
    # rubocop:enable Style/SymbolProc
  end

  private

  def document_ids
    params[:document_ids].split(",").map(&:to_i)
  end

  def document_set_params
    params.require(:document_set).permit(:document_date, document_tag: [:name, :_destroy])
  end
end
