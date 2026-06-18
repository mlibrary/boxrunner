# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngestAutomationJob, type: :job do
  describe 'queue' do
    it 'is enqueued on the default queue' do
      expect(described_class.new("event", {}).queue_name).to eq('automation')
    end

    it 'enqueues the job' do
      expect { described_class.perform_later("event", {}) }
        .to have_enqueued_job(described_class).on_queue('automation')
    end
  end

  describe '#perform' do
    it 'runs without raising an error' do
      expect { described_class.perform_now("event", {}) }.not_to raise_error
    end
  end
end
