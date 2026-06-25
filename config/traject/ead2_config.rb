# frozen_string_literal: true

# Load the arclight gem's default EAD2 traject configuration first.
# All additions and modifications below are kept separate from the upstream defaults.
load_config_file Arclight::Engine.root.join("lib/arclight/traject/ead2_config.rb").to_s

# ==========================================
# Boxrunner-specific additions / overrides
# ==========================================
to_field 'component_level_isim' do |record, accumulator|
  accumulator << 1 + NokogiriXpathExtensions.new.is_component(record.ancestors).count
end