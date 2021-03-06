import macros, strutils

type
  NimNodeOf*[K: static[NimNodeKind]] = NimNode

when false:
  converter toNode*[K: static[NimNodeKind]](n: NimNodeOf[K]): NimNode = NimNode(n)

  converter fromNode*[K: static[NimNodeKind]](n: NimNode): NimNodeOf[K] =
    if n.kind != K:
      error("node was " & $n.kind & ", supposed to be " & $K, n)
    result = NimNodeOf[K](n)

proc findIdent*(a: NimNode, b: string): int =
  for i, n in a:
    if n.kind == nnkIdent and n.eqIdent(b):
      return i
  -1

proc skipPostfix*(a: NimNode): NimNode =
  result = if a.kind == nnkPostfix: a[1] else: a

proc skipPostfixPragma*(a: NimNode): NimNode =
  result = a
  while true:
    if result.kind == nnkPostfix: result = result[1]
    elif result.kind == nnkPragmaExpr: result = result[0]
    else: break

proc toList*(a: NimNode): NimNode =
  if a.kind == nnkStmtList: a else: newStmtList(a)

proc addOrSetList*(x: var NimNode, y: NimNode) =
  if x.isNil or x.kind == nnkEmpty:
    x = toList(y)
  else:
    x.add(y)

proc addToList*(x: var NimNode, y: NimNode) =
  if x.isNil or x.kind == nnkEmpty:
    x = toList(y)
  elif x.kind == nnkStmtList:
    x.add(y)
  else:
    x = newStmtList(x, y)

proc uncapitalize*(s: string): string =
  result = s
  result[0] = result[0].toLowerAscii