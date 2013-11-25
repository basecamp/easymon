require_dependency "easymon/application_controller"

module Easymon
  class ChecksController < ApplicationController
    rescue_from Easymon::Repository::NoSuchCheck do |e|
      respond_to do |format|
         format.any(:text, :html) { render text: e.message, status: :not_found }
         format.json { render json: e.message, status: :not_found }
      end
    end
    
    def index
      checks = Easymon::Repository.all
      checks.run

      respond_to do |format|
         format.any(:text, :html) { render text: checks, status: checks.response_status }
         format.json { render json: checks, status: checks.response_status }
      end
    end

    def show
      check = Easymon::Repository.fetch(params[:check])
      check.run
      
      respond_to do |format|
         format.any(:text, :html) { render text: check, status: check.response_status }
         format.json { render json: check, status: check.response_status }
      end
    end
  end
end
