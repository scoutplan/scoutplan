# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventMailer, type: :mailer do
  # describe 'token_invitation_email' do
  #   before do
  #     @token = FactoryBot.create(:rsvp_token)
  #     @mail = EventMailer.with(token: @token, member: @token.member).token_invitation_email
  #   end

  #   it 'renders the headers' do
  #     expect(@mail.subject).to eq("#{@token.unit.name} Event Invitation: #{@token.event.title}")
  #   end

  #   it 'renders the body' do
  #   end
  # end

  # describe 'bulk_publish_email' do
  #   before do
  #     @member = FactoryBot.create(:member)
  #     @mail = EventMailer.with(
  #       unit: @member.unit,
  #       user: @member.user,
  #       event_ids: @member.unit.events.map(&:id),
  #       member: @member
  #     ).bulk_publish_email
  #   end

  #   it 'renders the headers' do
  #     expect(@mail.subject).to eq("#{@member.unit.name}: New Events Have Been Added to the Calendar")
  #   end

  #   it 'renders the body' do
  #     expect(@mail.body.encoded).to match('New Calendar Items')
  #   end
  # end

  # describe 'rsvp_confirmation_email' do
  #   before do
  #     @rsvp = FactoryBot.create(:event_rsvp)
  #     @mail = EventMailer.with(rsvp: @rsvp, member: @rsvp.member).rsvp_confirmation_email
  #   end

  #   it 'renders the headers' do
  #     expect(@mail.subject).to eq("#{@rsvp.unit.name}: Your RSVP for #{@rsvp.event.title} has been received")
  #   end
  # end
end
