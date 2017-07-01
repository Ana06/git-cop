# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Cop::Styles::CommitBodyPresent do
  let(:body) { "This is an example of a commit message body." }
  let(:commit) { object_double Git::Cop::Commit.new(sha: "1"), body: body }
  let(:settings) { {enabled: true} }
  subject { described_class.new commit: commit, settings: settings }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_present)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Present")
    end
  end

  describe "#valid?" do
    context "when valid" do
      it "answers true" do
        expect(subject.valid?).to eq(true)
      end
    end

    context "when invalid (empty)" do
      let(:body) { "" }

      it "answers false" do
        expect(subject.valid?).to eq(false)
      end
    end

    context "when invalid (whitespace & carriage returns)" do
      let(:body) { " \r  \n \n\t" }

      it "answers false" do
        expect(subject.valid?).to eq(false)
      end
    end
  end

  describe "#error" do
    context "when valid" do
      it "answers empty string" do
        expect(subject.error).to eq("")
      end
    end

    context "when invalid (whitespace & carriage returns)" do
      let(:body) { " \r  \n \n\t" }

      it "answers error message" do
        expect(subject.error).to eq("Empty commit body.")
      end
    end
  end
end
