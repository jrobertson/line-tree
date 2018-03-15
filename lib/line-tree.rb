#!/usr/bin/env ruby

# file: line-tree.rb

require 'rexle'


class LineTree

  attr_reader :to_a

  def initialize(raw_s, level: nil, ignore_non_element: true, 
                 ignore_blank_lines: true, ignore_label: false, 
                 ignore_newline: true, root: nil, debug: false)
    
    s = root ? root + "\n" + raw_s.lines.map {|x| '  ' + x}.join : raw_s
    
    @ignore_non_element = ignore_non_element
    @ignore_label = ignore_label
    @ignore_blank_lines = ignore_blank_lines
    @ignore_newline = ignore_newline
    @debug = debug
    
    lines = ignore_blank_lines ? s.gsub(/^ *$\n/,'') : s

    @to_a = scan_shift(lines.strip, level)
    
  end
  
  def to_doc(encapsulate: false)    
    
    a = @to_a
    
    a2 = if a[0].is_a? Array then      
      encapsulate ? encap(a) : scan_a(a)
    else
      scan_a(*a)
    end
    
    a2.unshift('root', {})
    puts 'a2: ' + a2.inspect if @debug
    
    Rexle.new(a2)
    
  end
    
  def to_xml(options={})
    to_doc.xml(options)
  end

  private
  
  def encap(a)
    
    puts '_a: ' + a.inspect
    
    a.each do |node|

      encap node[-1] if node[-1].is_a? Array
      
      if node.is_a? Array then
        val = node[0]
        node.insert 1, {}, val
        node[0] = 'entry'
      end

    end
    
    puts '2a: ' + a.inspect
    
    if a.first.is_a? String then
      val = a[0]
      a.insert 1, {}, val
      a[0] = 'entry'
    end
    
    a

  end

  def scan_shift(lines, level=nil)

    level -= 1 if level

    return [] if lines.strip.empty?
    a = lines.split(/(?=^\S+)/)

    return [a] if a.length <= 1 and a.first.strip.empty?
    
    a.map do |x|      

      if @ignore_label == true or not x[/.*/][/^ *\w+:\S+/] then

        rlines = if @ignore_newline then
          x.lines.map {|x| x.sub(/(.)\n$/,'\1') }
        else
          x.lines
        end
      
        rlines = [x.gsub(/^ {2}/,'')] if level and level < 0

        label = [rlines.shift]
        new_lines = rlines.map{|x| x.sub(/^ {2}/,'')}

        if new_lines.length > 1 then
          separator = @ignore_newline ? "\n" : ''
          label + scan_shift(new_lines.join(separator),level)           

        else          

          #label = [] if label == ["\n"]
          
          if (new_lines.length > 0 and new_lines != [nil]) then
            
            if label == ["\n"] then
              [new_lines]
            else
              label + [new_lines]
            end
          else
            label
          end
        end
        
      else
        [x.lines.map{|x| x.sub(/^ {2}/,'').chomp }.join]
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
