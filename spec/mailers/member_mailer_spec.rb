require 'rails_helper'

RSpec.describe MemberMailer, type: :mailer do
  describe 'invitation email' do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @mail = MemberMailer.with(member: @member).invitation_email
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq("Welcome to #{@unit.name}")
    end

    it 'renders the body' do
    end
  end

  describe 'digest email' do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @mail = MemberMailer.with(member: @member).digest_email
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq("#{@unit.name} Digest")
    end

    it 'renders the body' do
    end
  end

  describe 'daily reminder email' do
    before do
      @member = FactoryBot.create(:member)
      @unit = @member.unit
      @mail = MemberMailer.with(member: @member).daily_reminder_email
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq("#{@unit.name} — Event Reminder")
    end

    it 'renders the body' do
    end
  end
end
