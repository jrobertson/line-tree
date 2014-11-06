#!/usr/bin/env ruby

# file: line-tree.rb

require 'rexle'

class LineTree  

  attr_reader :to_a

  def initialize(lines, level: nil) @to_a = scan_shift(lines.strip, level)  end
  def to_xml(options={}) Rexle.new(scan_a(*@to_a)).xml(options) end

  private

  def scan_shift(lines, level=nil)

    level -= 1 if level

    a = lines.split(/(?=^\S+)/)

    a.map do |x|

      unless x[/.*/][/^\s*\w+:\S+/] then
        rlines = x.split(/\n/)
        label = [rlines.shift]
        new_lines = rlines.map{|x| x[2..-1]}

        if new_lines.length > 1 then

          if level then

            if level < 1 then

              [(label + new_lines).join("\n")]
            else
              label + scan_shift(new_lines.join("\n"),level) 
            end
          else
            label + scan_shift(new_lines.join("\n"),level) 
          end          
          
        else
          new_lines.length > 0 ? label + [new_lines] : label
        end
      else
        [x.lines.map{|x| x.sub(/^\s{2}/,'')}.join]
      end
    end

  end

  def scan_a(a)
    
    s = a.shift
    r = s.match(/('[^']+[']|[^\s]+)\s*(\{[^\}]+\})?\s*(.*)/m)
                                                 .captures.values_at(0,-1,1)

    if r.last then
      
      r[-1] = get_attributes(r.last)
      
    elsif s[/(\w+\s*=\s*["'])/]
      
      raw_attributes, value = s.split(/(?=[^'"]+$)/,2)
      r[-1] = get_xml_attributes raw_attributes
      r[1] = value.to_s.strip

    end
    
    a.map {|x| r << scan_a(x.clone) } if a.is_a? Array  
    
    r
  end

  def get_attributes(s)
    
    a = s.scan(/\w+: ["'][^"']+["']/).map do |attr|
      name, val = attr.match(/\s*([^:=]+)[:=]\s*['"]*([a-zA-Z0-9\(\);\-\/:\.,\s"'_]*)/).captures
      [name, val.sub(/['"]$/,'')]
    end

    Hash[*a.flatten]
  end
  
  def get_xml_attributes(raw_attributes)
    
    r1 = /([\w\-:]+\='[^']*)'/
    r2 = /([\w\-:]+\="[^"]*)"/
    
    r =  raw_attributes.scan(/#{r1}|#{r2}/).map(&:compact).flatten.inject({}) do |r, x|
      attr_name, val = x.split(/=/,2) 
      r.merge(attr_name.to_sym => val[1..-1])
    end

    return r
  end
  

end
