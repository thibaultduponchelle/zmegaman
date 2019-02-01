

class map():
  name = 'map'
  h = 0
  w = 0
  data = None

  def __init__(self, h, w):
    if h > 8:
      self.data = list()
      self.h = int(h/8)
      self.w = int(w/8) 
      for i in range (0, self.h, 1):
        for j in range(0, self.w, 1):
          self.data.append(0)
      print self
    

  def set(self, val, x, y):
    mx = int(x/8)
    my = int(y/8)
    print "mx : %s, my : %s ___ (x : %s, y : %s)" % (mx, my, x, y)
    if (mx > self.w) or (my > self.h):
      print "2.Out of bounds"
      return None
    self.data[self.w * my + mx] = val

  def set_size(self, h_pixels, w_pixels):
    self.h = int(h_pixels/8)
    self.w = int(w_pixels/8) 

  def resize_map(self, h_pixels, w_pixels):
    self.resize_width(w_pixels) 
    print self
    self.resize_height(h_pixels) 
    print self

  def resize_width(self, w_pixels):
    if w_pixels < 8:
      print "Error with is not valid"
      return None
    w = w_pixels - (w_pixels % 8) 
    w = w_pixels/8
    if w > self.w:
      for line in self.data:
        for i in range (w, self.w, -1):
          line.append(0)
    elif w < self.w:
      for line in self.data:
        for i in range(w, self.w, 1):
          line.pop()
    self.w = w

  def resize_height(self, h_pixels):
    print "resize h"
    if h_pixels < 8:
      print "Error height is not valid"
      return None
    h = (h_pixels) -(h_pixels % 8)
    if h > self.h:
      print "Plus grand"
      l = list()
      while h > self.h:
        while len(l) < self.w:
          l.append(0)
        self.data.append(l)
        self.h += 1
    elif h < self.h:
      while h < self.h:
        self.data.pop()
        self.h -= 1

  def export(self, filename):
    file = open(filename, "w")
    file.write("%s:\n" %self.name)
    file.write("\t.db $%s, $%s\n" %(hex(int(self.h))[2:] , hex(self.w)[2:]))
    file.write(self.__str__())
    file.close()

  def sanitize(self, s): 
    s = s.strip("\t")
    s = s.replace(",\n", '')
    s = s.replace("\n", '')
    s = s.replace(".db", '')
    s = s.replace("$", '')
    s = s.replace(" ", '')
    return s
    

  def read_from_file(self, filename):
    file = open(filename, "r")
    self.h = 0
    self.w = 0
    self.data = list()
    for line in file:
      if line.find(":") > -1:
        print "Ouverture de %s" %line
      elif line.find(".db") > -1:
        u = self.sanitize(line)
        sl = u.split(",")
        if len(sl) < 3:
          print "first line"
          self.set_size(int(sl[0], 16) * 8, int(sl[1],16) * 8) # Written in hex mode and 8x8 sprites (we need pixels)
        else: 
          for val in sl:
            if val != '':
              self.data.append(int(val, 16))
    file.close()


  def read_from_file_rle(self, filename):
    file = open(filename, "r")
    self.h = 0
    self.w = 0
    self.data = list()
    for line in file:
      if line.find(":") > -1:
        print "Ouverture de %s" %line
        self.name = line.replace(':', '') 
      elif line.find(".db") > -1:
        u = self.sanitize(line)
        sl = u.split(",")
        if line.find("$") != line.rfind("$"):
          print "first line"
          self.set_size(int(sl[0], 16) * 8, int(sl[1],16) * 8) # Written in hex mode and 8x8 sprites (we need pixels)
        else: 
          try:
            length = int(sl[0])
            val = sl[1]
            if val != '':
              for i in range(0, length):
                self.data.append(int(val, 16))
          except:
            pass
    file.close()





  def get(self, x, y):
    mx = int(x/8)
    my = int(y/8)
    if (mx > self.w) or (my > self.h):
      print "1.Out of bounds"
      return None
    #print self
    return self.data[self.w*my + mx]

  def reset(self):
    for x in range(0, self.w*8, 8): 
      for y in range(0, self.h, 8): 
        self.set(0, x, y)


  def __str__(self):
    str = ''
    str += "\t.db "
    for v in self.data:
      str += '$'
      str += hex(v)[2:]
      str += ","
    return str
