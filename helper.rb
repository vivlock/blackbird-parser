require 'json'

=begin
match open and close brackets
returns Hash:
  json_str:     substring of block_str from the first '{' to the closing '}' of a valid block
  json:         json_str parsed as json, or nil if invalid json
  trailing_str: remaining (stripped) string in block_str after json
=end
def extract_json(block_str)
  open_brackets = 0
  index = 0
  start = -1
  results = Hash.new

  begin
    next_bracket = block_str.match(/[{}]/, index)
    if next_bracket[0] == "{"
      open_brackets += 1
      start = next_bracket.begin(0) if start < 0
    elsif next_bracket[0] == "}"
      open_brackets -= 1
    end
    index = next_bracket.end(0)
  end until open_brackets == 0

  results[:json_str] = block_str[start..(index - 1)].strip
  results[:trailing_str] = block_str[index..-1].strip
  results[:json] = parse_valid_json(results[:json_str])

  return results
end

# returns parsed json or nil if invalid
def parse_valid_json(json)
  begin
    return JSON.parse(json)
  rescue TypeError, JSON::ParserError
    return nil
  end
end

# puts each element of array
def output_array(arr)
  for item in arr
    puts item.to_s
  end
end
