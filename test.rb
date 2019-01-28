require_relative 'helper'

class Tests
  # simple unit tests, no framework, lazy
  def initialize
    @test_count = 0
  end

  def run_tests

    # extract_json

    test_string = 'Hey there\'s some text before the JSON {"RECORD_DATA": {"whatever": "stuff", "lists": ["apples","peaches","raspberries","trains","calculators"],"response": { "teapot": {"status": 418,"status_text": "I\'m a teapot"}}}} All events completed successfully'
    extracted = extract_json(test_string)

    expectEqual(extracted[:json]["RECORD_DATA"]["response"]["teapot"]["status"], 418)
    expectEqual(extracted[:trailing_str], 'All events completed successfully')

    # parse_valid_json

    valid_json_str = '{"RECORD_DATA": { "status": "S", "record": { "person_id": 47, "person_name": "George RR Martin" } }}'
    invalid_json_str = '{"RECORD_DATA": { "status": "S", "record": { "person_id": 69, "person_name": "Bobby FartJokes", "note": "I heard that "unescaped quotes" are bad news"} }}'

    valid_json = parse_valid_json(valid_json_str)
    expectEqual(valid_json["RECORD_DATA"]["status"], "S")

    invalid_json = parse_valid_json(invalid_json_str)
    expectEqual(invalid_json, nil)

  end

  def expectEqual(a, b)
    @test_count += 1

    if(a == b)
      puts "Test #{@test_count} success"
      return true
    else
      puts "FAILURE - TEST (#{@test_count}) - Expected #{a} to equal #{b}"
      return false
    end
  end
end

t = Tests.new
t.run_tests
