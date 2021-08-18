class ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper

  def sp_date_picker(start_field, end_field, options = {})
    label = "#{start_field}_#{end_field}"
    return content_tag(:div, '', class: 'sp-date-picker', id: field_id(label))
  end

  def field_name(label,index=nil)
    output = index ? "[#{index}]" : ''
    return @object_name + output + "[#{label}]"
  end

  def field_id(label,index=nil)
    output = index ? "_#{index}" : ''
    return @object_name + output + "_#{label}"
  end

end
