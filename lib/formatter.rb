#!/usr/bin/env ruby
require 'active_support/number_helper'

class Formatter
  class << self
    def distance(km)
      number_string = ActiveSupport::NumberHelper.number_to_delimited(km2mi(km).round(1))
      "#{number_string} mi"
    end

    def elevation(meters)
      number_string = ActiveSupport::NumberHelper.number_to_delimited(m2ft(meters).round)
      "#{number_string} ft"
    end

    def time(total_seconds)
      hours = (total_seconds / 3600).floor
      minutes = ((total_seconds % 3600) / 60).floor
      seconds = (total_seconds % 60).floor

      sprintf("%d:%02d:%02d", hours, minutes, seconds)
    end

    def left_pad(string_hash)
      length = string_hash.values.map(&:length).max

      string_hash.transform_values do |string|
        string.rjust(length)
      end
    end

    private

    def km2mi(distance)
      distance * 0.621371192
    end

    def m2ft(elevation)
      elevation * 3.28084
    end
  end
end

if __FILE__ == $0
  puts Formatter.distance(102.1)
  puts Formatter.elevation(1000)
  puts Formatter.time(3741)
end
