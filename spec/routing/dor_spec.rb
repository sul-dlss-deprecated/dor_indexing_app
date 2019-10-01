# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dor routing', type: :routing do
  describe 'reindexing' do
    it 'routes appropriately' do
      expect(get: '/dor/reindex/druid:abc123').to route_to(
        controller: 'dor',
        action: 'reindex',
        pid: 'druid:abc123'
      )
      expect(post: '/dor/reindex/druid:abc123').to route_to(
        controller: 'dor',
        action: 'reindex',
        pid: 'druid:abc123'
      )
      expect(put: '/dor/reindex/druid:abc123').to route_to(
        controller: 'dor',
        action: 'reindex',
        pid: 'druid:abc123'
      )
    end
  end
end
