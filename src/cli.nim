import os

type CLI* = object
  flags: seq[tuple[longFlag: string, shortFlag: string, callback: proc (): void]]

method getArg*(cli: var CLI, number: int, default: string): string {.base.} =
  ## get cli arg number `number`.
  ## If there is no arg number `number` the `default` string is returned
  if paramCount() < number:
    return default
  else:
    return paramStr(number)

method registerFlag*(cli: var CLI, longFlag: string, shortFlag: string, procedure: proc (): void): void {.base.} =
  cli.flags.add((longFlag, shortFlag, procedure))

method run*(cli: var CLI): void {.base.} =
  for i in 0..paramCount() - 1:
    let arg = paramStr(i)
    for flag in cli.flags:
      if arg in @[flag.longFlag, flag.shortFlag]:
        flag.callback()

