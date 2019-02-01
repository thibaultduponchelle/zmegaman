
class sprite():

  name = None
  number = None
  data = None



  def __init__(self, nb, name, d):
    self.number = nb
    self.name = name
    if d == None:
      d = list()
      d.append(0)
      d.append(0)
      d.append(0)
      d.append(0)
      d.append(0)
      d.append(0)
      d.append(0)
      d.append(0)
    self.data = d

  def __str__(self):
    # Ne pas ecrire le empty sprite
    if self.number != 0:
      str = ';>'
      #str += '\n;$%s' %hex(self.number)[2:]
      str += '\n'
      str += '%s:' %self.name
      str += '\n'
      for y in range(0, 8, 1):
        str += "\t.db "
        for x in range (0, 8, 1):
          str += self.get(x, y).__str__()
        str +="b"
          
        str += '\n'
      str+= ';<'
      return str
    return ''


  def test(self, x, y):
    if y > len(self.data):
      print "erreur"
      return 0
    byte = self.data[y]
    comp = 0b10000000 >> x
    return (byte & comp) > 0

  def get(self, x, y):
    if y > len(self.data):
      print "erreur"
      return 0
    byte = self.data[y]
    comp = 0b10000000 >> x
    if (byte & comp) > 0:
      return 1
    else:
      return 0

  def set(self, x, y):
    if y > len(self.data):
      print "erreur"
      return 0

    if self.test(x, y):
      print "res"
      byte = self.data[y]
      comp = 0b10000000 >> x
      comp = ~comp
      self.data[y] = byte & comp
    else:
      print "set"
      byte = self.data[y]
      comp = 0b10000000 >> x
      self.data[y] = byte | comp

  def reset(self):
    for i in range(0, 8, 1):
      self.data[i] =  0


if __name__ == "__main__":
  d = list()
  d.append(0b11110000);
  d.append(0b11110000);
  d.append(0b11110000);
  d.append(0b11110000);
  d.append(0b11110000);
  d.append(0b11110000);
  d.append(0b11110000);
  d.append(0b11110000);
  spr = sprite(0, "gut0", 8, 1, d)
  print spr
  print spr.test(3, 3)
  print spr.test(7, 7)
  print spr.test(0, 0)
  


    
