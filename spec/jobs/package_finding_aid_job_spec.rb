require 'rails_helper'

RSpec.describe PackageFindingAidJob, type: :job do
  include ActiveJob::TestHelper

  let(:identifier) { 'eadid.slug' }
  let(:format) { 'html' }

  before do
    allow(FindingAids::PackageArtifact).to receive(:call)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job on the index queue' do
    expect { described_class.perform_later(identifier, format) }
      .to have_enqueued_job(described_class).with(identifier, format).on_queue('index')
  end

  it 'delegates packaging to the service' do
    expect { described_class.perform_now(identifier, format) }.not_to raise_error
    expect(FindingAids::PackageArtifact).to have_received(:call).with(identifier, format)
  end
end
