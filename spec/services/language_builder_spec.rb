# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LanguageBuilder do
  subject { described_class.build(languages) }

  context "when language doesn't have a code" do
    let(:languages) do
      [
        Cocina::Models::Language.new(
          "value": 'English',
          "code": 'eng'
        )
      ]
    end

    it { is_expected.to eq ['English'] }
  end
end
