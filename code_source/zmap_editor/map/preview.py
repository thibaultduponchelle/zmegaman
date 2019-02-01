import gtk
import cairo

class preview(gtk.DrawingArea):
  prevcr = None
  
  def __init__(self):
    super(preview, self).__init__()

  def button_press_event(self, widget, event):
    print "Key pressed"
    print '(%s, %s)' %(event.x, event.y)
    self.set_preview(None)
    self.queue_draw()
  
  def expose(self, widget, event):
    self.prevcr = widget.window.cairo_create()
    self.prevcr.rectangle(0, 0, event.area.height, event.area.width)
    self.prevcr.clip()
    self.prevcr.set_source_rgb(1, 0, 1)
    self.prevcr.fill()
    self.set_preview(None)

  def set_preview(self, sprite):
    print 'set_preview'
    for x in range(0, 8, 1):
      for y in range(0, 8, 1):
        if self.sprite.get(x,y):
          self.prevcr.rectangle( x, y, 1, 1);
          self.prevcr.set_source_rgb (0, 0, 0);
          self.prevcr.fill()
        else:
          self.prevcr.move_to(x, y)
          self.prevcr.rectangle(x, y, 1, 1);
          self.prevcr.set_source_rgb (1, 1, 1);
          self.prevcr.fill()
      self.prevcr.move_to(x,y) 

if __name__ == "__main__":

  pre = preview()
  spdb = spritedb()
  spdb.read_from_file("gut.inc")
  sprite = spdb.db[0]

  prev.set_position(gtk.WIN_POS_CENTER)
  prev.set_size_request(320, 320)

  prev.connect("destroy", prev.quit, 'Quit')

  vbox = gtk.VBox(False, 0)
  prev.add(vbox)

  prev.create_cellview(None)


  prev.darea = gtk.DrawingArea()
  #prev.add(prev.darea)
  prev.darea.connect("expose_event", prev.expose)
  prev.darea.connect("button_press_event", prev.button_press_event)
  prev.darea.set_events(gtk.gdk.EXPOSURE_MASK | gtk.gdk.BUTTON_PRESS_MASK) 

  vbox.pack_start(prev.darea, True, True, 0)
  vbox.pack_end(prev.prevcv, True, True, 0)
  prev.show_all()
  gtk.main()
