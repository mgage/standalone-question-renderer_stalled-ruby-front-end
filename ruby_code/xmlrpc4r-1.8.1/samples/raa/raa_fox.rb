
require "fox"
require "responder"

include Fox

class RAAFoxWindow < FXMainWindow

  include Responder

  ID_TREE, = enum(FXMainWindow::ID_LAST, 1)

  def initialize(app)
    super(app, "RAA FOX", nil, nil, DECOR_ALL, 0, 0, 640, 480)

    FXMAPFUNC(SEL_CLICKED, ID_TREE, "onCmdTree")

    contents   = FXHorizontalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    vert_left  = FXVerticalFrame.new(contents, LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_LEFT,0,0,0,0,10,10,10,10)
    vert_right = FXVerticalFrame.new(contents, LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_RIGHT,0,0,0,0,10,10,10,10)
     
    FXLabel.new(vert_right, "haljljlj", nil, LAYOUT_FILL_X)

    @tree_list = FXTreeList.new(vert_left, 0, nil, 0, (HSCROLLING_OFF|
      TREELIST_SHOWS_LINES|TREELIST_SHOWS_BOXES|FRAME_SUNKEN|FRAME_THICK|
      LAYOUT_FILL_X|LAYOUT_FILL_Y), 0, 0, 0, 0)
    @tree_list.target = self
    @tree_list.selector = ID_TREE
  end

  def onCmdTree(sender, sel, ptr)
    p @elems[ptr]
  end


  def fill_tree_list(tree)
    @elems =  {}

    root = @tree_list.getFirstItem
    root = @tree_list.addItemLast(root, "RAA", nil, nil, nil, true)
    @elems[root] = []

    tree.each {|k1,v1|
      ele = @tree_list.addItemLast(root, k1, nil, nil, nil, true)
      @elems[ele] = [k1]
      v1.each {|k2,v2|
        ele2 = @tree_list.addItemLast(ele, k2, nil, nil, nil, true)
        @elems[ele2] = [k1, k2]
        v2.each {|k3| 
          ele3 = @tree_list.addItemLast(ele2, k3, nil, nil, nil, true) 
          @elems[ele3] = [k1,k2,k3]
        }
      } 
    }

  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end

end # class RAAFoxWindow


def run
  application = FXApp.new("RAAFox", "RAA FOX")
  application.init(ARGV)
  x = RAAFoxWindow.new(application)
  x.fill_tree_list( {"Application" => {"Server" => ["hallo", "leute"], "Mist" => []},
            "Library" => {}
           })

  application.create
  application.run
end

run
