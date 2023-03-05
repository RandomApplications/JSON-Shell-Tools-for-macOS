#!/bin/sh

#
# Created by Pico Mitchell (of Random Applications)
#
# MIT License
#
# Copyright (c) 2023 Pico Mitchell (Random Applications)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# NOTE: This file can be saved and installed to be run as a standalone script, or the function below can be copy-and-pasted to integrate into your own sh/bash/zsh scripts.

# The following "json_value" function is best for doing very direct/simple value retrievals from JSON structures,
# for more advanced capabilites, check out https://randomapplications.com/json_extract instead.

json_value() { # Version 2023.3.4-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_value
	{ set -- "$(/usr/bin/osascript -l 'JavaScript' -e 'ObjC.import("unistd"); function run(argv) { const stdin = $.NSFileHandle.fileHandleWithStandardInput; let out; for (let i = 0;' \
		-e 'i < 3; i ++) { let json = (i === 0 ? argv[0] : (i === 1 ? argv[argv.length - 1] : ($.isatty(0) ? "" : $.NSString.alloc.initWithDataEncoding((stdin.respondsToSelector("re"' \
		-e '+ "adDataToEndOfFileAndReturnError:") ? stdin.readDataToEndOfFileAndReturnError(ObjC.wrap()) : stdin.readDataToEndOfFile), $.NSUTF8StringEncoding).js.replace(/\n$/, ""))))' \
		-e 'if ($.NSFileManager.defaultManager.fileExistsAtPath(json)) json = $.NSString.stringWithContentsOfFileEncodingError(json, $.NSUTF8StringEncoding, ObjC.wrap()).js; if (/[{[]/' \
		-e '.test(json)) try { out = JSON.parse(json); (i === 0 ? argv.shift() : (i === 1 && argv.pop())); break } catch (e) {} } if (out === undefined) throw "Failed to parse JSON."' \
		-e 'argv.forEach(key => { out = (Array.isArray(out) ? (/^-?\d+$/.test(key) ? (key = +key, out[key < 0 ? (out.length + key) : key]) : (key === "=" ? out.length : undefined)) :' \
		-e '(out instanceof Object ? out[key] : undefined)); if (out === undefined) throw "Failed to retrieve key/index: " + key }); return (out instanceof Object ? JSON.stringify(' \
		-e 'out, null, 2) : out) }' -- "$@" 2>&1 >&3)"; } 3>&1; [ "${1##* }" != '(-2700)' ] || { set -- "json_value ERROR${1#*Error}"; >&2 printf '%s\n' "${1% *}"; false; }
}

# USAGE: json_value [individual key path arguments] [JSON string or FILE PATH (or STDIN)]
# Copyright (c) 2023 Pico Mitchell - MIT License
# https://randomapplications.com/json_value

# JSON input can be passed as the FIRST or LAST argument or STDIN and can be either a JSON string or file path.
# Tested to work with up to 2GB file and 1GB string via STDIN, but when passing JSON string as the first or last argument,
# it is limited by ARG_MAX which is about 256KB on macOS 10.15 Catalina and older and about 1MB on macOS 11 Big Sur and newer.

# Each remaining argument is retrieved as a KEY or INDEX starting from the parsed JSON object and then retrieved recursively
# from the result of retrieving the previous KEY or INDEX argument (like piping the output of one command to the input of another).
# These arguments collectively form a "key path" but DO NOT use dot or bracket notation, instead EACH KEY OR INDEX IS ITS OWN ARGUMENT.

# NOTE: Because the JSON input and each key or index are all passed as arguments (or STDIN) to the JXA code instead of being placed directly in the code,
# none of them can be interpreted as code which means NO ARBITRARY CODE EXECUTION IS POSSIBLE AND NO SPECIAL CHARACTERS NEED TO BE ESCAPED.
# Some of the techniques used in this code were originally inspired by Paul Galow and Nathan Henrie:
# https://paulgalow.com/how-to-work-with-json-api-data-in-macos-shell-scripts
# https://twitter.com/n8henrie/status/1529513429203300352

