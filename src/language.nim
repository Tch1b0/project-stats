import terminal, json

type Language* = object
    name*: string
    extension*: string
    color*: ForegroundColor

func languageFromJson*(data: JsonNode): Language =
    Language(name: $data["name"], extension: $data["extension"], color: ForegroundColor(data["color"].getInt()))
