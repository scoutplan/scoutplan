# frozen_string_literal: true

class ScoutplanMailer < ApplicationMailer
  before_action :find_member
  before_action :find_unit
  before_action :attach_logo

  def attach_logo
    return unless @unit&.logo&.attached?

    attachments.inline['logo'] = @unit.logo.blob.download
  end

  def find_member
    @member = params[:member]
  end

  def find_unit
    @unit = @member.unit
  end
end
