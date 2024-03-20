module Scoutplan
  module Noticed
    class ApplicationJob < ActiveJob::Base
      discard_on ActiveJob::DeserializationError
      discard_on ::Noticed::ResponseUnsuccessful
    end
  end
end
