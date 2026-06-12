# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngestAutomationJob, type: :job do
  describe 'queue' do
    it 'is enqueued on the default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end

    it 'enqueues the job' do
      expect { described_class.perform_later }
        .to have_enqueued_job(described_class).on_queue('default')
    end
  end

  describe '#perform' do
    it 'runs without raising an error' do
      expect { described_class.perform_now }.not_to raise_error
    end
  end
end
