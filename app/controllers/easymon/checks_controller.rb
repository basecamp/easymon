require_dependency "easymon/application_controller"
require "benchmark"

module Easymon
  class ChecksController < ApplicationController
    before_filter :authorized
    rescue_from Easymon::NoSuchCheck do |e|
      respond_to do |format|
        format.any(:text, :html) { render_result e.message, :not_found }
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
        unless Easymon::Repository.critical.empty?
          critical_checks = checklist.items.map{|name, entry| checklist.results[name] if Easymon::Repository.critical.include?(name)}.compact
          critical_success = critical_checks.all?(&:success?)
          response_status = critical_success ? :ok : :service_unavailable
          message = add_prefix(critical_success, message)
        else
          message = add_prefix(checklist.success?, message)
        end
      end

      respond_to do |format|
         format.any(:text, :html) { render_result message, response_status }
         format.json { render :json => checklist, :status => response_status }
      end
    end

    def show
      check_result = []
      is_critical = params[:check] == "critical"

      if is_critical
        # Build the critical checklist
        checklist_proto = {}
        Easymon::Repository.critical.each do |name|
          checklist_proto[name] = Easymon::Repository.fetch(name)
        end
        checklist = Easymon::Checklist.new checklist_proto
        checklist.check
      else
        check = Easymon::Repository.fetch(params[:check])
        timing = Benchmark.realtime { check_result = check[:check].check }
        result = Easymon::Result.new(check_result, timing, check[:critical])
      end

      respond_to do |format|
        format.any(:text, :html) do
          if is_critical
            render_result add_prefix(checklist.success?, checklist), checklist.response_status
          else
            render_result result, result.response_status
          end
        end
        format.json do
          if is_critical
            render :json => checklist, :status => checklist.response_status
          else
            render :json => result, :status => result.response_status
          end
        end
      end
    end

    private
      def render_result(message, status)
        symbol_for_plain = Easymon.has_render_plain? ? :plain : :text
        render symbol_for_plain => message, :status => status
      end

      def add_prefix(result, message)
        result ? "OK #{message}" : "DOWN #{message}"
      end

      def authorized
        head :not_found unless Easymon.authorized?(request)
      end
  end
end
