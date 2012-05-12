#Introducing the line-tree gem

The line-tree gem is designed to parse lines of text, with each line being parsed as separate text fields which can be represented as an array.

If the line is indented then it's treated as a nested array of the line above.

    require 'line-tree'

    lines =<<LINES
    a
      b 123
      bike 456
    LINES


    LineTree.new(lines).to_a
    #=> [["a", ["b 123"], ["bike 456"]]]

## XML

    puts LineTree.new(lines).to_xml

output:

    <?xml version='1.0' encoding='UTF-8'?>
    <a><b>123</b><bike>456</bike></a>

If you want the XML to use attributes, write the attributes as a hash after the element name e.g.

    bike {colour: 'red'} 456
