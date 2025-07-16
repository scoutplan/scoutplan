module NestedKeys
  extend ActiveSupport::Concern

  # defines a class method that allows models to accept nested keys for a specified model and key name
  # Example usage:
  #
  # class Message < ApplicationRecord
  #   include NestedKeys
  #   accepts_nested_keys_for :message_recipients, :unit_membership_id
  # end
  #
  # This will create a method `message_recipients_keys=` that can be used to set the keys for message recipients
  # It will destroy any existing records that do not match the provided keys and create new ones for the provided keys.
  # This is useful for simple join tables or associations where you only need to manage the keys rather than the full
  # attributes of the associated records.
  #
  # Unlike `accepts_nested_attributes_for`:
  # - this does not handle attributes but rather just the keys.
  # - it does not allow for nested attributes to be passed in, only the keys themselves.
  # - it implicitly destroys existing records that do not match the provided keys without needing to specify
  #   `allow_destroy: true` and does not require the `:_destroy` attribute.
  #

  class_methods do
    def accepts_nested_keys_for(model_name, key_name)
      module_eval <<-RUBY, __FILE__, __LINE__ + 1
        after_save do
          keys = self.#{model_name}_keys                                              # keys = self.message_recipients_keys
          self.#{model_name}.where.not(#{key_name}: keys).destroy_all                 # self.message_recipients.where.not(unit_membership_id: keys).destroy_all
          keys.each do |key|                                                          # keys.each do |key|
            self.#{model_name}.find_or_create_by!(#{key_name}: key)                   # MessageRecipients.find_or_create_by!(unit_membership_id: key)
          end                                                                         # end
        end

        attr_accessor :#{model_name}_keys                                     # attr_accessor :message_recipients_keys
      RUBY
    end
  end
end
