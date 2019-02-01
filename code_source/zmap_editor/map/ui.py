import sys # Pour les arguments
import gtk
import cairo
from spritedb import spritedb
from map import map
from menu import menu

class interface(gtk.Window):
  path = None
  sprite = None
  m = None
  spdb = None

  def __init__(self):
    super(interface, self).__init__()

  def quit(self, widget, event):
    gtk.main_quit()
    exit(0)

  def preview_button_press_event(self, widget, event):
    #print "Click on the preview !"
    x = int(event.x/16)
    y = int(event.y/16)
    #print "x : %s, y : %s" %(x, y)
    spr = self.spdb.get_sprite_from_number(self.sprite.number)
    if spr:
      spr.set(x, y)
      self.set_preview()
    #self.spdb.export("sprite.inc")
    self.queue_draw()
  
  def preview_expose(self, widget, event):
    self.prevcr = widget.window.cairo_create()
    self.prevcr.scale(16,16)
    self.prevcr.rectangle(0, 0, event.area.height, event.area.width)
    self.prevcr.clip()
    self.set_preview()

  def set_preview(self):
    if self.sprite:
      for x in range(0, 8, 1):
        for y in range(0, 8, 1):
          if self.sprite.get(x,y):
            self.prevcr.rectangle( x, y, 1, 1);
            self.prevcr.set_source_rgb (0, 0, 0);
            self.prevcr.fill()

          else:
            self.prevcr.rectangle(x, y, 1, 1);
            self.prevcr.set_source_rgb (1, 1, 1);
            self.prevcr.fill()
        self.prevcr.move_to(x,y) 

  def map_button_press_event(self, widget, event):
    x = (int(event.x/2))
    y = (int(event.y/2))
    #print '(%s, %s) -> (%s, %s)' % (event.x, event.y, x, y)
    if self.m:
      self.m.set(self.sprite.number, x, y)
    self.queue_draw()

  def set_map(self):
    if self.m:
      self.mapcr.rectangle(0,0, self.m.w*8, self.m.h*8);
      self.mapcr.set_source_rgb (1, 1, 1);
      self.mapcr.fill()

    if self.m:
      for x in range(0, self.m.w*8, 8):
        for y in range(0, self.m.h*8, 8):
          if self.m.get(x, y) != 0:
            num = self.m.get(x, y)
            sp = self.spdb.get_sprite_from_number(num)
            self.put_sprite(x, y, sp)
      #print self.m
      #self.m.export("map.inc")
    
  def map_expose(self, widget, event):
    self.mapcr = widget.window.cairo_create()
    self.mapcr.scale(2,2)
    self.set_map()

  def put_sprite(self, x, y, sprite):
    if sprite == None:
      sprite = self.spdb.db[0]
    i = 0 # x
    j = 0 # y
    for cy in range (y, y+8, 1):
      for cx in range (x, x+8, 1):
        if sprite.test(i, j):
          self.mapcr.rectangle( cx, cy, 1, 1);
          self.mapcr.set_source_rgb (0, 0, 0);
          self.mapcr.fill()
        else:
          self.mapcr.rectangle( cx, cy, 1, 1);
          self.mapcr.set_source_rgb (1, 1, 1);
          self.mapcr.fill()
        self.prevcr.move_to(cx,cy) 
        i += 1
      j += 1
      i = 0
 

  def create_list_store(self, spritedb):
    sw = gtk.ScrolledWindow()
    sw.set_shadow_type(gtk.SHADOW_ETCHED_IN)
    sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
    vbox = gtk.VBox(False, 8)
    vbox.pack_start(sw, True, True, 0)
    self.model = self.create_model(spritedb)
    self.treeView = gtk.TreeView(self.model)
    self.treeView.connect("row-activated", self.on_activated)
    self.treeView.set_rules_hint(True)
    sw.add(self.treeView)
    self.create_columns(self.treeView)
    self.statusbar = gtk.Statusbar()
    vbox.pack_start(self.statusbar, False, False, 0)
    self.show_all()
    return vbox


  def create_model(self, spritedb):
      store = gtk.ListStore(int, str)
      for s in spritedb.db:
          store.append([s.number, s.name])
      return store

  def create_columns(self, treeView):
      rendererText = gtk.CellRendererText()
      column = gtk.TreeViewColumn("N", rendererText, text=0)
      column.set_sort_column_id(0)      
      treeView.append_column(column)
      rendererText = gtk.CellRendererText()
      column = gtk.TreeViewColumn("Name", rendererText, text=1)
      column.set_sort_column_id(1)
      treeView.append_column(column)

  def on_activated(self, widget, row, col):
      self.path = row
      model = widget.get_model()
      text = model[row][0].__str__() + " " + model[row][1] + " "
      self.statusbar.push(0, text)
      self.set_preview()
      self.sprite = self.spdb.get_sprite_from_number(model[row][0])
      self.queue_draw()


if __name__ == "__main__":

  if len(sys.argv) > 1:
    filename = sys.argv[1]
  else:
    #filename = "../tilemap/flash.inc"
    filename = "sprite.inc"  

  prev = interface()
  prev.spdb = spritedb()
  #prev.spdb.read_from_file(filename)
  #prev.sprite = prev.spdb.db[0]

  #prev.m = map(128,128)
  #print prev.m
  #prev.m.read_from_file("map.inc")

  prev.set_position(gtk.WIN_POS_CENTER)
#  prev.set_size_request(1200, 800)
  prev.set_size_request(1200, 600)
  prev.set_resizable(False)

  prev.connect("destroy", prev.quit, 'Quit')


  prev.sprite_list_vbox = prev.create_list_store(prev.spdb)
      

  mapviewport = gtk.Viewport()
  mapsw = gtk.ScrolledWindow()
  mapsw.set_shadow_type(gtk.SHADOW_ETCHED_IN)
  mapsw.set_policy(gtk.POLICY_ALWAYS, gtk.POLICY_ALWAYS)

  prev.darea = gtk.DrawingArea()
  ali = gtk.Alignment(0.5, 0.5, 0.4, 0.6)
  ali.add(prev.darea)

  prev.maparea = gtk.DrawingArea()
  #prev.maparea.set_size_request(800, prev.m.h*16)
  prev.maparea.connect("expose_event", prev.map_expose)
  prev.maparea.connect("button_press_event", prev.map_button_press_event)
  prev.maparea.set_events(gtk.gdk.EXPOSURE_MASK | gtk.gdk.BUTTON_PRESS_MASK) 
  mapviewport.add(prev.maparea)
  mapsw.add(mapviewport)

  hbox = gtk.HBox(False, 0)
  vbox = gtk.VBox(True, 0)
  hbox.set_size_request(300, 1000)
  vbox.set_size_request(400, 200)
  hbox.pack_start(mapsw, True, True, 0)
  hbox.pack_end(vbox, False, False, 0)
  


  prev.darea.connect("expose_event", prev.preview_expose)
  prev.darea.connect("button_press_event", prev.preview_button_press_event)
  prev.darea.set_events(gtk.gdk.EXPOSURE_MASK | gtk.gdk.BUTTON_PRESS_MASK) 

  vbox.pack_start(ali, False, True, 0)
  vbox.pack_end(prev.sprite_list_vbox, True, True, 0)
  prev.side_vbox = vbox
  global_vbox = gtk.VBox(False, 0)
  menu_bar = menu(prev)
  global_vbox.pack_start(menu_bar, False, False, 2)
  global_vbox.pack_end(hbox, True, True, 2)
  prev.add(global_vbox)
  prev.show_all()
  gtk.main()
