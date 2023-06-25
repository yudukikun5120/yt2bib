# frozen_string_literal: true

require 'test/unit'
require_relative 'core'

# Test core.rb
class TestCore < Test::Unit::TestCase
  def test_normalize_identifier
    assert_equal('9bZkp7q19f0', normalize_identifier('https://www.youtube.com/watch?v=9bZkp7q19f0'))
    assert_equal('9bZkp7q19f0', normalize_identifier('https://youtu.be/9bZkp7q19f0'))
  end

  def test_convert_to_bib
    metadata = [
      {
        name: 'Gangnam Style',
        url: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
        author_name: 'Psy',
        date_published: '2012-07-15'
      }
    ]
    expected = [
      <<~BIB
        @video{Psy:Gangnam Style,
          author = {Psy},
          title = {Gangnam Style},
          url = {https://www.youtube.com/watch?v=9bZkp7q19f0},
          date = {2012-07-15}
        }
      BIB
    ]
    assert_equal(expected, covert_to_bib(metadata))
  end

  def test_url_to_bib
    uri = 'https://www.youtube.com/watch?v=9bZkp7q19f0'
    identifier = normalize_identifier uri
    metadata = get_metadata(identifier)

    assert_equal(
      [
        <<~BIB
          @video{officialpsy:PSY - GANGNAM STYLE(강남스타일) M/V,
            author = {officialpsy},
            title = {PSY - GANGNAM STYLE(강남스타일) M/V},
            url = {https://www.youtube.com/watch?v=9bZkp7q19f0},
            date = {2012-07-15}
          }
        BIB
      ],
      covert_to_bib(metadata)
    )
  end
end
