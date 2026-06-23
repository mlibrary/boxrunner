# frozen_string_literal: true
class IngestFindingAidJob < ApplicationJob
  queue_as :index

  def perform(id)
    FindingAids::IngestRecord.call(id)
  end
end
