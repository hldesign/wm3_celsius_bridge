# frozen_string_literal: true
require 'ostruct'

module Wm3CelsiusBridge
  class EventReporter
    def initialize(title:, indent: 1)
      @title = title
      @indent = indent
      @events = []
      @sub_reports = []
      @start_message = ''
      @finish_message = ''
    end

    def sub_report(title:, subtitle: '')
      EventReporter.new(title: title, indent: indent + 1).tap { |r| sub_reports << r }
    end

    def start(message:)
      @start_message = message
      self
    end

    def finish(message:)
      @finish_message = message
      self
    end

    def info(message: '', model: nil, info: nil)
      log(message: 'INFO: ' + message, model: model, info: info)
    end

    def warning(message: '', model: nil, info: nil)
      log(message: 'WARNING: ' + message, model: model, info: info)
    end

    def error(message: '', model: nil, info: nil)
      log(message: 'ERROR: ' + message, model: model, info: info)
    end

    def log(message: '', model: nil, info: nil)
      @events << OpenStruct.new(message: message, model: model, info: info)
      self
    end

    def to_s
      title_line +
      start_line +
      event_lines +
      sub_report_lines +
      finish_line
    end

    private

    attr_reader :title, :indent, :events, :sub_reports, :start_message, :finish_message

    def title_line
      case indent
        when 1
          prefix(char: '=', end_char: '=') + title + " =====\n\n"
        when 2
          prefix(char: '=', end_char: '>') + title + "\n\n"
        else
          prefix(char: '-', end_char: '>') + title + "\n\n"
        end
    end

    def start_line
      start_message.empty? ? '' : (prefix + start_message + "\n\n")
    end

    def finish_line
      finish_message.empty? ? '' : (prefix + finish_message + "\n\n")
    end

    def event_lines
      events.map do |event|
        model_data = event.model.respond_to?(:to_hash) ? "#<#{event.model.class.name} #{event.model.to_hash}>" : event.model.inspect
        str = prefix + event.message + "\n"
        str << prefix + "  Info: #{event.info.inspect}\n" unless event.info.nil?
        str << prefix + "  Model: #{model_data}\n" unless event.model.nil?
        str << "\n"
        str
      end.join
    end

    def sub_report_lines
      sub_reports.map(&:to_s).join
    end

    def prefix(char: ' ', end_char: ' ')
      char * indent * 2 + end_char + ' '
    end
  end
end
