module Ripple
  def self.generate(kind, args)
    Ripple::Generate.send(kind, args)
  end
  
  module Generate
    def self.work(works)
      works.each do |w|
        FileUtils.mkdir_p(w)
        File.open(File.join(w, "_work.yml"), "w+") {|f| f << WORK_DEF}
      end
      FileUtils.cd(works.first)
    end
    
    def self.mvt(movements)
    end

    WORK_DEF = <<EOF
title: some title
subtitle: some subtitle
composer: some composer
parts:
score:
  hide_figures: true
  order:
    - violino1
    - violino2
    - viola
    - soprano
    - alto
    - tenore
    - basso
    - continuo
  groups:
    - brace: [violino1, violino2]
    - bracket: [soprano, alto, tenore, basso]
EOF

  end
end