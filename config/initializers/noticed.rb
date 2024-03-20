# module Noticed
#   class ApplicationJob
#     discard_on Noticed::ResponseUnsuccessful
#   end
# end

# refine Noticed::ApplicationJob do
#   discard_on Noticed::ResponseUnsuccessful
# end


Noticed.parent_class = "Scoutplan::Noticed::ApplicationJob"
