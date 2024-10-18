class Units::DocumentsController < UnitContextController
  # layout :select_layout

  def index
    authorize Document, policy_class: UnitDocumentPolicy
    @documents = current_unit.documents
    @home_layout = YAML.load(current_unit.settings(:documents).home_layout)
    redirect_to files_unit_documents_path(current_unit) if @home_layout.empty?
  end

  def create
    authorize Document, policy_class: UnitDocumentPolicy
    @documents = []
    files = params[:documents].reject(&:blank?)
    files.each { |file| @documents << current_unit.documents.create!(file: file) }
    redirect_to files_unit_documents_path(current_unit)
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

  def tag
    authorize Document, policy_class: UnitDocumentPolicy

    cookies[:documents_variant] = params[:variant]

    scope = current_unit.documents.includes(file_attachment: :blob).order("active_storage_blobs.filename ASC")
    @documents = scope.all
    @can_delete = UnitDocumentPolicy.new(current_member, Document).destroy?
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def batch_update
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

  def batch_delete
    authorize Document, policy_class: UnitDocumentPolicy
    @document_ids = params[:document_ids].split(",")
    current_unit.documents.where(id: @document_ids).destroy_all
  end

  def batch_tag
    authorize Document, policy_class: UnitDocumentPolicy
    batch_apply_tag(:add)
  end

  def batch_untag
    authorize Document, policy_class: UnitDocumentPolicy
    batch_apply_tag(:remove)
  end

  # rubocop:disable Metrics/AbcSize
  def batch_apply_tag(operation)
    @document_ids = params[:document_ids].split(",")
    @documents = current_unit.documents.where(id: @document_ids)
    @tag_name = params[:tag_name]
    @can_delete = UnitDocumentPolicy.new(current_member, Document).destroy?
    @documents.each do |document|
      document.document_tag_list.add(@tag_name) if operation == :add
      document.document_tag_list.remove(@tag_name) if operation == :remove
      document.save
    end
  end
  # rubocop:enable Metrics/AbcSize

  def select_layout
    return "full_page" if action_name == "tag"

    "application"
  end
end
