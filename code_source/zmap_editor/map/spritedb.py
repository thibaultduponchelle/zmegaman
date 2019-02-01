from sprite import sprite


class spritedb:
  db = list()
  number = 0


  def __init__(self):
    self.db = list()
    l = list()
    l.append(0b00000000)
    l.append(0b00000000)
    l.append(0b00000000)
    l.append(0b00000000)
    l.append(0b00000000)
    l.append(0b00000000)
    l.append(0b00000000)
    l.append(0b00000000)
    empty = sprite(0, "empty", l)
    self.db.append(empty)


  def bin_to_dec(self, string):
    result = 0
    for car in string:
        result *= 2
        if car == '1':
            result += 1
        elif car == '0':
            pass
        else:
            return None
    return result 

  def get_sprite_from_number(self, number):
    for s in self.db:
      if s.number == number:
        return s
    return None

 
  def read_from_file(self, filename):
    self.db = list() # reset sinon ajoute a chaque fois
    if filename == None:
      print "erreur"
      self.db = None
      return 
    file = open(filename, "r")
    for line in file:
      if line[0] == ';' and line[1] == '>':
        self.number += 1
        self.read_one_sprite(file)
    
    file.close() 
    
  def read_one_sprite(self, file):
    ''' Create a sprite from a file '''
    number = None
    name = None
    data = None
    for line in file:
      if line.find(':') > -1:
        p = line.partition(':')
        name = p[0]
      if line[0] == '\t' or line[0] == ' ':
        if data == None:
          data = list()
        p = line.partition('.db ')
        p2 = p[2].partition('b')
        v = self.bin_to_dec(p2[0])
        data.append(v)
      if (line[0] == ';') and (line[1] == '<') and (name != None) and (data!= None):
        self.db.append(sprite(self.number, name, data))
        return 

  def export(self, filename):
    file = open(filename, "w")
    file.write(self.__str__())
    file.close()



  def __str__(self):
    if self.db == None:
      print "Error"
      return 
    else:
      str = ''
      for s in self.db: 
        str += s.__str__()
        str += '\n'
      return str
    

if __name__ == "__main__":
  spdb = spritedb()
  spdb.read_from_file("gut.inc")
  print spdb



  




  
