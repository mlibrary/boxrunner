# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::Package::Generator do
  subject(:generator) { described_class.new(identifier: identifier) }

  let(:identifier) { 'umich-test-9999' }

  before do
    allow(generator).to receive(:fetch_doc) do |_identifier| # rubocop:disable RSpec/SubjectStub
      SolrDocument.new(
        'id': 'umich-test-9999',
        'normalized_title_ssm': [ 'Finding Aid' ],
        'ead_author_ssm': [ 'Finding Aid written by E. A. Document' ],
        'repository_ssm': [ 'University of Michigan Bentley Historical Library' ]
      )
    end

    allow(generator).to receive(:fetch_components) do |_identifier| # rubocop:disable RSpec/SubjectStub
      [
        SolrDocument.new(
          'id': 'umich-test-9999-01',
          'normalized_title_ssm': [ 'Component 1.0' ],
          "component_level_isim": [ 1 ],
          'total_digital_object_count_isim': [ 1 ],
          "parent_ssim": [ 'umich-test-9999' ],
          'digital_objects_ssm': [
            {
              'label': 'Digital Object',
              'href': 'https://quod.lib.umich.edu/x/xyzzy/x-9999-01/01',
              'role': 'image-service',
              'xpointer': nil
            }.to_json
          ],
          'repository_ssm': [ 'University of Michigan Bentley Historical Library' ]
        )
      ]
    end

    allow(generator).to receive(:get) do |url| # rubocop:disable RSpec/SubjectStub
      response = double('response') # rubocop:disable RSpec/VerifiedDoubles
      output = mock_get(url)
      allow(response).to receive(:body) do
        output
      end
      response
    end
  end

  it 'generate HTML for an identifier' do
    generator.build_html
    doc = generator.doc

    expect(doc.xpath('//div[@id="summary"]//dl/dd[contains(., "Finding Aid written by E. A. Document")]').first).to be_truthy
    expect(doc.css('style#utility-styles').first).to be_truthy

    # count that the components are in the doc
    expect(doc.css('.al-contents-ish article')).not_to be_empty
  end

  it 'modify HTML for to generate PDF' do
    generator.build_html
    generator.build_pdf_html
    doc = generator.doc

    expect(doc.css('m-website-header')).to be_empty
    expect(doc.css('header').first).to be_truthy
  end

  it 'does not fail when the catalog page lacks optional html nodes' do
    allow(generator).to receive(:get) do |url| # rubocop:disable RSpec/SubjectStub
      response = double('response') # rubocop:disable RSpec/VerifiedDoubles
      output = if url.start_with?('/catalog')
        <<-HTML
        <html>
          <head>
            <title>Finding Aid</title>
            <meta name="csrf-param">
            <meta name="csrf-token">
          </head>
          <body>
            <m-website-header name="Finding Aids"></m-website-header>
            <div id="summary"><dl></dl></div>
            <div class="al-contents"></div>
            <div id="context-tree-nav"><div class="tab-pane active"></div></div>
            <div class="access-preview-snippet"></div>
          </body>
        </html>
        HTML
      else
        mock_get(url)
      end
      allow(response).to receive(:body) { output }
      response
    end

    expect { generator.build_html }.not_to raise_error
  end

  it 'orders nested components using parent_ids without parent_ids_keyed' do
    allow(generator).to receive(:fetch_components).and_call_original

    collection_doc = SolrDocument.new(
      'id': 'umich-root',
      'ead_ssi': 'umich-root'
    )
    parent_component = SolrDocument.new(
      'id': 'umich-root_parent',
      'ref_ssm': [ 'parent' ],
      'component_level_isim': [ 1 ]
    )
    child_component = SolrDocument.new(
      'id': 'umich-root_child',
      'ref_ssm': [ 'child' ],
      'component_level_isim': [ 2 ],
      'parent_ids_ssim': [ 'umich-root', 'umich-root_parent' ]
    )

    first_page = instance_double(Blacklight::Solr::Response, documents: [ collection_doc, parent_component, child_component ], total: 3)
    empty_page = instance_double(Blacklight::Solr::Response, documents: [], total: 3)
    index = instance_double(Box::Package::Index)
    allow(index).to receive(:search).and_return(first_page, empty_page)
    allow(generator).to receive(:index).and_return(index)
    generator.collection = SolrDocument.new('id': 'umich-root')

    components = generator.send(:fetch_components, 'umich-root')
    expect(components.map(&:id)).to eq [ 'umich-root_parent', 'umich-root_child' ]
  end

  it 'handles component hierarchies with no level-1 root' do
    allow(generator).to receive(:fetch_components).and_call_original

    orphan_parent = SolrDocument.new(
      'id': 'umich-root_l2',
      'component_level_isim': [ 2 ],
      'parent_ids_ssim': [ 'umich-root' ]
    )
    orphan_child = SolrDocument.new(
      'id': 'umich-root_l3',
      'component_level_isim': [ 3 ],
      'parent_ids_ssim': [ 'umich-root', 'umich-root_l2' ]
    )

    first_page = instance_double(Blacklight::Solr::Response, documents: [ orphan_parent, orphan_child ], total: 2)
    empty_page = instance_double(Blacklight::Solr::Response, documents: [], total: 2)
    index = instance_double(Box::Package::Index)
    allow(index).to receive(:search).and_return(first_page, empty_page)
    allow(generator).to receive(:index).and_return(index)
    generator.collection = SolrDocument.new('id': 'umich-root')

    components = nil
    expect { components = generator.send(:fetch_components, 'umich-root') }.not_to raise_error
    expect(components.map(&:id)).to eq [ 'umich-root_l2', 'umich-root_l3' ]
  end
end

def mock_get(url) # rubocop:disable Metrics/MethodLength
  if url.start_with?('/catalog')
    <<-HTML
    <html>
      <head>
        <title>Finding Aid</title>
        <link rel="stylesheet" href="/assets/styles.css" />
        <meta name="csrf-param">
        <meta name="csrf-token">
        <script>console.log('NOP');</script>
      </head>
      <body>
        <m-universal-header></m-universal-header>
        <m-website-header name="Finding Aids"></m-website-header>
        <aside>
          <nav class="about-collection-nav">
            <a href="/catalog/umich-9999-test#about">About</a>
            <a href="/catalog/umich-9999-test#restrictions">Restrictions</a>
          </nav>
          <div id="context-tree-nav">
            <div class="tab-panes">
              <div class="tab-pane active">
                <!-- this will be removed -->
              </div>
            </div>
          </div>
        </aside>
        <main>
          <div class="card">
            <div class="card-img">
              <!-- this will be removed -->
            </div>
            <div class="card-body">Finding Aid Repository</div>
          </div>
          <div id="navigate-collection-toggle"></div>
          <div class="access-preview-snippet">
            <!-- this will be removed -->
          </div>
          <div id="summary">
            <dl>
              <dt>Scope</dt>
              <dd>Blah blah blah</dd>
            </dl>
          </div>
          <div id="background">
          </div>
          <div class="al-contents">
            <p>This will be replaced.</p>
          </div>
        </main>
        <footer>
          <!-- ahoy, a footer -->
        </footer>
      </body>
    </html>
    HTML
  elsif url.start_with?('/assets/')
    'main { border: 1px solid #666; }'
  end
end
