# frozen_string_literal: true

module Git
  module Cop
    module Styles
      class CommitSubjectPrefix < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            whitelist: %w[Fixed Added Updated Removed Refactored]
          }
        end

        def valid?
          puts "HOLA ANA: " + commit.subject.to_s
          puts "HOLA ANA2: " + /\A#{Regexp.union graylist.to_regexp}/.to_s
          return true if fixup_or_squash?
          return true if graylist.empty?

          commit.subject.match?(/\A#{Regexp.union graylist.to_regexp}/)
        end

        def issue
          return {} if valid?
          {hint: %(Use: #{graylist.to_hint}.)}
        end

        protected

        def load_graylist
          Kit::Graylist.new settings.fetch(:whitelist)
        end

        private

        def fixup_or_squash?
          commit.is_a?(Git::Cop::Commits::Unsaved) && (commit.fixup? || commit.squash?)
        end
      end
    end
  end
end
