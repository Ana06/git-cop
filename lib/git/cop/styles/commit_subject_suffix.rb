# frozen_string_literal: true

module Git
  module Cop
    module Styles
      class CommitSubjectSuffix < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            whitelist: ["\\."]
          }
        end

        def valid?
          return true if graylist.empty?
          commit.subject.match?(/#{Regexp.union graylist.to_regexp}\Z/)
        end

        def issue
          return {} if valid?
          {hint: %(Use: #{graylist.to_hint}.)}
        end

        protected

        def load_graylist
          Kit::Graylist.new settings.fetch(:whitelist)
        end
      end
    end
  end
end
