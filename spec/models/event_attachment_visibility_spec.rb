# frozen_string_literal: true

require "rails_helper"

# The edit form expresses attachment visibility by choosing which of the two
# has_many_attached collections carries a signed_id on submit. These specs pin
# the model behaviour that makes that safe.
describe Event do
  include ActiveJob::TestHelper

  let(:member) { FactoryBot.create(:member, :admin) }
  let(:event) { FactoryBot.create(:event, unit: member.unit) }

  def attach_public(filename)
    event.attachments.attach(
      io: StringIO.new("permission slip"), filename: filename, content_type: "text/plain"
    )
    event.attachments.find { |a| a.filename.to_s == filename }.blob
  end

  describe "moving an attachment between visibility sets" do
    it "keeps the blob and its stored file" do
      blob = attach_public("slip.txt")

      perform_enqueued_jobs do
        event.update!(attachments: [], private_attachments: [blob.signed_id])
      end
      event.reload

      expect(event.attachments.count).to eq(0)
      expect(event.private_attachments.count).to eq(1)
      expect(ActiveStorage::Blob.exists?(blob.id)).to be(true)
      expect(blob.service.exist?(blob.key)).to be(true)
      expect(event.private_attachments.first.blob.download).to eq("permission slip")
    end

    it "clears a collection when only the form's blank sentinel is submitted" do
      attach_public("slip.txt")

      perform_enqueued_jobs { event.update!(attachments: [""]) }

      expect(event.reload.attachments.count).to eq(0)
    end

    it "ignores the blank sentinel alongside a real signed_id" do
      blob = attach_public("slip.txt")

      perform_enqueued_jobs { event.update!(attachments: ["", blob.signed_id]) }

      expect(event.reload.attachments.count).to eq(1)
    end
  end

  describe "validation" do
    it "rejects a disallowed content type in the private set" do
      event.private_attachments.attach(
        io: StringIO.new("#!/bin/sh"), filename: "hack.sh", content_type: "application/x-sh"
      )

      expect(event).not_to be_valid
      expect(event.errors[:private_attachments]).to be_present
    end

    it "accepts an allowed content type in the private set" do
      event.private_attachments.attach(
        io: StringIO.new("receipt"), filename: "receipt.txt", content_type: "text/plain"
      )

      expect(event).to be_valid
    end
  end
end
