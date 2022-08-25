import project
import cli

var 
  c = CLI()
  proj = Project(path: c.getArg(1, "./"))

proj.init()

proj.print()
