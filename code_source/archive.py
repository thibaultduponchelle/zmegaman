# the 'b' modifier is used to prevent erroneous
# conversion of end-of-line characters on some platforms.
 
def do_the_job(filename):
  fin = open(filename, "rb")
  fout = open("A" + filename,'wb')
  try:
    counter = 0
    archived = None
    add_checksum = 0
    size = None
    size_set = False
    checksum = None
    while True:
      bytes = fin.read(1) # read the next /byte/

      if bytes == "":
        fin.seek(-2,2)
        bytes = fin.read(1)
        print "%02X" % ord(bytes[0]),
        checksum = ord(bytes[0])
        bytes = fin.read(1)
        print "%02X" % ord(bytes[0]),
        checksum += ord(bytes[0]) << 8
        print "Checksum : %04X" % checksum
        cs = (checksum + add_checksum) & 0xFFFF
        cs1 = cs & 0x00ff
        cs2 = ((cs & 0xff00) >> 8)
        print "cs1 : %02X" % cs1
        print "cs2 : %02X" % cs2

        print "New checksum : %04X" % (cs), 
        fout.seek(-2, 2)
        fout.write(chr(cs1))
        fout.write(chr(cs2))

        break;
      if counter == 0:
        end_signature = fin.read(7)
        counter += 7
        print "Signature : " + bytes[0] + end_signature
        fout.write(bytes[0] + end_signature)
      elif counter == 8:
        end_signature2 = fin.read(2)
        counter += 2
        print "Signature2 : %02X %02X %02X " % (ord(bytes[0]), ord(end_signature2[0]), ord(end_signature2[1]))
        fout.write(bytes[0] + end_signature2)
      elif counter == 11: #Comment
        end_comment = fin.read(41) 
        counter += 41
        print "Comment : "+ bytes[0] + end_comment
        com = "Made with love.Free&open source.2012-2013."
        print "New comment : " + com
        #fout.write(bytes[0] + end_comment)
        fout.write(com)
      elif counter == 53:
        size = ord(bytes[0])
        fout.write(bytes[0])
      elif counter == 54:
        size = ord(bytes[0]) << 8
        size_set = True
        print "Size : " + str(size)
        fout.write(bytes[0])
      elif counter == 55:
        start_vdata = fin.read(4)
        counter += 4
        print "Start variable data (magic number, length, id)"
        fout.write(bytes[0] + start_vdata)
      elif counter == 60:
        end_varname = fin.read(7)
        counter += 7
        print "Name : " + bytes[0] + end_varname
        fout.write(bytes[0] + end_varname)
      elif counter == 68:
        print "Version : %02X" % ord(bytes[0])
        archived = fin.read(1)
        counter += 1
        if archived == 0:
          print "Was not archived"
          add_checksum = 0x80
        fout.write("\x80")
        fout.write(bytes[0])
      else:
        fout.write(bytes[0])
        
      
      counter += 1
        
        

      # Do stuff with byte
      # e.g.: print as hex
      #print "%02X" % ord(bytes[0]),
   
  except IOError:
    # Your error handling here
    # Nothing for this example
    pass
  finally:
      fin.close()
      fout.close()

import os
do_the_job("ZMEGAMAN.8xp")
os.remove("ZMEGAMAN.8xp")
os.rename("AZMEGAMAN.8xp", "ZMEGAMAN.8xp")

do_the_job("ZMEGADAT.8xp")
os.remove("ZMEGADAT.8xp")
os.rename("AZMEGADAT.8xp", "ZMEGADAT.8xp")
