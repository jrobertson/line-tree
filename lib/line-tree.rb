#!/usr/bin/env ruby

# file: line-tree.rb

require 'rexle'

class LineTree  

  attr_reader :to_a

  def initialize(lines) @to_a = scan_shift(lines)  end
  def to_xml(options={}) Rexle.new(scan_a(*@to_a)).xml(options) end

  private

  def scan_shift(lines)

    a = lines.split(/(?=^\S+)/)

    a.map do |x|

      unless x[/.*/][/^\s*\w+:\S+/] then
        rlines = x.split(/\n/)
        label = [rlines.shift]
        new_lines = rlines.map{|x| x[2..-1]}

        if new_lines.length > 1 then
          label + scan_shift(new_lines.join("\n")) 
        else
          new_lines.length > 0 ? label + [new_lines] : label
        end
      else
        [x.lines.map{|x| x.sub(/^\s{2}/,'')}.join]
      end
    end
  end

  def scan_a(a)

    r = a.shift.match(/('[^']+[']|[^\s]+)\s*(\{[^\}]+\})?\s*(.*)/m)
          .captures.values_at(0,-1,1)

    r[-1] = get_attributes(r.last) if r.last
    a.map {|x| r << scan_a(x.clone) } if a.is_a? Array  
    r
  end

  def get_attributes(s)

    a = s[/{(.*)}/,1].split(',').map do |attr|
      name, val = attr.match(/\s*([^:=]+)[:=]\s*['"]*([a-zA-Z0-9\(\);\-\/:\.\s"'_]*)/).captures
      [name, val.sub(/['"]$/,'')]
    end

    Hash[*a.flatten]
  end

end