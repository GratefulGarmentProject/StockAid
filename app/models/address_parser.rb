class AddressParser
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  def parse(value)
    case value.strip
    when "HISTORICAL", "confidential", ""
      {}
    when /\A([^,]*), ([^,]*), ([^,]*), ([a-zA-Z]{2}) (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        address2: Regexp.last_match[2].strip,
        city: Regexp.last_match[3].strip,
        state: Regexp.last_match[4].strip,
        zip: Regexp.last_match[5].strip
      }
    when /\A([^,]*), ([^,]*), ([^,]*), ([a-zA-Z]{2})\z/
      {
        address1: Regexp.last_match[1].strip,
        address2: Regexp.last_match[2].strip,
        city: Regexp.last_match[3].strip,
        state: Regexp.last_match[4].strip
      }
    when /\A([^,]*), ([^,]*), ([^,]*) ([a-zA-Z]{2}) (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        address2: Regexp.last_match[2].strip,
        city: Regexp.last_match[3].strip,
        state: Regexp.last_match[4].strip,
        zip: Regexp.last_match[5].strip
      }
    when /\A([^,]*), ([^,]*), ([^,]*), ([a-zA-Z]{2}), (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        address2: Regexp.last_match[2].strip,
        city: Regexp.last_match[3].strip,
        state: Regexp.last_match[4].strip,
        zip: Regexp.last_match[5].strip
      }
    when /\A([^,]*), (Building [^, ]+) ([^,]*), ([a-zA-Z]{2}) (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        address2: Regexp.last_match[2].strip,
        city: Regexp.last_match[3].strip,
        state: Regexp.last_match[4].strip,
        zip: Regexp.last_match[5].strip
      }
    when /\A([^,]*), ([^,]*), ([a-zA-Z]{2}) (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        city: Regexp.last_match[2].strip,
        state: Regexp.last_match[3].strip,
        zip: Regexp.last_match[4].strip
      }
    when /\A([^,]*), ([^,]*), ([a-zA-Z]{2}), (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        city: Regexp.last_match[2].strip,
        state: Regexp.last_match[3].strip,
        zip: Regexp.last_match[4].strip
      }
    when /\A([^,]*), ([^,]*) ([a-zA-Z]{2}) (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        city: Regexp.last_match[2].strip,
        state: Regexp.last_match[3].strip,
        zip: Regexp.last_match[4].strip
      }
    when /\A([^,]*), ([^,]*) ([a-zA-Z]{2})\. (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        city: Regexp.last_match[2].strip,
        state: Regexp.last_match[3].strip,
        zip: Regexp.last_match[4].strip
      }
    when %r(\A([^,]* C/O [^,]*), ([^,]{3,}), ([^,]{3,}), (\d+-?\d*)\z)
      {
        attention: Regexp.last_match[1].strip,
        address1: Regexp.last_match[2].strip,
        city: Regexp.last_match[3].strip,
        zip: Regexp.last_match[4].strip
      }
    when /\A([^,]*) (Oakland|Modesto), ([a-zA-Z]{2}) (\d+-?\d*)\z/
      {
        address1: Regexp.last_match[1].strip,
        city: Regexp.last_match[2].strip,
        state: Regexp.last_match[3].strip,
        zip: Regexp.last_match[4].strip
      }
    when /\A([^,]* Bascom Avenue [^,]*)\z/
      {
        address1: Regexp.last_match[1].strip
      }
    else
      raise "Address is unparseable: #{value}"
    end
  end
end
