# frozen_string_literal: true

require 'prawn'

# PDF file generator.
# The generator relies heavily on hand-picked values.
# Changing anything can be dangerous.
class CheatSheet
  def initialize(column_count)
    @pdf = Prawn::Document.new(page_size: 'A4', page_layout: :landscape, margin: 20)

    # Font files
    @regular_font = 'fonts/Roboto-Regular.ttf'
    @bold_font = 'fonts/Roboto-Bold.ttf'
    @extra_bold_font = 'fonts/Roboto-Black.ttf'
    @mono_font = 'fonts/JetBrainsMono-Regular.ttf'

    # Font settings
    @regular_font_size = 8
    @title_font_size = 12
    @line_height = 10
    @char_width = 5

    # Some constants and calculations
    @column_count = column_count
    @column_margin = 16
    @column_width = (@pdf.bounds.right - @pdf.bounds.left) / column_count - @column_margin * (column_count - 1)

    # Key rendering settings
    @key_padding = 2
    @key_bg_color = 'e6e6e6'
    @key_margin = 2
    @key_border_radius = 2

    # Current vertical position for each column
    @y = [@pdf.bounds.top - 12] * column_count

    @column = 0
  end

  # Don't call more than once
  def make_title(text)
    @pdf.font @extra_bold_font, size: @title_font_size
    @pdf.text text
  end

  # Select the most empty column for a category.
  # Call before printing a new category.
  def select_next_column()
    _, @column = @y.each_with_index.max
  end

  def print_category_name(text) 
    @y[@column] -= @column_margin
    x = @column * (@column_width + @column_margin)

    @pdf.font @bold_font, size: @regular_font_size

    @pdf.bounding_box([x, @y[@column]], width: @column_width) do
      top = @pdf.bounds.top
      @pdf.text text
      @y[@column] -= @pdf.bounds.top - top + 4
    end
  end

  def print_binding(keys, description)
    x = @column * (@column_width + @column_margin)

    keys.each do |key|
      x += _draw_key x, @y[@column], key
    end

    @y[@column] -= 1.5
    x += _print_dash x, @y[@column]

    @y[@column] -= _print_description x, @y[@column], description
  end

  def _draw_key(x, y, key)
    key_width = key.length * @char_width
    @pdf.fill_color @key_bg_color

    @pdf.bounding_box [x, y], width: key_width + @key_padding * 2 do
      @pdf.rounded_rectangle [0, 0], key_width + @key_padding * 2, @line_height, @key_border_radius
      @pdf.fill
    end

    @pdf.fill_color '000000'
    x += @key_padding

    @pdf.font @mono_font, size: @regular_font_size
    @pdf.bounding_box [x, y], width: key_width do
      @pdf.text key
    end

    # return the value by which x should be increased
    key_width + @key_padding * 2 + @key_margin
  end

  # Print a separator between keys and description
  def _print_dash(x, y)
    width = 3
    x += width

    @pdf.font @regular_font, size: @regular_font_size
    @pdf.bounding_box [x, y], width: width do
      @pdf.text ' - ', { leading: 4 }
    end

    # return the value by which x should be increased
    width * 3
  end

  def _print_description(x, y, text)
    # Calculate space available for text
    used_width = x - @column * (@column_width + @column_margin)
    available_width = @column_width - used_width

    diff = 0

    @pdf.bounding_box [x, y], width: available_width do
      top = @pdf.bounds.top
      @pdf.text text, { leading: 4 }

      # return the value by which y should be decreased
      diff = @pdf.bounds.top - top
    end

    # Return the value by which @y[@column] should be decreased
    diff
  end

  # Type text at the bottom right. Call only once.
  def print_link(text)
    link_width = 160
    @pdf.font @regular_font, size: @regular_font_size
    @pdf.bounding_box [@pdf.bounds.right - link_width, 15], width: link_width do
      @pdf.text text
    end
  end

  def save_to_file(path)
    @pdf.render_file path
  end
end
