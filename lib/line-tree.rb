#!/usr/bin/ruby

# file: line-tree.rb

require 'rexle'

class LineTree  

  attr_reader :to_a

  def initialize(lines) @to_a = scan_shift(lines)  end
  def to_xml(options={}) 
    Rexle.new(scan_a(*@to_a)).xml(options)
  end

  private

  def scan_shift(lines)
    a = lines.split(/^\b/)
    a.map do |x|
      rlines = x.split(/\n/)
      label = [rlines.shift]
      new_lines = rlines.map{|x| x[2..-1]}
      if new_lines.length > 1 then
        label + scan_shift(new_lines.join("\n")) 
      else
        new_lines.length > 0 ? label + [new_lines] : label
      end
    end
  end

  def scan_a(a)
    r = a.shift.match(/([^\s]+)\s?(.*)/).captures << {}  
    a.map {|x| r << scan_a(x.clone) } if a.is_a? Array  
    r
  end


end
