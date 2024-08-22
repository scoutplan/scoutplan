module ThroughAssociations
  extend ActiveSupport::Concern

  # included do
  #   after_save_commit :save_through_associations
  # end

  module ClassMethods
    def accepts_through_attributes_for(join_model, options = {})
      key = [options[:joining], options[:key]].map(&:to_s).join("_") # unit_membership_id
      joined_model = options[:joining]
      association_name = [join_model, joined_model].map(&:to_s).join("_")

      module_eval <<-EORUBY, __FILE__, __LINE__ + 1
        def #{association_name}=(values)  # def event_organizers_unit_membership_id=(values)
          @#{association_name} = values   #   @event_organizers_unit_membership_id = values
        end                               # end

        def #{association_name}           # def event_organizers_unit_membership_id=(values)
          @#{association_name} || []      #   @event_organizers_unit_membership_id || []
        end                               # end

        def save_#{association_name}_associations
          return unless @#{association_name}.present?

          #{join_model}.where("#{key} NOT IN (?)", @#{association_name}).destroy_all            #   event_organizers.where("unit_membership_id NOT IN (?)", values).destroy_all
          @#{association_name}.map { |value| #{join_model}.find_or_create_by(#{key}: value) }   #   @event_organizers_unit_membership.map { |value| event_organizers.find_or_create_by(unit_membership_id: value) }
        end

        after_save_commit :save_#{association_name}_associations
      EORUBY
    end
  end
end
