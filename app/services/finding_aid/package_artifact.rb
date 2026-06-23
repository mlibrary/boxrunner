# frozen_string_literal: true

module FindingAid
  class PackageArtifact
    FORMATS = %w[html pdf].freeze

    def self.call(identifier, format)
      unless FORMATS.include?(format)
        raise ::UmArclight::GenerateError, identifier, "Unsupported format requested: #{format}"
      end

      convert(identifier, format)
    end

    def self.convert(identifier, format)
      artifact = ::UmArclight::Package::Generator.new identifier: identifier
      format == "html" ? artifact.generate_html : artifact.generate_pdf
      ::IngestFindingAidJob.perform_later "#{format}.success", ead_id: identifier
    rescue => error
      ::IngestFindingAidJob.perform_later "#{format}.failure", ead_id: identifier
      raise ::UmArclight::GenerateError, identifier, error.to_s
    end

    private_class_method :convert
  end
end
