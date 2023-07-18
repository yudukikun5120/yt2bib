# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'date'
require 'active_support/core_ext/string'

# a class to convert a soundcloud track to a bib entry
class SoundcloudSolution
  attr_accessor :author_name, :name, :url, :date_published

  def initialize(url)
    @url = url
    @doc = Nokogiri::HTML(URI.open(url))
    parse_data
  end

  def parse_data
    self.author_name = parse_author
    self.name = parse_name
    self.date_published = parse_date
  end

  def parse_author
    title_tag = @doc.at_xpath('//title')
    title_text = title_tag.text
    title_text.split("by").last.split("|").first.strip
  end

  def parse_name
    meta = @doc.xpath('//meta[@property="og:title"]')
    meta.attribute('content').value
  end

  def parse_date
    time_tag = @doc.at_xpath('//time')
    datetime_str = time_tag.text
    datetime = DateTime.parse(datetime_str)
    datetime.strftime('%Y-%m-%d')
  end

  def citation_key
    "#{author_name}:#{name}".parameterize
  end

  def to_bib
    <<~BIB
      @music{#{citation_key},
        author = {#{author_name}},
        title = {#{name}},
        url = {#{url}},
        date = {#{date_published}},
        entrysubtype = {work}
      }
    BIB
  end
end
