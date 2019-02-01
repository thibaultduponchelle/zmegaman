#!/usr/bin/python

# This is a tool to convert a map to a rle map

import sys
import os	# chickendude

class rle():
  length = 0
  val = -1
  next_is_first_line = True

  def compress(self, input, output):
    fin = open(input, "r")
    fout = open(output, "w")
    for line in fin:
      # Si label alors ecrire
      if line.find(":") > -1:
        if line.find("rle:") == -1:
#          line = line.replace(":", "_rle:")					# original
          filename = os.path.basename(input)							# chickendude
          line = line.replace(":", os.path.splitext(filename)[0]+":")	# chickendude
        fout.write(line)

      # Si data alors on avise
      if line.find(".db") > -1:

        # Si les valeurs hauteur et largeur alors ecrire
        if line.find(".db") > -1 and self.next_is_first_line == True:
          fout.write(line)
          fout.write("\t;;;; Debut data\n")
          self.next_is_first_line = False
        else:
          # Virer les \t, \n, espaces, virgules, dollars, .db
          u = line.strip("\t")
          u = u.replace(",\n", '')
          u = u.replace("\n", '')
          u = u.replace(".db", '')
          u = u.replace("$", '')
          u = u.replace(" ", '')
          #print u
          sl = u.split(",")
          print sl
          #print sl
          for v in sl:
            if self.val == -1:
              self.length = 0
              self.val = v
            if v != self.val:
              fout.write("\t.db %s,$%s\n"%(self.length, self.val))
              self.length = 1
              self.val = v
            else:
              self.length += 1
              self.val = v
    if self.val != '':
      fout.write("\t.db %s,$%s\n"%(self.length, self.val))
    fout.write("\t.db 0 ; marqueur de fin")


if __name__ == "__main__":
 
  if len(sys.argv) > 1:
    print "COMPRESS %s TO %s" %(sys.argv[1], sys.argv[2])
    r = rle()
    r.compress(sys.argv[1], sys.argv[2])




