# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FindingAids::PackageArtifact do
  let(:identifier) { 'eadid.slug' }
  let(:generator) { instance_double(UmArclight::Package::Generator) }

  before do
    stub_const('UmArclight::GenerateError', Class.new(StandardError))
    generator_class = Class.new do
      def initialize(identifier:); end

      def generate_html; end

      def generate_pdf; end
    end
    stub_const('UmArclight::Package::Generator', generator_class)

    allow(UmArclight::Package::Generator).to receive(:new).with(identifier: identifier).and_return(generator)
    allow(generator).to receive(:generate_html)
    allow(generator).to receive(:generate_pdf)
    allow(IngestAutomationJob).to receive(:perform_later)
  end

  context 'when the format is html' do
    it 'generates html and enqueues an html.success event' do
      expect { described_class.call(identifier, 'html') }.not_to raise_error
      expect(generator).to have_received(:generate_html)
      expect(generator).not_to have_received(:generate_pdf)
      expect(IngestAutomationJob).to have_received(:perform_later).with('html.success', ead_id: identifier)
    end
  end

  context 'when the format is pdf' do
    it 'generates pdf and enqueues a pdf.success event' do
      expect { described_class.call(identifier, 'pdf') }.not_to raise_error
      expect(generator).to have_received(:generate_pdf)
      expect(generator).not_to have_received(:generate_html)
      expect(IngestAutomationJob).to have_received(:perform_later).with('pdf.success', ead_id: identifier)
    end
  end

  context 'when the format is unsupported' do
    it 'raises a GenerateError without generating or enqueuing' do
      expect { described_class.call(identifier, 'txt') }
        .to raise_error(UmArclight::GenerateError, identifier)
      expect(UmArclight::Package::Generator).not_to have_received(:new)
      expect(IngestAutomationJob).not_to have_received(:perform_later)
    end
  end

  context 'when generation fails' do
    before do
      allow(generator).to receive(:generate_html).and_raise(StandardError, 'boom')
    end

    it 'enqueues a failure event and re-raises as a GenerateError' do
      expect { described_class.call(identifier, 'html') }
        .to raise_error(UmArclight::GenerateError, identifier)
      expect(IngestAutomationJob).to have_received(:perform_later).with('html.failure', ead_id: identifier)
      expect(IngestAutomationJob).not_to have_received(:perform_later).with('html.success', ead_id: identifier)
    end
  end
end
