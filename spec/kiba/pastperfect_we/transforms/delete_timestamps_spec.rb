# frozen_string_literal: true

RSpec.describe Kiba::PastperfectWe::Transforms::DeleteTimestamps do
  subject(:xform) { described_class.new(fields: fields) }

  let(:input) do
    [
      {removedate: "12/30/1899 12:00:00 AM", misc: "2024-05-30 17:24:28.173",
       opendate: "2024-07-31 04:00:00.000"},
      {removedate: "12/30/1899 12:00:00", misc: "random",
       opendate: nil}
    ]
  end
  let(:result) { input.map { |row| xform.process(row) } }

  context "with no fields passed" do
    let(:fields) { nil }

    it "removes timestamps when fieldname ends with date" do
      expect(result).to eq([
        {removedate: "12/30/1899", misc: "2024-05-30 17:24:28.173",
         opendate: "2024-07-31"},
        {removedate: "12/30/1899", misc: "random",
         opendate: nil}
      ])
    end
  end

  context "with fields passed" do
    let(:fields) { :misc }

    it "removes timestamps from given field(s)" do
      [
        {removedate: "12/30/1899 12:00:00 AM", misc: "2024-05-30",
         opendate: "2024-07-31 04:00:00.000"},
        {removedate: "12/30/1899 12:00:00", misc: "random",
         opendate: nil}
      ]
    end
  end
end
