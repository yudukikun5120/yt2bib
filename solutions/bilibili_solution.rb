# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'json'
require 'active_support/core_ext/string'

# a class to convert a Bilibili video to a bib entry
class BilibiliSolution
  attr_accessor :author_name, :name, :url, :date_published

  def initialize(url)
    @url = url
    @doc = Nokogiri::HTML(URI.open(url))
    parse_data
  end

  def parse_author
    nickname = @doc.at('a[class="bstar-meta-up-follow__nickName"]')
    nickname.text.strip
  end

  def parse_data
    json_ld = @doc.at('script[type="application/ld+json"]')
    json_data = JSON.parse(json_ld.text) if json_ld

    self.author_name = parse_author

    name = json_data.find { |item| item["@type"] == "VideoObject" }["name"] if json_data
    self.name = remove_postfix_from name if name
    
    self.date_published = json_data.find { |item| item["@type"] == "VideoObject" }["uploadDate"] if json_data
  end

  def citation_key
    "#{author_name}:#{name}".parameterize
  end

  def to_bib
    <<~BIB
      @video{#{citation_key},
        author = {#{author_name}},
        title = {#{name}},
        url = {#{url}},
        date = {#{DateTime.parse(date_published).strftime('%Y-%m-%d')}},
        entrysubtype = {work}
      }
    BIB
  end

  private

  def remove_postfix_from(name)
    name.split(" - ").first
  end
end
