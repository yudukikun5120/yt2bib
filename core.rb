# frozen_string_literal: true

require 'rdf/microdata'
require 'rdf/vocab'

def normalize_identifier(raw_identifier)
  # https://www.youtube.com/watch?v=<id> or <id> should be <id>.
  if raw_identifier.include? 'youtube.com'
    raw_identifier.split('v=')[1]
  elsif raw_identifier.include? 'youtu.be'
    raw_identifier.split('/')[3]
  end
end

def valid_uri?(uri)
  uri = URI.parse(uri)
  uri.is_a?(URI::HTTP) && !uri.host.nil?
rescue URI::InvalidURIError
  false
end

def solutions_to_metadata(solutions)
  solutions.map do |solution|
    {
      name: solution.name.to_s,
      url: solution.url.to_s,
      author_name: solution.author_name.to_s,
      date_published: solution.date_published.to_s
    }
  end
end

def get_metadata(identifier)
  uri = "https://www.youtube.com/watch?v=#{identifier}"
  graph = RDF::Graph.load(uri, content_type: 'text/html')
  solutions = RDF::Query.execute(graph) do
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.url, :url]
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.name, :name]
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.datePublished, :date_published]
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.author, :author]
    pattern [:author, RDF::Vocab::SCHEMA.name, :author_name]
  end

  solutions_to_metadata solutions
end

def covert_to_bib(metadata)
  metadata.each do |data|
    entry = <<~BIB
      @video{#{data[:author_name]}:#{data[:name]},
        author = {#{data[:author_name]}},
        title = {#{data[:name]}},
        url = {#{data[:url]}},
        date = {#{data[:date_published]}}
      }
    BIB
    puts entry
  end
end
