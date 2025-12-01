import json
import sys

file_path = "/Users/artem/.config/karabiner/karabiner.json"

with open(file_path, "r") as f:
    lines = f.readlines()

# Find the start and end of the manipulators block in the first rule
start_line = 17  # 0-indexed, so line 18
end_line = 450   # 0-indexed, so line 451 (exclusive)

# Verify the lines
if "manipulators" not in lines[start_line]:
    # Search for it
    for i, line in enumerate(lines[:50]):
        if "manipulators" in line:
            start_line = i
            break
    else:
        print("Could not find 'manipulators' in first 50 lines")
        sys.exit(1)

# Search for the end of the block
for i in range(start_line, len(lines)):
    if "PC-Style Copy/Paste/Cut" in lines[i]:
        for j in range(i, start_line, -1):
            if "]" in lines[j]:
                end_line = j + 1 
                break
        break
else:
    print("Could not find next rule")
    sys.exit(1)

new_manipulators = [
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "key_code": "spacebar", "modifiers": { "mandatory": ["left_option"], "optional": ["any"] } },
        "to": [ { "key_code": "slash", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "key_code": "right_option", "modifiers": { "mandatory": ["left_option"], "optional": ["any"] } },
        "to": [ { "key_code": "comma" } ]
    }
]

new_lines = []
new_lines.append("                        \"manipulators\": [\n")
for i, m in enumerate(new_manipulators):
    m_str = json.dumps(m, indent=4)
    indented_m_str = ""
    for line in m_str.split("\n"):
        indented_m_str += " " * 28 + line + "\n"
    indented_m_str = indented_m_str.rstrip()
    new_lines.append(indented_m_str)
    if i < len(new_manipulators) - 1:
        new_lines.append(",\n")
    else:
        new_lines.append("\n")

new_lines.append("                        ]\n")

lines[start_line:end_line] = new_lines

with open(file_path, "w") as f:
    f.writelines(lines)

print("Successfully removed all combos except Alt+Space and Alt+Alt.")