# EXAMPLES (WHICH ARE ALL EQUIVALENT):
	# JSON First: json_value '{"topLevelKey":[{"keyOfDictInArray":42}]}' 'topLevelKey' '0' 'keyOfDictInArray'
	# JSON Last: json_value 'topLevelKey' '0' 'keyOfDictInArray' '{"topLevelKey":[{"keyOfDictInArray":42}]}'
	# STDIN JSON: echo '{"topLevelKey":[{"keyOfDictInArray":42}]}' | json_value 'topLevelKey' '0' 'keyOfDictInArray'
	# NOTE: The JSON string could also be a path to a JSON file in all 3 of the above examples.
# SAME OUTPUT FOR ALL EXAMPLES: 42

# NOTE: While the primary goal of this function is to be incredibly simple and easy to use, which mean intentionally NOT having
# complicated output manipulation and querying features, there are 2 convenience features added when dealing with array values.

# ARRAY CONVENIENCE FEATURE 1: NEGATIVE ARRAY INDEXES
	# In any place that you are accessing an array index, you can use negative numbers to count back from the last item in the array.
	# EXAMPLE: json_value '{"someArray":["A","B","C","D"]}' 'someArray' '-1'
	# OUTPUT: D
# ARRAY CONVENIENCE FEATURE 2: GET COUNT (LENGTH) OF AN ARRAY
	# To get the count (aka length) of an array value, specify '=' as the last argument in your key path.
	# EXAMPLE: json_value '{"someArray":["A","B","C","D"]}' 'someArray' '='
	# OUTPUT: 4


# Disable ShellCheck warning that functions with the same name are defined below since only the one above is what we want to run if this script is executed directly (the simpler variants are explained below).
# shellcheck disable=SC2218
json_value "$@"

exit "$?" # Exit explicitly with the exit code from "json_value" if this file is executed directly so that the exit code is not lost by the simpler variant functions below being loaded by the shell.


# NOTES ABOUT CODE COMPLEXITY AND SIMPLER VARIANTS:

# While the code in the function above may seem complex for such a simple task, the bulk of the code complexity is to allow for flexibility in how the JSON
# can be passed as either the first or last argument or as stdin as well as error handling and being able to read a JSON file rather than only JSON strings.
# Below are examples of progressively simpler and simpler variants of the same basic concept with fewer and fewer JSON input options, etc.

# If you would like to use one of these simpler variants in your script, just copy out the desired function below instead of using the most flexible variant above.
# All variants below included the basic functionality to accept multiple key/index arguments.

# NOTE: Disabling the ShellCheck warning "SC2317" does NOT need to be retained in your code, and is done below because this script exits
# explicitly above (explained above) which makes ShellCheck correctly detect that the simpler variant functions below are unreachable.

# Also, all of the simpler variants below only allow the JSON to be passed as the last argument.
# If you would prefer to pass JSON as the first argument instead, you can simply change "argv.pop()" to "argv.shift()" in any of the functions below.


# WITH FILE READING, NEGATIVE ARRAY INDEXES AND ARRAY COUNTS, ERROR HANDLING, AND JSON OUTPUT FOR OBJECTS, BUT NO STDIN, AND JSON ONLY AS LAST ARGUMENT:
# shellcheck disable=SC2317

json_value() { # Version 2023.3.4-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_value
	{ set -- "$(/usr/bin/osascript -l 'JavaScript' -e 'function run(argv) { let out = argv.pop(); if ($.NSFileManager.defaultManager.fileExistsAtPath(out))' \
		-e 'out = $.NSString.stringWithContentsOfFileEncodingError(out, $.NSUTF8StringEncoding, ObjC.wrap()).js; if (/[{[]/.test(out)) out = JSON.parse(out)' \
		-e 'argv.forEach(key => { out = (Array.isArray(out) ? (/^-?\d+$/.test(key) ? (key = +key, out[key < 0 ? (out.length + key) : key]) : (key === "=" ?' \
		-e 'out.length : undefined)) : (out instanceof Object ? out[key] : undefined)); if (out === undefined) throw "Failed to retrieve key/index: " + key })' \
		-e 'return (out instanceof Object ? JSON.stringify(out, null, 2) : out) }' -- "$@" 2>&1 >&3)"; } 3>&1
	[ "${1##* }" != '(-2700)' ] || { set -- "json_value ERROR${1#*Error}"; >&2 printf '%s\n' "${1% *}"; false; }
}


