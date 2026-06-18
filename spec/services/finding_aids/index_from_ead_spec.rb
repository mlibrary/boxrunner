require 'rails_helper'

RSpec.describe FindingAids::IndexFromEad do
  let(:src_path) { 'path/to/file.xml' }
  let(:repo_id) { 'repo' }

  before do
    stub_const('Box::IndexError', Class.new(StandardError))
    allow(IngestAutomationJob).to receive(:perform_later)
  end

  context 'when source open fails' do
    before do
      allow(File).to receive(:open).with(src_path, 'r:UTF-8:UTF-8').and_raise(StandardError, 'boom')
    end

    it 'enqueues index.failure and raises Box::IndexError' do
      expect { described_class.call(src_path, repo_id) }
        .to raise_error(Box::IndexError, 'boom')

      expect(IngestAutomationJob).to have_received(:perform_later).with(
        'index.failure',
        src_path: src_path,
        archive_path: nil,
        ead_id: nil,
        err_msg: 'boom'
      )
    end
  end
end

