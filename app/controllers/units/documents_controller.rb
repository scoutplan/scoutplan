class Units::DocumentsController < UnitContextController
  def index
    @documents = @unit.documents
    @home_layout = YAML.load(@unit.settings(:documents).home_layout)
  end

  def list
    scope = @unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
    scope = scope.tagged_with(params[:tag]) if params[:tag].present?
    @documents = scope.all
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

  def tag
    scope = @unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
    scope = scope.tagged_with(params[:tag]) if params[:tag].present? && params[:tag] != "all"
    @documents = scope.all
  end

  def bulk_update
    # ap params
    tags = params[:multi_select_action][:tags]

    params[:document_ids].each do |document_id|
      document = @unit.documents.find(document_id)
      document.document_tag_list.add(tags, parse: true)
      # ap document
      document.save
    end
  end
end
