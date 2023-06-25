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

def get_solutions(identifier)
  uri = "https://www.youtube.com/watch?v=#{identifier}"
  graph = RDF::Graph.load(uri, content_type: 'text/html')
  RDF::Query.execute(graph) do
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.url, :url]
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.name, :name]
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.datePublished, :date_published]
    pattern [RDF::URI(uri), RDF::Vocab::SCHEMA.author, :author]
    pattern [:author, RDF::Vocab::SCHEMA.name, :author_name]
  end
end

def covert_to_bib(solutions)
  solutions.map do |solution|
    <<~BIB
      @video{#{solution.author_name}:#{solution.name},
        author = {#{solution.author_name}},
        title = {#{solution.name}},
        url = {#{solution.url}},
        date = {#{solution.date_published}}
      }
    BIB
  end
end
