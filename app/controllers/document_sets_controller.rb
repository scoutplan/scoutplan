class DocumentSetsController < UnitContextController
  def new
    doc_ids = params[:document_ids].split(",")
    @documents = Document.find(doc_ids)
    respond_to do |format|
      format.turbo_stream
    end
  end
end
