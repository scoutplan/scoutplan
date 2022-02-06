# https://www.brandnewbox.com/notes/2021/03/form-builders-in-ruby/

# An app-specific form builder that adds a few tags
class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  LABEL_CLASSES = "block uppercase mb-2 md:mb-0 text-sm font-bold tracking-wide".freeze
  LABEL_CLASSES_INLINE = "md:inline-block md:w-[25%]".freeze

  # build a label tag that's properly styled via Tailwind
  # def styled_label(attribute, args = {})
  def styled_label(method, text = nil, options = {}, &block)
    options = text if text.is_a? Hash
    classes = LABEL_CLASSES.dup
    classes << " " << LABEL_CLASSES_INLINE if options[:layout] == :inline
    classes.gsub! "block", "inline-block" if options[:layout] == :checkbox
    options[:class] = ((options[:class] || "") << " " << classes).strip
    label(method, text, options, &block)
  end
end
