#!/usr/bin/env ruby

# file: line-tree.rb

require 'rexle'

class LineTree

  attr_reader :to_a

  def initialize(s, level: nil, ignore_non_element: true, 
                              ignore_blank_lines: true, ignore_label: false)
    
    @ignore_non_element = ignore_non_element
    @ignore_label = ignore_label
    @ignore_blank_lines = ignore_blank_lines
    
    lines = ignore_blank_lines ? s.gsub(/^ *$\n/,'') : s

    @to_a = scan_shift(lines.strip, level)
  end
    
  def to_xml(options={})
    a = scan_a(*@to_a).first
    Rexle.new(a).xml(options)
  end

  private

  def scan_shift(lines, level=nil)

    level -= 1 if level

    a = lines.split(/(?=^\S+)/)

    return [a] if a.length <= 1 and a.first.strip.empty?
    
    a.map do |x|      

      if @ignore_label == true or not x[/.*/][/^ *\w+:\S+/] then

        rlines = x.lines.map {|x| x.sub(/(.)\n$/,'\1')}

        rlines = [x.gsub(/^ {2}/,'')] if level and level < 0
        label = [rlines.shift]
        new_lines = rlines.map{|x| x.sub(/^ {2}/,'')}
        
        if new_lines.length > 1 then
          label + scan_shift(new_lines.join("\n"),level)           
        else          
          (new_lines.length > 0 and \
                            new_lines != [nil])? label + [new_lines] : label
        end
        
      else
        [x.lines.map{|x| x.sub(/^ {2}/,'')}.join]
      end
    end

  end

  def scan_a(a)
    
    s = a.shift
    
    if @ignore_non_element then
      non_element = s[/^ *(\w+:)/,1]    
      return [nil,non_element] if non_element
    end
    
    r = s.match(/('[^']+[']|[^ ]+) *(\{.*\})? *(.*)/m)
                                                 .captures.values_at(0,1,-1)

    if r[1] then
      
      r[1] = get_attributes(r[1])
      
    elsif s[/(\w+ *= *["'])/]
      
      raw_attributes, value = s.split(/(?=[^'"]+$)/,2)
      r[1] = get_xml_attributes raw_attributes
      r[-1] = value.to_s.strip

    end
    
    if a.is_a? Array then
      
      a.map do |x|
        result, remaining = scan_a(x.clone) 

        if remaining then
          r.last ?  r << remaining :  r[-1] += remaining  
        end
        r << result
      end
    end
    
    [r, non_element]
  end

  def get_attributes(s)
    
    a = s.scan(/\w+: ["'][^"']+["']/).map do |attr|

      name, val = attr.match(/\s*([^:=]+)[:=]\s*['"]*\
([a-zA-Z0-9\(\);\-\/:\.,\s"'_\{\}\$]*)/).captures
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
