# frozen_string_literal: true

require 'optparse'

# Command line parameter handler.
# Requires the path to the input and output file.
def options
  input_file_path = ''
  output_file_path = ''

  parser = OptionParser.new

  parser.on('-t', '--template [path]', String, 'The path to the file with keyboard shortcuts') do |path|
    input_file_path = path
  end

  parser.on('-o', '--output [path]', String, 'Path to the new PDF file') do |path|
    output_file_path = path
  end

  parser.parse!

  puts parser.help if input_file_path == '' || output_file_path == ''

  [input_file_path, output_file_path]
end
