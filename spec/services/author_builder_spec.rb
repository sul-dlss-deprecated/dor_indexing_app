# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorBuilder do
  subject { described_class.build(contributors) }

  context 'with an creator' do
    let(:contributors) do
      [
        Cocina::Models::Contributor.new(
          "name": [{
            "structuredValue": [{
              "value": 'George, Henry',
              "type": 'name'
            },
                                {
                                  "value": '1839-1897',
                                  "type": 'life dates'
                                }]
          }],
          "type": 'person',
          "role": [{
            "value": 'creator',
            "source": {
              "code": 'marcrelator'
            }
          }]
        ),
        Cocina::Models::Contributor.new(
          "name": [{
            "structuredValue": [{
              "value": 'George, Henry',
              "type": 'name'
            },
                                {
                                  "value": '1862-1916',
                                  "type": 'life dates'
                                }]
          }],
          "type": 'person'
        )
      ]
    end

    it { is_expected.to eq ['George, Henry (1839-1897)', 'George, Henry (1862-1916)'] }
  end

  context 'with an author (example from Hydrus)' do
    let(:contributors) do
      [
        Cocina::Models::Contributor.new(
          "name": [{ "value": 'Stanford, Jane Lathrop' }],
          "type": 'person',
          "role": [{
            "value": 'Author',
            "source": {
              "code": 'marcrelator'
            }
          }]
        )
      ]
    end

    it { is_expected.to eq ['Stanford, Jane Lathrop'] }
  end

  context 'with non-author contributors' do
    let(:contributors) do
      [
        Cocina::Models::Contributor.new(
          "name": [
            {
              "structuredValue": [
                {
                  "value": 'Hilton',
                  "type": 'surname'
                },
                {
                  "value": 'W.',
                  "type": 'forename'
                },
                {
                  "value": '1786-1839',
                  "type": 'life dates'
                }
              ]
            },
            {
              "value": 'Hilton, W., 1786-1839',
              "type": 'display'
            }
          ],
          "type": 'person',
          "role": [
            {
              "value": 'Artist',
              "code": 'art',
              "uri": 'http://id.loc.gov/vocabulary/relators/art',
              "source": {
                "code": 'marcrelator',
                "uri": 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ]
        ),
        Cocina::Models::Contributor.new(
          "name": [
            {
              "structuredValue": [
                {
                  "value": 'Scriven',
                  "type": 'surname'
                },
                {
                  "value": 'Edward',
                  "type": 'forename'
                },
                {
                  "value": '1775-1841',
                  "type": 'life dates'
                }
              ]
            },
            {
              "value": 'Scriven, Edward, 1775-1841',
              "type": 'display'
            }
          ],
          "type": 'person',
          "role": [
            {
              "value": 'Engraver',
              "code": 'egr',
              "uri": 'http://id.loc.gov/vocabulary/relators/egr',
              "source": {
                "code": 'marcrelator',
                "uri": 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ]
        )
      ]
    end

    it { is_expected.to be_empty }
  end
end
