module Easymon
  class ApplicationController < ActionController::Base
    rescue_from Easymon::Repository::NoSuchCheck do |e|
      respond_to do |format|
         format.any(:text, :html) { render text: e.message, status: :not_found }
         format.json { render json: e.message, status: :not_found }
      end
    end
  end
end
