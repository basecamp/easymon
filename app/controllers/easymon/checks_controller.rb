require_dependency "easymon/application_controller"

module Easymon
  class ChecksController < ApplicationController
    rescue_from Easymon::NoSuchCheck do |e|
      respond_to do |format|
         format.any(:text, :html) { render :text => e.message, :status => :not_found }
         format.json { render :json => e.message, :status => :not_found }
      end
    end
    
    def index
      checklist = Easymon::Repository.all
      checklist.check
      
      message = "No Checks Defined"
      
      response_status = checklist.response_status
      message = checklist.to_s unless checklist.empty?
      
      # override response_status if we have a "critical" checklist
      if checklist.include?("critical")
        response_status = checklist.fetch("critical").response_status
      end

      respond_to do |format|
         format.any(:text, :html) { render :text => message, :status => response_status }
         format.json { render :json => checklist, :status => response_status }
      end
    end

    def show
      check = Easymon::Repository.fetch(params[:check])
      result = Easymon::Result.new(check.check)
      
      message = "#{params[:check]}: #{result.message}"
      
      respond_to do |format|
         format.any(:text, :html) { render :text => result.message, :status => result.response_status }
         format.json { render :json => message, :status => result.response_status }
      end
    end
  end
end
