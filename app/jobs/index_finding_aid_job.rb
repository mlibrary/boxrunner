# require 'dul_arclight/errors'       # TODO: add dul_arclight gem
# require 'um_arclight/errors'         # TODO: add um_arclight gem

# require_dependency "um_arclight/package/generator"  # TODO: add um_arclight gem

class IndexFindingAidJob < ApplicationJob
  queue_as :index

  def perform(src_path, repo_id)
    FindingAids::IndexFromEad.call(src_path, repo_id)
  end
end
