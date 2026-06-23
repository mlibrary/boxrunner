# frozen_string_literal: true
class DeleteFindingAidJob < ApplicationJob
  queue_as :delete

  def perform(eadid)
    FindingAids::DeleteFromIndex.call(eadid)
  end
end
