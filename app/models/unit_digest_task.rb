# frozen_string_literal: true

# Subclass for sending unit digests to members
class UnitDigestTask < UnitTask
  def description
    I18n.t("tasks.unit_digest_description")
  end

  def perform
    Rails.logger.warn { "Sending Unit Digest for #{unit.name}" }

    unit.members.find_each do |member|
      perform_for_member(member)
    end

    super
  end

  def perform_for_member(member)
    return unless Flipper.enabled? :digest, member

    # Time.zone = member.unit.settings(:locale).time_zone
    Rails.logger.warn { "Sending Unit Digest to #{member.flipper_id}" }
    MemberNotifier.new(member).send_digest
  end
end
