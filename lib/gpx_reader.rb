#!/usr/bin/env ruby

# Extracts streams from a GPX file.
require 'nokogiri'
require 'time'
require 'json'

class GpxReader
  class << self
    def summary(gpx_body)
      doc = Nokogiri::XML(gpx_body)
      trkpts = doc.xpath('//xmlns:trkpt')

      elevation = get_elevation(trkpts)
      lat_lng = get_lat_lng(trkpts)

      {
        name: get_name(doc),
        elevation: trim(elevation),
        lat_lng: trim(lat_lng)
      }
    end

    def lat_lng(gpx_body)
      doc = Nokogiri::XML(gpx_body)
      trkpts = doc.xpath('//xmlns:trkpt')

      results = trkpts.map do |trkpt|
        [
          trkpt.attr('lat').to_f.round(6),
          trkpt.attr('lon').to_f.round(6)
        ]
      end

      trim(results)
    end

    private

    def get_elevation(trkpts)
      trkpts.map do |trkpt|
        trkpt.children.at('ele').content.to_f
      end
    end

    def get_lat_lng(trkpts)
      trkpts.map do |trkpt|
        [
          trkpt.attr('lat').to_f.round(6),
          trkpt.attr('lon').to_f.round(6)
        ]
      end
    end

    def get_name(doc)
      doc.xpath('//xmlns:name').first.content
    end

    def trim(data, size=200)
      data_size = data.size
      return data if data_size <= size

      result = []
      (0..size-1).each do |i|
        result << data[((i.to_f / size-1) * data_size).floor]
      end

      result
    end
  end
end

if __FILE__ == $0
  infile = ARGV[0]
  puts "GPX file required!" and exit unless infile

  contents = File.read(infile)
  puts GpxReader.lat_lng(contents).to_json
end
