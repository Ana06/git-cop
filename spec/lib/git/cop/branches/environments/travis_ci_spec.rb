# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Cop::Branches::Environments::TravisCI do
  let(:shell) { class_spy Open3 }
  subject { described_class.new shell: shell }

  describe ".ci_branch" do
    it "answers branch" do
      ClimateControl.modify TRAVIS_BRANCH: "test" do
        expect(described_class.ci_branch).to eq("test")
      end
    end
  end

  describe ".pull_request_branch" do
    it "answers branch" do
      ClimateControl.modify TRAVIS_PULL_REQUEST_BRANCH: "test" do
        expect(described_class.pull_request_branch).to eq("test")
      end
    end
  end

  describe ".pull_request_slug" do
    it "answers slug" do
      ClimateControl.modify TRAVIS_PULL_REQUEST_SLUG: "test" do
        expect(described_class.pull_request_slug).to eq("test")
      end
    end
  end

  describe "#name" do
    it "answers pull request branch name when defined" do
      allow(described_class).to receive(:pull_request_branch).and_return("pr_test")
      allow(described_class).to receive(:ci_branch).and_return("ci_test")

      expect(subject.name).to eq("pr_test")
    end

    it "answers ci branch name when pull request branch is undefined" do
      allow(described_class).to receive(:pull_request_branch).and_return("")
      allow(described_class).to receive(:ci_branch).and_return("ci_test")

      expect(subject.name).to eq("ci_test")
    end
  end

  describe "#shas" do
    let(:commits_command) { %(git log --pretty=format:"%H" origin/master..test_name) }

    before do
      allow(shell).to receive(:capture2e).with("git remote set-branches --add origin master")
      allow(shell).to receive(:capture2e).with("git fetch")
      allow(shell).to receive(:capture2e).with(commits_command).and_return(["abc\ndef", true])

      allow(subject).to receive(:name).and_return("test_name")
    end

    it "answers Git commit SHAs without pull request slug" do
      allow(described_class).to receive(:pull_request_slug).and_return("")
      expect(subject.shas).to contain_exactly("abc", "def")
    end

    it "answers Git commit SHAs with pull request slug" do
      remote_add_command = "git remote add -f original_branch https://github.com/test_slug.git"
      remote_fetch_command = "git fetch original_branch test_name:test_name"

      allow(described_class).to receive(:pull_request_slug).and_return("test_slug")
      allow(shell).to receive(:capture2e).with(remote_add_command)
      allow(shell).to receive(:capture2e).with(remote_fetch_command)

      expect(subject.shas).to contain_exactly("abc", "def")
    end
  end
end
