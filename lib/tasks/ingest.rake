# frozen_string_literal: true

require "arclight"
require "arclight/repository"

# Read the repository configuration
repo_config = YAML.safe_load(File.read("./config/repositories.yml"))

namespace :arclight do
  # FIXME: SHAMELESS copy of dul_arclight:reindex_everything for now
  desc "Reingest all finding aids in the data directory via background jobs"
  task ingest_everything: :environment do
    data_path = "./data/ead"
    puts "Looking in #{data_path} ..."

    # Find our configured repositories, get their IDs
    repo_config.keys.each do |repo_id|
      puts "repo ID : #{repo_id}"
      puts "working directory : "
      Dir.glob(File.join(Rails.root, "data", "ead", repo_id, "*.xml")) do |path|
        puts "Queuing #{path} for Ingest..."
        IngestFindingAidJob.perform_later("ingest.file", repo_id: repo_id, file_path: path)
      end
    end

    puts "All collections queued for Ingest."
  end
end
