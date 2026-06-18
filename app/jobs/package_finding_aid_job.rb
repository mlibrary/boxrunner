# frozen_string_literal: true

# require 'um_arclight/errors'           # TODO: add um_arclight gem
# require 'um_arclight/package/generator'  # TODO: add um_arclight gem

# Job to queue packaging
class PackageFindingAidJob < ApplicationJob
  queue_as :index

  def perform(identifier, format)
    FindingAids::PackageArtifact.call(identifier, format)
  end
end
