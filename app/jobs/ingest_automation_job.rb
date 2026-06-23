# frozen_string_literal: true

# require_dependency "um_arclight/package/generator"  # TODO: add um_arclight gem

class IngestAutomationJob < ApplicationJob
  queue_as :automation

  def perform(event, details)
    unless Rails.configuration.x.arclight.enable_automation
      logger.debug <<~EOM
        Ingest automation attempted, but disabled...
        Set config.x.arclight.enable_automation = true if you want it to run.
        event: #{event}, details: #{details}
      EOM
      return
    end

    IngestAutomation::Dispatch.call(event, details, logger: logger)
  end
end
