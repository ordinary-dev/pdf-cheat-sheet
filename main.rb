#!/usr/bin/env ruby
# frozen_string_literal: true

require 'toml-rb'
require_relative 'options'
require_relative 'cheat_sheet'

input_file_path, output_file_path = options
exit 1 if input_file_path == '' || output_file_path == ''

input_file = TomlRB.load_file(input_file_path)

props = input_file['main']
cheat_sheet = CheatSheet.new props['column_count']
cheat_sheet.make_title props['title']

input_file['categories'].each do |category|
  cheat_sheet.print_category_name category['name']

  category['bindings'].each do |binding|
    # Not all keys are specified as an array. This line turns everything into an array.
    keys = binding['keys'].respond_to?('each') ? binding['keys'] : [binding['keys']]
    cheat_sheet.print_binding keys, binding['desc']
  end

  cheat_sheet.select_next_column
end

cheat_sheet.print_link 'github.com/ordinary-dev/pdf-cheat-sheet'
cheat_sheet.save_to_file output_file_path
