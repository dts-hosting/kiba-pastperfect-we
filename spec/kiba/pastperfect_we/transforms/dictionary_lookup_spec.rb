# frozen_string_literal: true

RSpec.describe Kiba::PastperfectWe::Transforms::DictionaryLookup do
  subject(:xform) { described_class.new(**params) }

  let(:base_params) { {fields: fields, lookup: hash} }
  let(:params) { base_params }
  let(:fields) { %i[stringid blahid] }
  let(:hash) do
    {
      "1" => [{title: "Aaa", description: "Bbb"}],
      "2" => [{title: "Ccc", description: "Ddd"}]
    }
  end
  let(:input) do
    [
      {stringid: "1", blahid: "2"},
      {stringid: "3", blahid: "4"},
      {stringid: "", blahid: nil}
    ]
  end
  let(:result) { input.map { |row| xform.process(row) } }

  let(:no_merge_desc) do
    [
      {string: "Aaa", blah: "Ccc"},
      {string: nil, blah: nil},
      {string: nil, blah: nil}
    ]
  end

  let(:with_merge_desc) do
    [
      {string: "Aaa", string_desc: "Bbb", blah: "Ccc", blah_desc: "Ddd"},
      {string: nil, string_desc: nil, blah: nil, blah_desc: nil},
      {string: nil, string_desc: nil, blah: nil, blah_desc: nil}
    ]
  end

  it "transforms as expected" do
    expect(result).to eq(no_merge_desc)
  end

  context "with merge_desc explicitly set true on xform" do
    let(:params) { base_params.merge({merge_desc: true}) }

    it "transforms as expected" do
      expect(result).to eq(with_merge_desc)
    end
  end

  context "when project merge_desc set to true" do
    before { Ppwe.config.merge_dictionary_item_descriptions = true }
    after { Ppwe.config.merge_dictionary_item_descriptions = false }

    it "transforms as expected" do
      expect(result).to eq(with_merge_desc)
    end

    context "with merge_desc explicitly set false on xform" do
      let(:params) { base_params.merge({merge_desc: false}) }

      it "transforms as expected" do
        expect(result).to eq(no_merge_desc)
      end
    end
  end
end
