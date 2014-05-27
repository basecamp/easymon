require_dependency "easymon/application_controller"
require "benchmark"

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
      
      unless checklist.empty?
        # override response_status if we have a "critical" checklist
        if checklist.include?("critical")
          critical_checklist = checklist.fetch("critical")
          response_status = critical_checklist.response_status
          message = add_prefix(critical_checklist.success?, message)
        else
          message = add_prefix(checklist.success?, message)
        end
      end

      respond_to do |format|
         format.any(:text, :html) { render :text => message, :status => response_status }
         format.json { render :json => checklist, :status => response_status }
      end
    end

    def show
      check = Easymon::Repository.fetch(params[:check])
      check_result = []
      timing = Benchmark.realtime { check_result = check.check }
      result = Easymon::Result.new(check_result, timing)
      
      respond_to do |format|
         format.any(:text, :html) { render :text => result, :status => result.response_status }
         format.json { render :json => result, :status => result.response_status }
      end
    end

    private
      def add_prefix(result, message)
        result ? "OK #{message}" : "DOWN #{message}"
      end
  end
end
