# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleasableIndexer do
  let(:obj) { instance_double(Dor::Abstract) }

  describe 'to_solr' do
    let(:doc) { described_class.new(resource: obj).to_solr }

    let(:released_for_info) do
      {
        'Project' => { 'release' => true },
        'test_target' => { 'release' => true },
        'test_nontarget' => { 'release' => false }
      }
    end
    let(:service) { instance_double(Dor::ReleaseTags::IdentityMetadata, released_for: released_for_info) }
    let(:released_to_field_name) { Solrizer.solr_name('released_to', :symbol) }

    before do
      allow(Dor::ReleaseTags::IdentityMetadata).to receive(:for).and_return(service)
    end

    it 'indexes release tags' do
      expect(doc).to match a_hash_including(released_to_field_name => %w[Project test_target])
    end
  end
end
