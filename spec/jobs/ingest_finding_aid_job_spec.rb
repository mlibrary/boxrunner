require 'rails_helper'

RSpec.describe IngestFindingAidJob, type: :job do
  include ActiveJob::TestHelper

  let(:id) { 'id' }

  before do
    allow(FindingAids::IngestRecord).to receive(:call)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { described_class.perform_later(id) }.to have_enqueued_job(described_class).with(id).on_queue("index")
  end

  it 'delegates ingest record work to the service' do
    expect { described_class.perform_now(id) }.not_to raise_error
    expect(FindingAids::IngestRecord).to have_received(:call).with(id)
  end
end