# WITH NEGATIVE ARRAY INDEXES AND ARRAY COUNTS, ERROR HANDLING, AND JSON OUTPUT FOR OBJECTS, BUT NO FILE READING, NO STDIN, AND JSON ONLY AS LAST ARGUMENT:
# shellcheck disable=SC2317

json_value() { # Version 2023.3.4-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_value
	{ set -- "$(/usr/bin/osascript -l 'JavaScript' -e 'function run(argv) { let out = argv.pop(); if (/[{[]/.test(out)) out = JSON.parse(out)' \
		-e 'argv.forEach(key => { out = (Array.isArray(out) ? (/^-?\d+$/.test(key) ? (key = +key, out[key < 0 ? (out.length + key) : key]) : (key === "=" ?' \
		-e 'out.length : undefined)) : (out instanceof Object ? out[key] : undefined)); if (out === undefined) throw "Failed to retrieve key/index: " + key })' \
		-e 'return (out instanceof Object ? JSON.stringify(out, null, 2) : out) }' -- "$@" 2>&1 >&3)"; } 3>&1
	[ "${1##* }" != '(-2700)' ] || { set -- "json_value ERROR${1#*Error}"; >&2 printf '%s\n' "${1% *}"; false; }
}


# WITH ERROR HANDLING, AND JSON OUTPUT FOR OBJECTS, BUT NO NEGATIVE ARRAY INDEXES NOR ARRAY COUNTS, NO FILE READING, NO STDIN, AND JSON ONLY AS LAST ARGUMENT:
# shellcheck disable=SC2317

json_value() { # Version 2023.3.4-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_value
	{ set -- "$(/usr/bin/osascript -l 'JavaScript' -e 'function run(argv) { let out = argv.pop(); if (/[{[]/.test(out))' \
		-e 'out = JSON.parse(out); argv.forEach(key => { out = (out instanceof Object ? out[key] : undefined); if (out === undefined)' \
		-e 'throw "Failed to retrieve key/index: " + key }); return (out instanceof Object ? JSON.stringify(out, null, 2) : out) }' \
		-- "$@" 2>&1 >&3)"; } 3>&1; [ "${1##* }" != '(-2700)' ] || { set -- "json_value ERROR${1#*Error}"; >&2 printf '%s\n' "${1% *}"; false; }
}


# WITH JSON OUTPUT FOR OBJECTS, BUT NO ERROR HANDLING, NO NEGATIVE ARRAY INDEXES NOR ARRAY COUNTS, NO FILE READING, NO STDIN, AND JSON ONLY AS LAST ARGUMENT:
# shellcheck disable=SC2317

json_value() { # Version 2023.3.4-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_value
	/usr/bin/osascript -l 'JavaScript' -e 'function run(argv) {' \
		-e 'let out = JSON.parse(argv.pop()); argv.forEach(key => out = out[key])' \
		-e 'return (out instanceof Object ? JSON.stringify(out, null, 2) : out) }' -- "$@"
}


# NO JSON OUTPUT FOR OBJECTS, NO ERROR HANDLING, NO NEGATIVE ARRAY INDEXES NOR ARRAY COUNTS, NO FILE READING, NO STDIN, AND JSON ONLY AS LAST ARGUMENT:
# shellcheck disable=SC2317

json_value() { # Version 2023.3.4-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_value
	/usr/bin/osascript -l 'JavaScript' -e 'function run(argv) { let out = JSON.parse(argv.pop()); argv.forEach(key => out = out[key]); return out }' -- "$@"
}
