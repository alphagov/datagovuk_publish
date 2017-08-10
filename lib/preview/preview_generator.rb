require 'csv'
require 'open-uri'
require 'tempfile'

class PreviewGenerator
  def initialize(link)
    @link = link
  end

  def generate
    payload = {}
    payload[:type] = @link.format
    payload[:size] = @link.size

    if @link.format == "CSV"
      payload[:body] = CSVPreviewGenerator.create @link
    end

    preview = Preview.find_or_initialize_by(datafiles_id: @link.id)
    preview.content = payload
    preview.save!
  end
end


class CSVPreviewGenerator
  def self.create(link)
    puts "\n#{link.url}"

    begin
      csv_text = open(link.url)
    rescue StandardError => e
      puts e.message
      return []
    end

    file = CSVPreviewGenerator.write_temp_file(csv_text)
    content = get_magic_encoding(file.path)
    file.unlink

    CSVPreviewGenerator.get_rows(content, link.url)
  end


  def self.get_rows(content, from_url)
    rows = []
    count = 0

    begin
      c = CSV.new(content, headers: true)
      c.each do |row|
        count += 1
        rows << row.to_hash.values
        break if count == 6
      end
    rescue StandardError => e
      puts e.message
      puts "\n#{from_url} is not a CSV so empty preview generated"
    end

    rows
  end

  def self.write_temp_file(data)
    file = Tempfile.new(["preview", ".csv"])
    file.binmode
    begin
      data.each do |s|
        file.write(s)
      end
    ensure
      file.close
    end
    file
  end
end


def get_magic_encoding(filename)
  encoding = `file -b --mime-encoding #{filename}`.strip
  return "" if encoding == "binary"

  if ["UTF-8", "US-ASCII", "ASCII-8BIT"].include? encoding.upcase
    File.read(filename)
  else
    convert(encoding, "utf-8", filename)
  end
end


def convert(source, target, data)
  begin
    Iconv.conv(target, source, IO.binread(data))
  rescue
    ""
  end
end
