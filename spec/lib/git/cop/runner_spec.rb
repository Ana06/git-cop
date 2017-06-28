# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Cop::Runner, :temp_dir, :git_repo do
  let :defaults do
    {
      commit_body_leading_space: {enabled: true},
      commit_subject_length: {enabled: true, length: 50},
      commit_subject_prefix: {enabled: true, whitelist: %w[Fix Add Change Update Remove Refactor Enable Disable]},
      commit_subject_suffix: {enabled: true, whitelist: ["."]}
    }
  end

  let :configuration do
    Runcom::Configuration.new project_name: Git::Cop::Identity.name, defaults: defaults
  end

  let(:branch) { "test" }
  subject { described_class.new configuration: configuration.to_h }

  before do
    Dir.chdir git_repo_dir do
      `git checkout -b test`
      `printf "%s\n" "Test content." > one.txt`
      `git add --all .`
    end
  end

  describe "#run" do
    context "with valid commits" do
      it "reports no errors" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Updated one.txt." --message "- For testing purposes."`
          report = subject.run

          expect(report.empty?).to eq(true)
        end
      end
    end

    context "with invalid commits" do
      it "reports errors" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Add one.txt." --message "- For testing purposes only."`
          report = subject.run

          expect(report.total).to eq(1)
        end
      end
    end

    context "with disabled cop" do
      let(:defaults) { {commit_subject_prefix: {enabled: false, prefixes: %w[Added]}} }

      it "reports no errors" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Bogus commit message"`
          report = subject.run

          expect(report.empty?).to eq(true)
        end
      end
    end

    context "with invalid cop ID" do
      let(:defaults) { {invalid_cop_id: true} }

      it "fails with errors" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Updated one.txt." --message "- For testing purposes."`
          result = -> { subject.run }

          expect(&result).to raise_error(StandardError, /Invalid\scop\:\sinvalid_cop_id.+/)
        end
      end
    end
  end
end
