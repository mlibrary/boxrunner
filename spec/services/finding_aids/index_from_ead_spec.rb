require 'rails_helper'

RSpec.describe FindingAids::IndexFromEad do
  let(:src_path) { 'path/to/file.xml' }
  let(:repo_id) { 'repo' }

  before do
    stub_const('Box::IndexError', Class.new(StandardError))
  end

  context 'when source open fails' do
    before do
      allow(File).to receive(:open).with(src_path, 'r:UTF-8:UTF-8').and_raise(StandardError, 'boom')
    end

    it 'raises Box::IndexError' do
      expect { described_class.call(src_path, repo_id) }
        .to raise_error(Box::IndexError, 'boom')
    end
  end
end

