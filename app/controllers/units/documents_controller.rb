class Units::DocumentsController < UnitContextController
  def index
    @documents = @unit.documents
    @home_layout = YAML.load(@unit.settings(:documents).home_layout)
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

  # rubocop:disable Metrics/AbcSize
  def tag
    redirect_to tag_variant_unit_documents_path(@unit, tag: params[:tag], variant: cookies[:documents_variant] || "list") unless params[:variant].present?

    cookies[:documents_variant] = params[:variant]

    @tag = params[:tag]
    scope = @unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
    scope = scope.tagged_with(params[:tag]) if @tag.present? && @tag != "all"
    @title = @tag.downcase == "all" ? "All documents" : @tag.titleize
    @documents = scope.all
  end
  # rubocop:enable Metrics/AbcSize

  def bulk_update
    tags = params[:multi_select_action][:tags]

    params[:document_ids].each do |document_id|
      document = @unit.documents.find(document_id)
      document.document_tag_list.add(tags, parse: true)
      document.save
    end
  end
end
