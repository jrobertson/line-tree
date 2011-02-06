#!/usr/bin/ruby

# file: line-tree.rb

class LineTree  

  def initialize(lines)
    @a = scan_shift(lines)
  end

  def to_a()
    @a
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

end
