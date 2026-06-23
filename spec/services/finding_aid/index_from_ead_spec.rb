# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::IndexFromEad do
  let(:src_path) { 'path/to/file.xml' }
  let(:repo_id) { 'bhl' }
  let(:fixture_path) { Rails.root.join('spec/fixtures/bhl/umich-bhl-032.xml') }

  context 'when source open fails' do
    before do
      allow(File).to receive(:open).with(src_path, 'r:UTF-8:UTF-8').and_raise(StandardError, 'boom')
    end

    it 'raises FindingAidIndexError' do
      expect { described_class.call(src_path, repo_id) }
        .to raise_error(FindingAidIndexError, 'boom')
    end
  end

  context 'when source open succeed' do
    it 'return ead_id' do
      x = described_class.call(fixture_path, repo_id)
      expect(x).to eq "umich-bhl-032"
    end
  end
end
