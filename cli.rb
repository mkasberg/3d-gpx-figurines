#!/usr/bin/env ruby

require 'thor'
require 'json'

require_relative 'lib/gpx_reader'
require_relative 'lib/stl_writer'

class FigurineCLI < Thor
  desc 'generate FILE', 'Generate .scad and .stl files from a GPX FILE'
  option :title, desc: 'Title to display on the model, omit to use GPX name'
  option :out_back, desc: 'Advanced. Percentage of the route to render on the map'
  option :map_rotation, desc: 'Advanced. Anticlockwise rotation of the map in degrees'
  def generate(file)
    gpx_contents = File.read(file)
    summary = GpxReader.summary(gpx_contents)

    title = if options[:title].nil? then summary[:name] else options[:title] end
    out_back = if options[:out_back].nil? then '100' else options[:out_back].to_i.to_s end
    map_rotation = if options[:map_rotation].nil? then '0' else options[:map_rotation] end


    template_data = {
      elevation: summary[:elevation].to_json,
      lat_lng: summary[:lat_lng].to_json,
      title: title,
      out_back: out_back,
      map_rotation: map_rotation
    }

    base_name = File.basename(file, '.gpx')
    scad_filename = "#{base_name}.scad"

    puts "Rendering SCAD Template..."
    StlWriter.render_template(
      '3D_Course_Miniature.scad.erb',
      scad_filename,
      template_data
    )

    puts "Rendering STL. This might take several minutes..."
    StlWriter.render(scad_filename)
  end
end

FigurineCLI.start(ARGV)
