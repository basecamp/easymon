require_dependency "easymon/application_controller"
require "benchmark"

module Easymon
  class ChecksController < ApplicationController
    # Rails 5+ deprecates `before_filter` in favor of `before_action`. Alias
    # the latter for forward compatibility.
    unless defined?(before_action)
      class << self
        %w( before ).each do |callback|
          alias_method :"#{callback}_action", :"#{callback}_filter"
        end
      end
    end

    before_action :authorize_request

    def index

    end
  end
end
