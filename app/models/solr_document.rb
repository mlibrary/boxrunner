# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Repository request mappings may reference these legacy-style accessors.
  def physloc
    first("physloc_tesim") || first("physloc_ssm")
  end

  def collection_date
    normalized_date || collection&.normalized_date
  end
  def repository_id
    repository_config&.slug
  end
  def repository_config
    return unless repository

    @repository_config ||= Arclight::Repository.find_by(name: repository)
  end
  def repository
    first('repository_ssm')
  end
end
