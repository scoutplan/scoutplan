class DocumentSet
  attr_reader :unit, :document_ids

  def initialize(unit, document_ids)
    @unit = unit
    @document_ids = document_ids
  end

  def add_tag(tag)
    documents.each do |document|
      document.document_tag_list.add(tag)
      document.save
    end
  end

  def remove_tag(tag)
    documents.each do |document|
      document.document_tag_list.remove(tag)
      document.save
    end
  end

  def documents
    @documents ||= unit.documents.find(document_ids)
  end

  def common_tags
    @common_tags ||= documents.map(&:document_tag_list).reduce(:&)
  end

  def common_date
    @common_date ||= documents.map(&:document_date).uniq.count == 1 ? documents.first.document_date : nil
  end

  def update_all(params)
    documents.each do |document|
      document.update!(params)
    end
  end

  def destroy_all
    @documents ||= unit.documents.find(document_ids)
    documents.each(&:destroy)
  end

  def assign_date(common_date)
    common_date = common_date.to_date
    documents.each do |document|
      document.document_date = common_date
      document.save!
      document.reloadupper
    end
  end
end
