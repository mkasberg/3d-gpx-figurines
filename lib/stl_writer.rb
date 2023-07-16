#!/usr/bin/env ruby

require 'erb'
require 'json'

class StlWriter
  class << self
    # Generates a .scad file from a .scad.erb template.
    def render_template(template_filename, scad_filename, template_data)
      scad_contents = ERB.new(File.read(template_filename)).result_with_hash(template_data)
      File.open(scad_filename, 'w') { |f| f.write(scad_contents) }
    end

    # Generates a .stl file from a .scad file.
    def render(scad_filename)
      stl_filename = scad_filename.gsub(/\.scad$/, '.stl')
      if openscad_command == 'openscad-nightly'
        `#{openscad_command} --enable=fast-csg -o #{stl_filename} #{scad_filename}`
      else
        `#{openscad_command} -o #{stl_filename} #{scad_filename}`
      end

      stl_filename
    end

    private

    def openscad_command
      return @openscad_command if @openscad_command

      @openscad_command =
        if ENV['OPENSCAD_COMMAND']
          ENV['OPENSCAD_COMMAND']
        elsif system('openscad-nightly --version')
          'openscad-nightly'
        else
          'openscad'
        end
    end
  end
end

if __FILE__ == $0
  begin
    template = ARGV[0]
    scad_file = ARGV[1]
    data_json = ARGV[2]

    throw 'error' unless template && scad_file && data_json
    data = JSON.parse(data_json, symbolize_names: true)
  rescue
    puts """Usage: stl_writer.rb template.scad.erb out.scad '{\"key\": \"value\"}'

Example: stl_writer.rb Activity.scad.erb out.scad '{\"elevation\": [1,3,4], \"distance\": [1,2,3]}'

Data should be valid JSON with the following keys:
  elevation:    array of elevation values.
  lat_lng:      array of lat_lng values.
  title:        optional. text.
"""
    exit
  end

  defaults = {
    title: 'Title'
  }

  data = defaults.merge(data)

  StlWriter.render_template(template, scad_file, data)
end
