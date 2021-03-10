# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TitleBuilder do
  subject { described_class.build(titles) }

  let(:titles) do
    [
      Cocina::Models::Title.new(
        structuredValue: [
          {
            structuredValue: [
              {
                "value": 'ti1:nonSort',
                "type": 'nonsorting characters'
              },
              {
                "value": 'brisk junket',
                "type": 'main title'
              },
              {
                "value": 'ti1:subTitle',
                "type": 'subtitle'
              },
              {
                "value": 'ti1:partNumber',
                "type": 'part number'
              },
              {
                "value": 'ti1:partName',
                "type": 'part name'
              }
            ]
          }
        ]
      )
    ]
  end

  it { is_expected.to eq 'ti1:nonSort brisk junket : ti1:subTitle. ti1:partNumber, ti1:partName' }
end
