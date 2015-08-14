require 'rubygems'
require 'nokogiri'
require 'csv'
require 'json'
require 'open-uri'

output = []

pro8 = [
  'Hansa Yellow Medium',
  'Naphthol Red Light',
  'Quinacridone Magenta',
  'Phthalo Blue (Green Shade)',
  'Phthalo Green (Blue Shade)',
  'Yellow Ochre',
  'Zinc White',
  'Titanium White' ]

pro10 = [
  'Titanium White',
  'Hansa Yellow Medium',
  'Yellow Oxide',
  'Pyrrole Red',
  'Quinacridone Magenta',
  'Ultramarine Blue',
  'Phthalo Blue (Green Shade)',
  'Phthalo Green (Blue Shade)',
  'Burnt Sienna',
  'Carbon Black' ]

CSV.open("golden-fluid-acrylics.csv", "wb") do |csv|

  page = Nokogiri::HTML(open("golden-fluid-acrylics.html"))
  page.css('#swatched_main_div .color_swatch_child').each do |swatch|

    color_raw = swatch['data']
    color_name = color_raw.split(' - ')[0]
    color_no = color_raw.split(' - ')[1]
    color_hex = swatch.css('a > .color')[0]['style'].split(' ')[1]

    puts "Processed #{color_name}"

    # if pro8.include?(color_name)
      slug = color_name.downcase.strip.gsub(' ', '-').gsub(/\(|\/|,/, '-').gsub(/[^\w-]/, '')
      sub_page = Nokogiri::HTML(open("http://www.goldenpaints.com/products/colors/fluid/#{slug}"))

      csv << [color_hex, color_no, color_name]

      output << { hex: color_hex, mfg_no: color_no, name: color_name }
      tints = []
      tint_names = ['10 to 1', '3 to 1', '1 to 1', '1 to 3', '1 to 10']

      5.times do |i|
        tints[i] = sub_page.css("#tint_#{i} > .tint_circle")[0]['style'].split(' ')[1]
        if tints[i] =~ /^rgb/
          tints[i] = tints[i].gsub(/rgb\(|\)/, '').split(',').map {|c| c.to_i }.map {|j| j > 255 ? 255 : j }
          tints[i] = "##{tints[i][0].to_s(16)}#{tints[i][1].to_s(16)}#{tints[i][2].to_s(16).rjust(2, '0')}"
        end
        csv << [tints[i], color_no, "#{color_name} #{tint_names[i]}"]
        output << { hex: tints[i].upcase, mfg_no: color_no, name: "#{color_name} #{tint_names[i]}" }
      end
    # end

  end
end

puts output.to_json.gsub(/\},/, "},\n")