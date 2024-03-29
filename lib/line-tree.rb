#!/usr/bin/env ruby

# file: line-tree.rb

require 'rexle'


module HashDigx
  refine Hash do
    
    def digx( a)

      self.dig a[0], *a[1..-1].flat_map {|x| [:body, x]}

    end  
  end
end



class LineTree
  using ColouredText

  def initialize(raw_s, level: nil, ignore_non_element: true, 
                 ignore_blank_lines: true, ignore_label: false, 
                 ignore_newline: true, root: nil, debug: false)
    
    
    puts 'inside linetree'.info if @debug
    
    @root = root
    s =  raw_s
    
    @ignore_non_element = ignore_non_element
    @ignore_label = ignore_label
    @ignore_blank_lines = ignore_blank_lines
    @ignore_newline = ignore_newline
    @debug = debug
    
    lines = ignore_blank_lines ? s.gsub(/^ *$\n/,'') : s
    puts ('lines : ' + lines.inspect).debug if @debug
    @to_a = scan_shift(lines.lstrip, level)
    
  end
  
  def to_a(normalize: false)
    normalize ? norm(@to_a) : @to_a
  end
  
  def to_doc(encapsulate: false)    
    
    a = @to_a
    
    a2 = if a[0].is_a? Array then      
      encapsulate ? encap(a) : scan_a(a)
    else
      puts 'before scan_a' if @debug
      scan_a(*a)
    end

    
    
    a3 = @root ? a2.unshift(@root, {}) : a2.flatten(1)
      
    puts 'a3: ' + a3.inspect if @debug  

    Rexle.new(a3)
    
  end
  
  def to_h()
    build_h(@to_a)
  end
  
  def to_html(numbered: false)
    
    @numbered = numbered
    s = "<ul>%s</ul>" % make_html_list(@to_a)
    puts ('s: ' + s.inspect).debug if @debug
    puts s if @debug
    Rexle.new(s).xml declaration: false
    
  end

  #  key–value pair returns Hash object describing a
  #  flat representation of a tree
  #
  def to_kv_pair

    def scan2keypair(h, trail=nil)

      h.inject([]) do |r,x|

        if x.last.is_a? String then

          key, val = x

          new_key = if r.last and r.last.first.length > 0 then
            key.to_s
          else
            key.to_s
          end
          r << [[trail, new_key].compact.join('/'), val]
        else
          new_key = x.first.to_s
          r << [new_key, x.last.first]
          r.concat scan2keypair(x.last.last, [trail, new_key].compact.join('/'))
        end

      end

    end

    scan2keypair(self.to_h).to_h

  end
  
  def to_tree()
    
    def make_tree_list(a)
      
      items = a.inject([]) do |r,x|    
        
        if x.is_a? Array then
          r << make_tree_list(x)
        else
          r + ['item', {title: x}]
        end
      end

    end

    a = make_tree_list(@to_a)
    doc = Rexle.new(['tree', {}, *a])
    doc.xml    
    
  end
    
  def to_xml(options={})
    to_doc.xml(options)
  end

  private
  
  def build_h(a)

    a.inject({}) do |r,x|

      h2 = if x.is_a? Array and x.length > 1 then

        {x[0] => {summary: {}, body: build_h(x[1..-1]) } }

      else

        {x[0] => {summary: {}}}
      end

      r.merge(h2)

    end
  end
  
  def encap(a)
        
    a.each do |node|

      puts 'node: ' + node.inspect if @debug
      
      encap node[1..-1] if node[1].is_a? Array
      
      if node.is_a? Array then
        val = node[0]
        node.insert 1, {}, val
        node[0] = 'entry'
      end

    end
        
    if a.first.is_a? String then
      val = a[0]
      a.insert 1, {}, val
      a[0] = 'entry'
    end
    
    a

  end
  
  def make_html_list(a, indent=-1, count=nil)

    puts 'inside make_html_list'.info if @debug
    
    items = a.map.with_index do |x, i|    
      
      puts ('x:'  + x.inspect).debug if @debug
      
      if x.is_a? Array then

        id, head, tail = if count then 
         
          [
            count.to_s + '.' + i.to_s, 
            i == 1 ? "<ul>\n" : '', 
            i == a.length - 1 ? "\n</ul>\n</li>" : ''
          ]

        else
          [i+1, '', '']
        end

        head + make_html_list(x, indent+1, id) + tail
        
      else

        #"%s%s %s" % ['  ' * indent, count, x]
        r = if @numbered then
          "%s<li id='n%s'>%s" % ['  ' * indent, count.to_s.gsub('.','-'), x]
        else
          "%s<li>%s" % ['  ' * indent, x]
        end
        
        i == 1 ? "<ul>" + r  : i == a.length - 1 ? r + "</li>" : r + ""

      end

    end

    items.join("\n")

  end
  
  # Improves readability by removing unnecessary brackets from an Array row. 
  # Thus making it a String when there are no children.
  #
  def norm(a)

    a.map do |x|

      if x.is_a? Array then
        
        if x.length < 2 then 
          x.first
        else
          row = norm(x[1..-1])
          [x.first, row]
        end
        
      else
        x
      end
      
    end
  end

  

  def scan_shift(lines, level=nil)

    level -= 1 if level

    return [] if lines.strip.empty?
    a = lines.split(/(?=^\S+)/)

    return [a] if a.length <= 1 and a.first.strip.empty?
    
    a.map do |x|      

      puts 'x: ' + x.inspect if @debug
      
      #jr240521 x.sub!(/ *$/,'')
      
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
        
        puts 'chomp' if @debug
        puts 'level: ' + level.inspect if @debug
        
        if level and level < 1 then
          [x]
        else
          [x.lines.map{|x| x.sub(/^ {2}/,'').chomp }.join]
        end
      end
    end

  end
  
  def scan_a(a)
    
    puts 'a: ' + a.inspect if @debug    
    
    a.each do |node|
      
      puts 'node: ' + node.inspect if @debug
      
      if node.is_a? Array then      
        if node[1].is_a?(Array) and node[1][0] =~ /^<\w+/ then

          r = parse_node(node[0])
          node[0] = r[0]
          node[2] = node[1][0]
          node[1] = r[1]

        else
          
          scan_a node[1..-1] if node[1..-1].is_a?(Array)
        
          puts 'node2: ' + node.inspect if @debug

          r = parse_node(node[0])
          node[0] = r[0]; node.insert 1, r[1], r[2]        

        end
      end
    end
        
    if a.first.is_a? String then
      
      s = a[0]
      
      if @ignore_non_element then
        non_element = s[/^ *(\w+:)/,1]    
        return [nil,non_element] if non_element
      end      
      
      r = parse_node(s)
      a[0] = r[0]; a.insert 1, r[1], r[2]        
    end
    
    a

  end


  def get_attributes(s)
    
    a = s[1..-2].split(/(\w+:)/)[1..-1].each_slice(2).map do |label, val|
      [label[0..-2], val.strip.sub(/^['"]/,'').sub(/['"]$/,'')]
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
  
  def parse_node(s)
    
    r = s.match(/('[^']+[']|[^ ]+) *(\{.*\})? *(.*)/m)
                                                .captures.values_at(0,1,-1)

    if r[1] then
      
      r[1] = get_attributes(r[1])
      
    elsif s[/(\w+ *= *["'])/]
      
      raw_attributes, value = s.split(/(?=[^'"]+$)/,2)
      r[1] = get_xml_attributes raw_attributes
      r[-1] = value.to_s.strip

    end      
    
    r
  end

end
