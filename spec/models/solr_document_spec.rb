# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolrDocument do
  describe "request mapping compatibility accessors" do
    it "returns physloc from physloc_tesim" do
      document = described_class.new("physloc_tesim" => [ "Offsite shelving" ])

      expect(document.physloc).to eq("Offsite shelving")
    end

    it "returns collection_date from normalized_date" do
      document = described_class.new("normalized_date_ssm" => [ "1974-1996" ])

      expect(document.collection_date).to eq("1974-1996")
    end

    it "falls back collection_date to collection normalized_date" do
      document = described_class.new(
        "collection" => {
          "docs" => [
            {
              "id" => "umich-root",
              "normalized_date_ssm" => [ "1888-1928" ]
            }
          ]
        }
      )

      expect(document.collection_date).to eq("1888-1928")
    end
  end
end
