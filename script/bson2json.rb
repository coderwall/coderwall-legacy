#!/usr/bin/ruby

# This script acts as a command-line filter to convert a BSON file (such as from mongodump) to an equivalent JSON file
# The resulting JSON file will be an array of hashes
# Any binary values from the BSON file are converted to base64 (such as Mongo's _id fields)
# I originally wrote this script so that Mongo files can be easily used with jsawk for
# offline data processing -- https://github.com/micha/jsawk
#
# To invoke, assuming mycollection.bson is a file from mongodump:
#   ruby bson2json.rb  < mycollection.bson > mycollection.json

require 'rubygems'
require 'bson'
require 'json'
require 'base64'

def process(file)
  puts '['

  while not file.eof? do
    bson = BSON.read_bson_document(file)
    bson = bson_debinarize(bson)
    puts bson.to_json + (file.eof? ? '' : ',')
  end

  puts ']'
end

# Accept BSON document object; return equivalent, but with any BSON::Binary values converted with Base64
def bson_debinarize(bson_doc)
  raise ArgumentError, "bson_doc must be a BSON::OrderedHash" unless bson_doc.is_a?(BSON::OrderedHash)

  # each key and value is passed by reference and is modified in-place
  bson_doc.each do |k,v|
    if v.is_a?(BSON::Binary)
      bson_doc[k] = Base64.encode64(v.to_s)
    elsif v.is_a?(BSON::OrderedHash)
      bson_doc[k] = bson_debinarize(v)
    end
  end

  bson_doc
end

process(STDIN)

__END__

Copyright (c) 2012 SPARC, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
