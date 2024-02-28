class Units::DocumentsController < UnitContextController
  def index
    @documents = @unit.documents
    @home_layout = YAML.load(@unit.settings(:documents).home_layout)
  end

  def list
    @documents = @unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
  end

  def grid
    @documents = @unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
  end

  def create
    @documents = []
    files = params[:documents].reject(&:blank?)
    files.each { |file| @documents << @unit.documents.create!(file: file) }
  end

  def destroy
    @document = @unit.documents.find(params[:id])
    @document.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@document) }
    end
  end

  def bulk_update
    ap params
    @documents = @unit.documents.find(params[:document_ids])
    @documents.each do |document|
      ap document
    end
  end
end
