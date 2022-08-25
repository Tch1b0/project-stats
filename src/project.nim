import os
import std/terminal
import std/strutils
import sequtils
import std/algorithm

type 
  LangFile = tuple
    occurences: int
    language: Language
  Project* = object
    path*: string
    files*: seq[string]
    size: BiggestUInt
    languages: seq[Language]
  Language* = object
    name*: string
    extension*: string
    color*: ForegroundColor

proc langFileCmp(a, b: LangFile): int =
  cmp(a.occurences, b.occurences)

method updateFiles(p: var Project, originPath = p.path): void {.base.} =
  ## update the files property of the project object
  for kind, path in walkDir(originPath):
    case kind
    of pcFile, pcLinkToFile:
      p.files.add(path)
      p.size += BiggestUInt(getFileSize(path))
    of pcDir, pcLinkToDir:
      p.updateFiles(path)

method getLangFiles*(p: var Project): seq[LangFile] {.base.} =
  ## get and count files ending in a language extension
  var langFiles: seq[LangFile] = @[]
  for lang in p.languages:
    var occurences = 0
    for file in p.files:
      if file.endsWith("." & lang.extension):
        occurences += 1
    var l: LangFile = (occurences: occurences, language: lang)
    langFiles.add(l)
  langFiles

method print*(p: var Project, showBar = true, showPercentage = true): void {.base.} =
  ## prints the project statistics in a colorful way
  var langFiles = p.getLangFiles()
  langFiles.sort(langFileCmp)
  langFiles.reverse()
  var totalFiles: int = foldl(langFiles, a + b.occurences, 0)

  if showBar:
    # prints a coloured bar representing the language shares in the project
    # "[==================================================]"
    stdout.write("[")
    for lf in langFiles:
      if lf.occurences == 0: continue
      let share = lf.occurences/totalFiles
      stdout.styledWrite(lf.language.color, "=".repeat(int(share * 50)), fgDefault)
    echo "]"
  
  if showPercentage:
    # prints the language shares in numbers
    # "percent% language"
    for lf in langFiles:
      if lf.occurences == 0: continue
      let percentage = (lf.occurences/totalFiles) * 100
      stdout.styledWriteLine(lf.language.color, $int(percentage), "%", " ", lf.language.name)
    echo "Project contains " & $p.size & " Byte"

method init*(p: var Project) {.base.} =
  ## initializes the project with default values
  p.languages = @[
    Language(name: "Python", extension: "py", color: fgBlue),
    Language(name: "JavaScript", extension: "js", color: fgYellow),
    Language(name: "TypeScript", extension: "ts", color: fgCyan),
    Language(name: "Ruby", extension: "rb", color: fgRed),
    Language(name: "Nim", extension: "nim", color: fgYellow),
    Language(name: "Vue", extension: "vue", color: fgGreen),
    Language(name: "Golang", extension: "go", color: fgBlue),
    Language(name: "C", extension: "c", color: fgWhite),
    Language(name: "C++", extension: "cpp", color: fgMagenta),
    Language(name: "Other", extension: "", color: fg8Bit),
  ]
  p.size = 0
  p.updateFiles()
