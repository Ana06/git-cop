# frozen_string_literal: true

module Git
  module Cop
    module Styles
      class CommitBodyPresent < Abstract
        def self.defaults
          {
            enabled: false
          }
        end

        def valid?
          !commit.body.gsub(/\s/, "").empty?
        end

        def error
          return "" if valid?

          "Empty commit body."
        end
      end
    end
  end
end
