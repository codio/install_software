JSON_FILE="/home/codio/.claude.json"

if [ ! -f "$JSON_FILE" ]; then
  exit 0
fi

LAST_20_CHARS="${ANTHROPIC_API_KEY: -20}"

# Check if the value already exists in the array to avoid duplicates
EXISTS=$(jq -r --arg val "$LAST_20_CHARS" '.customApiKeyResponses.rejected[]? | select(. == $val)' "$JSON_FILE" 2>/dev/null)

if [ -n "$EXISTS" ]; then
  exit 0
fi

# Add the value to the customApiKeyResponses.rejected array
# This will create the nested structure if it doesn't exist
jq --arg val "$LAST_20_CHARS" '
    .customApiKeyResponses.rejected //= [] | 
    .customApiKeyResponses.rejected += [$val]
' "$JSON_FILE" >> "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "$JSON_FILE"