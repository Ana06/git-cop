# frozen_string_literal: true

require "open3"

module Git
  module Cop
    module Branches
      module Environments
        # Provides feature branch information for Travis CI build environment.
        class TravisCI
          def self.ci_branch
            ENV["TRAVIS_BRANCH"]
          end

          def self.pull_request_branch
            ENV["TRAVIS_PULL_REQUEST_BRANCH"]
          end

          def self.pull_request_slug
            ENV["TRAVIS_PULL_REQUEST_SLUG"]
          end

          def initialize shell: Open3
            @shell = shell
          end

          def name
            klass = self.class
            pull_request_branch = klass.pull_request_branch

            pull_request_branch.empty? ? klass.ci_branch : pull_request_branch
          end

          def shas
            prepare_project

            result, _status = shell.capture2e %(git log --pretty=format:"%H" origin/master..#{name})
            result.split("\n")
          end

          private

          attr_reader :shell

          def prepare_project
            slug = self.class.pull_request_slug

            unless slug.empty?
              shell.capture2e "git remote add -f original_branch https://github.com/#{slug}.git"
              shell.capture2e "git fetch original_branch #{name}:#{name}"
            end

            shell.capture2e "git remote set-branches --add origin master"
            shell.capture2e "git fetch"
          end
        end
      end
    end
  end
end
