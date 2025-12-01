import json
import sys

file_path = "/Users/artem/.config/karabiner/karabiner.json"

with open(file_path, "r") as f:
    lines = f.readlines()

# Find the start and end of the manipulators block in the first rule
start_line = 17  # 0-indexed, so line 18
end_line = 450   # 0-indexed, so line 451 (exclusive)

# Debug: print what we see
print(f"Line {start_line+1} content: {repr(lines[start_line])}")

# Verify the lines
if "manipulators" not in lines[start_line]:
    print(f"Error: Line {start_line+1} does not contain \"manipulators\"")
    # Search for it
    for i, line in enumerate(lines[:50]):
        if "manipulators" in line:
            print(f"Found 'manipulators' at line {i+1}: {repr(line)}")
            start_line = i
            break
    else:
        print("Could not find 'manipulators' in first 50 lines")
        sys.exit(1)

# Re-verify end line
# Search for the end of the block
# We look for the closing bracket before the next rule description
for i in range(start_line, len(lines)):
    if "PC-Style Copy/Paste/Cut" in lines[i]:
        # The closing bracket should be a few lines before
        # The structure is:
        # ...
        #     ]
        # },
        # {
        #     "description": "PC-Style Copy/Paste/Cut",
        
        # So lines[i] is description.
        # lines[i-1] is {
        # lines[i-2] is },
        # lines[i-3] is ]
        
        # Let's look backwards from i
        for j in range(i, start_line, -1):
            if "]" in lines[j]:
                end_line = j + 1 # exclusive, so j+1
                print(f"Found closing bracket at line {j+1}")
                break
        break
else:
    print("Could not find next rule")
    sys.exit(1)

new_manipulators = [
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "e" }, { "key_code": "r" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "9", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "org.unknown.keylayout.Russian" } ] } ],
        "from": { "simultaneous": [ { "key_code": "e" }, { "key_code": "r" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "backslash", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "u" }, { "key_code": "i" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "0", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "org.unknown.keylayout.Russian" } ] } ],
        "from": { "simultaneous": [ { "key_code": "u" }, { "key_code": "i" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "backslash" } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "d" }, { "key_code": "f" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "grave_accent_and_tilde", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "org.unknown.keylayout.Russian" } ] } ],
        "from": { "simultaneous": [ { "key_code": "d" }, { "key_code": "f" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "grave_accent_and_tilde", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "j" }, { "key_code": "k" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "grave_accent_and_tilde" } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "org.unknown.keylayout.Russian" } ] } ],
        "from": { "simultaneous": [ { "key_code": "j" }, { "key_code": "k" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "grave_accent_and_tilde" } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "c" }, { "key_code": "v" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "open_bracket", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "m" }, { "key_code": "comma" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "close_bracket", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "key_code": "spacebar", "modifiers": { "mandatory": ["left_option"], "optional": ["any"] } },
        "to": [ { "key_code": "slash", "modifiers": ["left_shift"] } ]
    },
    {
        "type": "basic",
        "conditions": [ { "type": "input_source_if", "input_sources": [ { "input_source_id": "com.apple.keylayout.ABC" } ] } ],
        "from": { "simultaneous": [ { "key_code": "left_option" }, { "key_code": "right_option" } ], "modifiers": { "optional": ["any"] } },
        "to": [ { "key_code": "comma" } ]
    }
]

new_lines = []
new_lines.append("                        \"manipulators\": [\n")
for i, m in enumerate(new_manipulators):
    m_str = json.dumps(m, indent=4)
    # Indent each line of m_str by 28 spaces (24 + 4)
    indented_m_str = ""
    for line in m_str.split("\n"):
        indented_m_str += " " * 28 + line + "\n"
    
    # Remove the last newline
    indented_m_str = indented_m_str.rstrip()
    
    new_lines.append(indented_m_str)
    if i < len(new_manipulators) - 1:
        new_lines.append(",\n")
    else:
        new_lines.append("\n")

new_lines.append("                        ]\n")

# Replace
print(f"Replacing lines {start_line+1} to {end_line}")
lines[start_line:end_line] = new_lines

with open(file_path, "w") as f:
    f.writelines(lines)

print("Successfully updated manipulators.")
