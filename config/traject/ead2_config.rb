# frozen_string_literal: true

def remove_to_field_def(field_name)
  instance_variable_get(:@index_steps).reject! { |f| f.instance_variable_get(:@field_name) == field_name }
end

# Load the arclight gem's default EAD2 traject configuration first.
# All additions and modifications below are kept separate from the upstream defaults.
load_config_file Arclight::Engine.root.join("lib/arclight/traject/ead2_config.rb").to_s

# ==========================================
# Boxrunner-specific additions / overrides
# ==========================================

# Utilize genreform for Formats facet

remove_to_field_def "access_subjects_ssim"
remove_to_field_def "access_subjects_ssm"

to_field "access_subjects_ssim", extract_xpath("/ead/archdesc/controlaccess", to_text: false) do |_record, accumulator|
  accumulator.map! do |element|
    %w[subject function occupation].map do |selector|
      element.xpath(".//#{selector}").map(&:text)
    end
  end.flatten!
  p accumulator
end

to_field "access_subjects_ssm" do |_record, accumulator, context|
  accumulator.concat Array.wrap(context.output_hash["access_subjects_ssim"])
end

to_field "formats_ssim", extract_xpath("/ead/archdesc/controlaccess/genreform|/ead/archdesc/controlaccess/controlaccess/genreform")
to_field "formats_ssm" do |_record, accumulator, context|
  accumulator.concat Array.wrap(context.output_hash["formats_ssim"])
end
