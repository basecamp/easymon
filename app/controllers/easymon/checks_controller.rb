require_dependency "easymon/application_controller"

module Easymon
  class ChecksController < ApplicationController
    def index
      checks = Easymon::Repository.all
      checks.run

      respond_to do |format|
         format.any(:text, :html) { render text: checks, status: set_status(checks) }
         format.json { render json: checks, status: set_status(checks) }
      end
    end

    def show
      check = Easymon::Repository.fetch(params[:check])
      check.run
      
      respond_to do |format|
         format.any(:text, :html) { render text: check, status: check.success? ? :ok : 503 }
         format.json { render json: check, status: check.success? ? :ok : 503 }
      end
    end
    private
      def set_status(checks)
        return :ok if checks.success?
        return :ok if checks.has_critical? && checks.critical_success?
        503
      end
  end
end
