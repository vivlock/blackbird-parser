require_relative 'helper'

class Block
  def initialize(blockStr)
    @blockStr = blockStr
  end

  def output
    puts @blockStr
  end
end

# Request Block Structure (formatted for clarity, do -NOT- consider whitespace when parsing)
=begin
[Request Name:] <-- we lose this in our parent split
<Optionally request name string first, often blank>
Program Name: MP_GET_CODESET       <-- make program name prominent
Parameter Array: ^MINE^,14211.0    <-- make params prominent
Data Blob: null
Binding: null
readyState: 4
status: 200
Response: {
  "RECORD_DATA": { # "RECORD_DATA" is standard for hec, but can be different -- better to get Hash.keys.first for top level key
    "MyJsonResponse": { JSON, MAY BE INVALID (blackbird doesn't display escape chars) },     <-- try to parse. If invalid, just display the raw string.
    "STATUS_DATA": { # "STATUS_DATA" is standard for most ccl scripts, but it isn't guaranteed to be present
      "STATUS": "S",      <-- S(uccess), Z(empty), P(artial), F(ailure) are our standard statuses
      "SUBEVENTSTATUS": [
        {
          "OPERATIONNAME": "",
          "OPERATIONSTATUS": "",
          "TARGETOBJECTNAME": "",
          "TARGETOBJECTVALUE": ""  <-- if status F, targetobjectvalue and targetobjectname should be displayed
        }
      ]
    }
  }
}
<OTHER STRINGS, ERROR INFO, ETC>
=end
class RequestBlock < Block
  def initialize(blockStr)
    @request_data = Hash.new
    @lines = []
    parse(blockStr)
  end

  def output
    status = "?"
    if !@request_data[:json].nil?
      top_level_key = @request_data[:json].keys[0]
      if !@request_data[:json][top_level_key]["STATUS_DATA"].nil?
        status = @request_data[:json][top_level_key]["STATUS_DATA"]["STATUS"]
      end
    end

    @lines.push("#{@request_data[:program]}: #{status}")
    @lines.push("HTTP Status: #{@request_data[:http_status]}") if @request_data[:http_status] != "200"
    @lines.push(@request_data[:name]) if @request_data[:name] != ""
    @lines.push(@request_data[:params])
    @lines.push("Response:")
    @lines.push(@request_data[:json_str])
    @lines.push(@request_data[:trailing_str]) if @request_data[:trailing_str] != ""

    output_array(@lines)
  end

  private

  def parse(str)
    program = str.match(/Program Name:/)
    params = str.match(/Parameter Array:/)
    data = str.match(/Data Blob:/)
    status = str.match(/status:/)
    response = str.match(/Response:/)

    @request_data[:name] = str[0..(program.begin(0) - 1)].strip
    @request_data[:program] = str[program.end(0)..(params.begin(0) - 1)].strip
    @request_data[:params] = str[params.end(0)..(data.begin(0) - 1)].strip
    @request_data[:http_status] = str[status.end(0)..(response.begin(0) - 1)].strip

    extracted = extract_json(str[response.end(0)..-1])
    @request_data[:json] = extracted[:json]
    @request_data[:json_str] = extracted[:json_str]
    @request_data[:trailing_str] = extracted[:trailing_str]
  end
end

# TODO: parse and format criterion blocks
class CriterionBlock < Block

end
