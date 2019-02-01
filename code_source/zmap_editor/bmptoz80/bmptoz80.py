import sys


class converter:
  
  def __init__(self):
    None


if __name__ == "__main__":
  off = 36
  h = 22
  w = 24

  
  if len(sys.argv) < 2:
    print "Need at least the input name"
  elif len(sys.argv) < 3:
    print "open %s" % sys.argv[1]
    input = open(sys.argv[1], "rb")
    output = open(sys.argv[1]+".z80.tmp", "w")
    output.write("boss:\n")
    stack = list()
    input.read(0x36),

    for r in range(0, h):
      output.write("\t.db ")
      cpto = 0
      for c in range(0, w):
        str = input.read(4)
        if((ord(str[0]) > 0 or ord(str[1]) > 0 or ord(str[2]))) :
          print "1",
          output.write("1")
        else:
          print "0",
          output.write("0")
        cpto += 1
        if cpto > 6:
          cpto = 0
          output.write("b, ")
      print ""
      if cpto < 7:
        for i in range(cpto, 7):
            output.write("0")
        output.write("b, ")
      output.write("\n")
      #print "%d%d%d," %(ord(str[0]),ord(str[1]),ord(str[2])),

    output.close() 

    output = open(sys.argv[1]+".z80.tmp", "r")
    output2 = open(sys.argv[1]+".z80", "w")
    stack = list()
    for line in output:
      stack.append(line)

    while(len(stack) > 0):
      output2.write(stack.pop())

    output .close()
    input .close()
  
  elif len(sys.argv) == 4:
    None


  
