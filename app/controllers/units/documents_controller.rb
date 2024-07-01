class Units::DocumentsController < UnitContextController
  def index
    authorize Document, policy_class: UnitDocumentPolicy
    @documents = current_unit.documents
    @home_layout = YAML.load(current_unit.settings(:documents).home_layout)
  end

  def create
    authorize Document, policy_class: UnitDocumentPolicy
    @documents = []
    files = params[:documents].reject(&:blank?)
    files.each { |file| @documents << current_unit.documents.create!(file: file) }
    redirect_to tag_unit_documents_path(current_unit, :all)
  end

  def update
    authorize Document, policy_class: UnitDocumentPolicy
  end

  def destroy
    @document = current_unit.documents.find(params[:id])
    authorize @document, policy_class: UnitDocumentPolicy
    @document.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@document) }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def tag
    authorize Document, policy_class: UnitDocumentPolicy
    redirect_to tag_variant_unit_documents_path(current_unit, tag: params[:tag], variant: cookies[:documents_variant] || "list") unless params[:variant].present?

    cookies[:documents_variant] = params[:variant]

    @tag = params[:tag]
    scope = current_unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
    scope = scope.tagged_with(params[:tag]) if @tag.present? && @tag != "all"
    @title = @tag.downcase == "all" ? "All documents" : @tag.titleize
    @documents = scope.all
    @can_delete = UnitDocumentPolicy.new(current_member, Document).destroy?
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def bulk_update
    authorize Document, policy_class: UnitDocumentPolicy

    tags = params[:multi_select_action][:tags]
    filename = params[:multi_select_action][:filename]
    document_date = params[:multi_select_action][:document_date]
    documents = current_unit.documents.where(id: params[:document_ids])

    documents.each do |document|
      document.document_tag_list.add(tags, parse: true) if tags.present?
      document.file.blob.update(filename: filename) if filename.present?
      document.update(document_date: document_date) if document_date.present?
      document.save
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
