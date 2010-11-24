# simple interface to pdftk:
#   http://www.pdftk.com
class PDFTK
  class << self
    def exec(params)
      `pdftk #{params}`
    end
    
    def info(fn)
      i = exec("#{fn} dump_data")
      a = nil
      i.lines.inject({}) do |m, l|
        case l
        when /^InfoKey: (.*)/
          a = $1
        when /^InfoValue: (.*)/
          m[a] = $1
        when /^(NumberOfPages): (.*)/
          m[:pages] = $2.to_i
          m[$1] = $2
        when /(.+): (.*)/
          m[$1] = $2
        end
        m
      end
    end
    
    def booklet_fn(fn)
      if fn =~ /^(.+)\.pdf$/
        "#{$1}-booklet.pdf"
      else
        raise "Couldn't decide booklet file name for #{fn}"
      end
    end
    
    BLANK_PDF = File.expand_path(File.join(File.dirname(__FILE__), "../blank.pdf"))
    
    def make_booklet(fn)
      page_count = info(fn)[:pages]
      output_fn = booklet_fn(fn)
      page_order = booklet_page_order(page_count)
      blank_no = page_count + 1
      
      mapped_order = page_order.map do |p| 
        p <= page_count ? "A#{p}" : "B1"
      end.join(" ")
      
      exec "A=#{fn} B=#{BLANK_PDF} cat #{mapped_order} output #{output_fn}"
      puts "Making booklet #{fn} >> #{output_fn}"
      
      `open #{output_fn}`
    end
    
    def booklet_page_order(page_count)
      # normalize page count to multiples of 4
      normalized_count = page_count
      if (mod = normalized_count % 4) > 0
        normalized_count += 4 - mod
      end
      
      original_order = (1..normalized_count).to_a
      booklet_order = []
      while !original_order.empty?
        booklet_order << original_order.shift
        booklet_order << original_order.pop
        booklet_order << original_order.pop
        booklet_order << original_order.shift
      end
      booklet_order.reverse
    end
  end
end
