# frozen_string_literal: true
class IngestRecordFindingAidJob < ApplicationJob
  queue_as :index

  def perform(id)
    FindingAids::IngestRecord.call(id)
  end
end
