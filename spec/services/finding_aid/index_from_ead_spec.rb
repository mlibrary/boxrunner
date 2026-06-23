# frozen_string_literal: true

require 'rails_helper'
require 'stringio'

RSpec.describe FindingAid::IndexFromEad do
  let(:src_path) { 'path/to/file.xml' }
  let(:repo_id) { 'repo' }

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
    before do
      allow(File).to receive(:open)
        .with(src_path, 'r:UTF-8:UTF-8')
        .and_return(StringIO.new('<ead></ead>'))
    end

    it 'return ead_id' do
      expect ( described_class.call(src_path, repo_id)).to be_a String
    end
  end
end
