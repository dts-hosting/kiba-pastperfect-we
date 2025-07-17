# frozen_string_literal: true

RSpec.describe Kiba::PastperfectWe::Transforms::CrSplitter do
  subject(:xform) { described_class.new(**args) }

  describe "#process" do
    let(:input) do
      [
        {foo: "a%CR%b%CR%%CR%c%CR%d"},
        {foo: "a%CR%b%CR%c%CR%d"},
        {foo: "abcd"},
        {foo: nil},
        {foo: ""}
      ]
    end

    let(:expected_collapsed) do
      [
        {foo: "a|b|c|d"},
        {foo: "a|b|c|d"},
        {foo: "abcd"},
        {foo: nil},
        {foo: ""}
      ]
    end

    let(:result) { input.map { |row| xform.process(row) } }

    context "with fields Symbol" do
      let(:args) { {fields: :foo} }

      it "returns as expected" do
        expect(result).to eq(expected_collapsed)
      end
    end

    context "with fields Array" do
      let(:args) { {fields: [:foo]} }

      it "returns as expected" do
        expect(result).to eq(expected_collapsed)
      end
    end

    context "without collapsing and with custom delim" do
      let(:args) { {fields: :foo, delim: ";", collapse_multi_crs: false} }

      it "returns as expected" do
        expected = [
          {foo: "a;b;;c;d"},
          {foo: "a;b;c;d"},
          {foo: "abcd"},
          {foo: nil},
          {foo: ""}
        ]
        expect(result).to eq(expected)
      end
    end
  end
end
