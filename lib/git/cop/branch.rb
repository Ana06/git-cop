# frozen_string_literal: true

module Git
  module Cop
    class Branch
      REMOTE_PATH = "origin/"

      def initialize
        @path = ENV["CI"] == "true" ? REMOTE_PATH : ""
      end

      def name
        if ENV["TRAVIS"] == "true"
          pr_branch = ENV["TRAVIS_PULL_REQUEST_BRANCH"]
          return pr_branch unless pr_branch.empty?
          return ENV["TRAVIS_BRANCH"]
        end
        "#{path}#{`git rev-parse --abbrev-ref HEAD | tr -d '\n'`}"
      end

      def shas
        set_travis if ENV["TRAVIS"] == "true"
        `git log --pretty=format:"%H" #{master}..#{name}`.split("\n")
      end

      private

      attr_reader :path

      def master
        "#{path}master"
      end

      def set_travis
        pr_slug = ENV["TRAVIS_PULL_REQUEST_SLUG"]
        unless pr_slug.empty?
          # origin is set to the upstream in a PR in Travis
          `git remote add original_branch https://github.com/#{pr_slug}.git`
          `git fetch original_branch #{name}:#{name}`
        end
        # Travis doesn't know master by default
        `git remote set-branches --add origin master`
        `git fetch`
      end
    end
  end
end
