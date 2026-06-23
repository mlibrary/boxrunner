# frozen_string_literal: true

# require 'um_arclight/errors'           # TODO: add um_arclight gem
# require 'um_arclight/package/generator'  # TODO: add um_arclight gem

# Job to queue packaging
class IngestAutomationPackageJob < ApplicationJob
  queue_as :index

  def perform(identifier, format)
    FindingAid::PackageArtifact.call(identifier, format)
    IngestAutomationJob.perform_later("#{format}.success", ead_id: identifier, err_msg: nil)
  rescue ::UmArclight::GenerateError => e
    IngestAutomationJob.perform_later("#{format}.failure", ead_id: identifier, err_msg: e.message)
  end
end
