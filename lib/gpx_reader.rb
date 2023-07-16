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
      distance = get_distance(trkpts)
      elapsed_time = get_elapsed_time(trkpts)
      lat_lng = get_lat_lng(trkpts)

      {
        name: get_name(doc),
        elevation: trim(elevation),
        distance: trim(distance),
        lat_lng: trim(lat_lng),
        elapsed_time: elapsed_time,
        elevation_gain: find_gain(elevation),
        total_distance: distance.last
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

    def find_gain(elevation)
      gain = 0
      (1...elevation.size).each do |i|
        gain += elevation[i] - elevation[i - 1] if elevation[i] > elevation[i - 1]
      end

      gain
    end

    def get_distance(trkpts)
      lat_lng = get_lat_lng(trkpts)

      distance = [0]
      (1...lat_lng.size).each do |i|
        distance << distance[i - 1] + haversine_distance(lat_lng[i - 1], lat_lng[i])
      end

      distance
    end

    def get_lat_lng(trkpts)
      trkpts.map do |trkpt|
        [
          trkpt.attr('lat').to_f.round(6),
          trkpt.attr('lon').to_f.round(6)
        ]
      end
    end

    def get_elapsed_time(trkpts)
      t0 = Time.parse(trkpts.first.children.at('time').content)
      t1 = Time.parse(trkpts.last.children.at('time').content)
      (t1 - t0).to_i
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

    def haversine_distance(a, b)
      # Radius of the Earth in kilometers
      earth_radius = 6371

      # Convert degrees to radians
      lat1_rad = deg2rad(a[0])
      lon1_rad = deg2rad(a[1])
      lat2_rad = deg2rad(b[0])
      lon2_rad = deg2rad(b[1])

      # Haversine formula
      dlat = lat2_rad - lat1_rad
      dlon = lon2_rad - lon1_rad
      a = Math.sin(dlat/2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon/2) ** 2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      earth_radius * c
    end

    def deg2rad(degrees)
      degrees * Math::PI / 180
    end
  end
end

if __FILE__ == $0
  infile = ARGV[0]
  puts "GPX file required!" and exit unless infile

  contents = File.read(infile)
  puts GpxReader.lat_lng(contents).to_json
end
