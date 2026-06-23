# frozen_string_literal: true

# require 'dul_arclight/errors'       # TODO: add dul_arclight gem
# require 'um_arclight/errors'         # TODO: add um_arclight gem

# require_dependency "um_arclight/package/generator"  # TODO: add um_arclight gem

class IndexFindingAidJob < ApplicationJob
  queue_as :index

  def perform(src_path, repo_id)
      FindingAid::IndexFromEad.call(src_path, repo_id)
      IngestFindingAidJob.perform_later("index.success", src_path: src_path, repo_id: repo_id, ead_id: nil, err_msg: nil)

  rescue FindingAidIndexError => e
    IngestFindingAidJob.perform_later("index.failure", src_path: src_path, repo_id: repo_id, ead_id: nil, err_msg: e.message)
  end
end
