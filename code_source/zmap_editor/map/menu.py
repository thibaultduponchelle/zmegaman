import gtk
from map import map
from sprite import sprite
from rle import rle
import shutil

class menu(gtk.MenuBar):
  ui = None
 
  def __init__(self, ui):
    super(menu, self).__init__()
    self.ui = ui
    self.create_file_menu()
    self.create_map_menu()
    self.create_sprite_menu()
    self.show()

  def create_file_menu(self):
    menu = gtk.Menu()
    new_map = gtk.MenuItem("New map")
    open_map = gtk.MenuItem("Open a map file")
    open_map_rle = gtk.MenuItem("Open a rle compressed map file")
    open_sprite = gtk.MenuItem("Open a sprites file")
    save_map = gtk.MenuItem("Save map to file")
    save_map_rle = gtk.MenuItem("Save rle compressed map to file")
    save_sprite = gtk.MenuItem("Save sprites to file")
    quit = gtk.MenuItem("Quit")
    new_map.connect("activate", self.new_map, 'New map')
    open_map.connect("activate", self.open_map, 'Open map')
    open_map_rle.connect("activate", self.open_map_rle, 'Open map rle')
    open_sprite.connect("activate", self.open_sprite, 'Open sprite')
    save_map.connect("activate", self.save_map, 'Save map')
    save_map_rle.connect("activate", self.save_map_rle, 'Save map rle')
    save_sprite.connect("activate", self.save_sprite, 'Save sprite')
    quit.connect("activate", self.quit, 'Quit')
    root = gtk.MenuItem("Files")
    root.set_submenu(menu)
    menu.append(new_map)
    menu.append(open_map)
    menu.append(open_map_rle)
    menu.append(open_sprite)
    menu.append(save_map)
    menu.append(save_map_rle)
    menu.append(save_sprite)
    menu.append(quit)
    root.show()
    self.append(root)

  def create_map_menu(self):
    menu = gtk.Menu()
    resize_map = gtk.MenuItem("Resize the map")
    reset_map = gtk.MenuItem("Reset map")
    resize_map.connect("activate", self.resize_map, 'Resize map')
    reset_map.connect("activate", self.reset_map, 'Reset map')
    root = gtk.MenuItem("Map")
    root.set_submenu(menu)
    menu.append(resize_map)
    menu.append(reset_map)
    root.show()
    self.append(root)

  def create_sprite_menu(self):
    menu = gtk.Menu()
    new_sprite = gtk.MenuItem("New sprite")
    edit_sprite = gtk.MenuItem("Edit sprite properties")
    reset_sprite = gtk.MenuItem("Reset the selected sprite")
    delete_sprite = gtk.MenuItem("Delete the selected sprite")
    new_sprite.connect("activate", self.new_sprite, 'New sprite')
    edit_sprite.connect("activate", self.edit_sprite, 'Edit sprite')
    reset_sprite.connect("activate", self.reset_sprite, 'Reset sprite')
    delete_sprite.connect("activate", self.delete_sprite, 'Delete sprite')
    root = gtk.MenuItem("Sprite")
    root.set_submenu(menu)
    menu.append(new_sprite)
    menu.append(edit_sprite)
    menu.append(reset_sprite)
    menu.append(delete_sprite)
    root.show()
    self.append(root)

  # Files
  def new_map(self, widget, event):
    print "new map"
    dialog = gtk.Dialog("New blank Map", None, gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT, (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT, gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
    labelh = gtk.Label("Height (pixels)")
    inputh = gtk.Entry(4)
    labelw = gtk.Label("Width (pixels)")
    inputw = gtk.Entry(4)
    hboxh = gtk.HBox(True, 0)
    hboxh.pack_start(labelh)
    hboxh.pack_end(inputh)
    hboxw = gtk.HBox(True, 0)
    hboxw.pack_start(labelw)
    hboxw.pack_end(inputw)
    dialog.vbox.pack_start(hboxh)
    dialog.vbox.pack_end(hboxw)
    hboxh.show()
    hboxw.show()
    inputh.show()
    inputw.show()
    labelh.show()
    labelw.show()
    response = dialog.run()
    roundh = (int(inputh.get_text())/8)* 8
    roundw = (int(inputw.get_text())/8)* 8
    self.ui.m = map(roundh, roundw)
    self.ui.maparea.set_size_request(self.ui.m.w*16, self.ui.m.h*16) 
    dialog.destroy()
    self.ui.queue_draw()

  def open_map(self, widget, event):
    print "open map"
    fcd = gtk.FileChooserDialog(title="Open map file", parent=None, action=gtk.FILE_CHOOSER_ACTION_OPEN, buttons=(gtk.STOCK_OPEN, gtk.RESPONSE_OK), backend=None)
    response = fcd.run()
    if response == gtk.RESPONSE_OK:
      f = fcd.get_filename()
      if self.ui.m == None:
        print "creation"
        self.ui.m = map(128, 128)
      self.ui.m.read_from_file(f)
      self.ui.maparea.set_size_request(self.ui.m.w*16, self.ui.m.h*16) 
    fcd.destroy()
    print f

  def open_map_rle(self, widget, event):
    print "open map"
    fcd = gtk.FileChooserDialog(title="Open map file", parent=None, action=gtk.FILE_CHOOSER_ACTION_OPEN, buttons=(gtk.STOCK_OPEN, gtk.RESPONSE_OK), backend=None)
    response = fcd.run()
    if response == gtk.RESPONSE_OK:
      f = fcd.get_filename()
      if self.ui.m == None:
        print "creation"
        self.ui.m = map(128, 128)
      self.ui.m.read_from_file_rle(f)
      self.ui.maparea.set_size_request(self.ui.m.w*16, self.ui.m.h*16) 
    fcd.destroy()
    print f



  def open_sprite(self, widget, event):
    print "open sprite"
    fcd = gtk.FileChooserDialog(title="Open sprite file", parent=None, action=gtk.FILE_CHOOSER_ACTION_OPEN, buttons=(gtk.STOCK_OPEN, gtk.RESPONSE_OK), backend=None)
    response = fcd.run()
    if response == gtk.RESPONSE_OK:
      f = fcd.get_filename()
      self.ui.spdb.read_from_file(f)
    fcd.destroy()
    print f
    self.ui.model.clear()
    for s in self.ui.spdb.db:
      self.ui.model.append([s.number, s.name])


  def save_map(self, widget, event):
    print "save map"
    fcd = gtk.FileChooserDialog(title="Save map into file", parent=None, action=gtk.FILE_CHOOSER_ACTION_SAVE, buttons=(gtk.STOCK_SAVE, gtk.RESPONSE_OK), backend=None)
    response = fcd.run()
    if response == gtk.RESPONSE_OK:
      f = fcd.get_filename()
      self.ui.m.export(f)
    fcd.destroy()
    print f

  def save_map_rle(self, widget, event):
    print "save map"
    fcd = gtk.FileChooserDialog(title="Save map into file", parent=None, action=gtk.FILE_CHOOSER_ACTION_SAVE, buttons=(gtk.STOCK_SAVE, gtk.RESPONSE_OK), backend=None)
    response = fcd.run()
    if response == gtk.RESPONSE_OK:
      f = fcd.get_filename()
      self.ui.m.export(f)
      f2 = "%s%s"%(f, "temp")
      shutil.move(f, f2)
      r = rle()
      r.compress("%s%s" %(f, "temp"), f)
    fcd.destroy()
    print f




  def save_sprite(self, widget, event):
    print "save_sprite"
    fcd = gtk.FileChooserDialog(title="Save sprite list into file", parent=None, action=gtk.FILE_CHOOSER_ACTION_SAVE, buttons=(gtk.STOCK_SAVE, gtk.RESPONSE_OK), backend=None)
    response = fcd.run()
    if response == gtk.RESPONSE_OK:
      f = fcd.get_filename()
      self.ui.spdb.export(f)
    fcd.destroy()
    print f

  def quit(self, widget, event):
    gtk.main_quit()
    exit(0)
    print "quit"

  # Map
  def resize_map(self, widget, event):
    print "resize_map"
    dialog = gtk.Dialog("Resize Map", None, gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT, (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT, gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
    labelh = gtk.Label("Height (pixels)")
    inputh = gtk.Entry(4)
    labelw = gtk.Label("Width (pixels)")
    inputw = gtk.Entry(4)
    hboxh = gtk.HBox(True, 0)
    hboxh.pack_start(labelh)
    hboxh.pack_end(inputh)
    hboxw = gtk.HBox(True, 0)
    hboxw.pack_start(labelw)
    hboxw.pack_end(inputw)
    dialog.vbox.pack_start(hboxh)
    dialog.vbox.pack_end(hboxw)
    hboxh.show()
    hboxw.show()
    inputh.show()
    inputw.show()
    labelh.show()
    labelw.show()
    response = dialog.run()
    roundh = (int(inputh.get_text())/8)* 8
    roundw = (int(inputw.get_text())/8)* 8
    if self.ui.m == None:
      self.ui.m = map(8, 8)
    self.ui.m.resize_map(roundh, roundw)
    dialog.destroy()
    self.ui.queue_draw()


  def reset_map(self, widget, event):
    print "reset map"
    self.ui.m.reset()
    self.ui.queue_draw()
    

  # Sprite
  def new_sprite(self, widget, event):
    print "new sprite"
    dialog = gtk.Dialog("New Sprite", None, gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT, (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT, gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
    labeln = gtk.Label("Number")
    inputn = gtk.Entry(3)
    labell = gtk.Label("Label")
    inputl = gtk.Entry(20)
    hboxn = gtk.HBox(True, 0)
    hboxn.pack_start(labeln)
    hboxn.pack_end(inputn)
    hboxl = gtk.HBox(True, 0)
    hboxl.pack_start(labell)
    hboxl.pack_end(inputl)
    dialog.vbox.pack_start(hboxn)
    dialog.vbox.pack_end(hboxl)
    hboxn.show()
    hboxl.show()
    inputn.show()
    inputl.show()
    labeln.show()
    labell.show()
    response = dialog.run()
    number = int(inputn.get_text())
    name = inputl.get_text()
    spr = sprite(number, name, None)
    self.ui.spdb.db.append(spr)
    self.ui.model.append([number, name])
    dialog.destroy()
    self.ui.queue_draw()



  def edit_sprite(self, widget, event):
    print "edit sprite"
    if self.ui.sprite == None:
      print "No sprite selected"
      return None
    dialog = gtk.Dialog("New Sprite", None, gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT, (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT, gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
    labeln = gtk.Label("Number")
    inputn = gtk.Entry(3)
    inputn.set_text(self.ui.sprite.number.__str__())
    labell = gtk.Label("Label")
    inputl = gtk.Entry(20)
    inputl.set_text(self.ui.sprite.name)
    hboxn = gtk.HBox(True, 0)
    hboxn.pack_start(labeln)
    hboxn.pack_end(inputn)
    hboxl = gtk.HBox(True, 0)
    hboxl.pack_start(labell)
    hboxl.pack_end(inputl)
    dialog.vbox.pack_start(hboxn)
    dialog.vbox.pack_end(hboxl)
    hboxn.show()
    hboxl.show()
    inputn.show()
    inputl.show()
    labeln.show()
    labell.show()
    response = dialog.run()
    number = int(inputn.get_text())
    name = inputl.get_text()
    self.ui.sprite.number = number
    self.ui.sprite.name = name
    iter = self.ui.model.get_iter(self.ui.path)
    self.ui.model.remove(iter)
    self.ui.model.append([number, name])
    dialog.destroy()
    self.ui.queue_draw()


  def reset_sprite(self, widget, event):
    print "reset sprite"
    self.ui.sprite.reset()
    self.ui.set_preview()
    self.ui.queue_draw()

  def delete_sprite(self, widget, event):
    print "delete_sprite"
    n = -1
    num_to_delete = -1
    for s in self.ui.spdb.db:
      n += 1
      if s == self.ui.sprite:
       num_to_delete = n 

    if num_to_delete != -1:
      self.ui.spdb.db.pop(num_to_delete) 
    if self.ui.path:
      iter = self.ui.model.get_iter(self.ui.path)
      self.ui.model.remove(iter)
    

    

    


