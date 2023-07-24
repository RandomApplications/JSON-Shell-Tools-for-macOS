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

json_create() { # Version 2023.7.24-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_create
	/usr/bin/osascript -l 'JavaScript' -e 'ObjC.import("unistd"); function run(argv) { let stdin = $.NSFileHandle.fileHandleWithStandardInput, out = [], dictOut = false, stdinJson' \
	-e '= false, isValue = true, keyArg; if (!$.isatty(0)) { stdin = $.NSString.alloc.initWithDataEncoding((stdin.respondsToSelector("readDataToEndOfFileAndReturnError:") ? stdin.' \
	-e 'readDataToEndOfFileAndReturnError(ObjC.wrap()) : stdin.readDataToEndOfFile), $.NSUTF8StringEncoding).js; if (/^\s*[{[]/.test(stdin)) try { out = JSON.parse(stdin); dictOut' \
	-e '= !Array.isArray(out); stdinJson = true } catch (e) {} } if (argv[0] === "-d") { if (!stdinJson) { out = {}; dictOut = true } if (dictOut) argv.shift() } argv.forEach((arg' \
	-e ', index) => { if (dictOut) isValue = ((index % 2) !== 0); if (isValue) if (/^\s*[{[]/.test(arg)) try { arg = JSON.parse(arg) } catch (e) {} else ((/\d/.test(arg) && !isNaN' \
	-e '(arg)) ? arg = +arg : ((arg === "true") ? arg = true : ((arg === "false") ? arg = false : ((arg === "null") && (arg = null))))); (dictOut ? (isValue ? out[keyArg] = arg :' \
	-e 'keyArg = arg) : out.push(arg)) }); if (dictOut && !isValue && (keyArg !== void 0)) out[keyArg] = null; return JSON.stringify(out, null, 2) }' -- "$@"
}

# USAGE: json_create [-d] [individual arguments to set to elements of a JSON array or keys and values of a JSON dictionary]
# Copyright (c) 2023 Pico Mitchell - MIT License
# https://randomapplications.com/json_create

# By defaults, the arguments passed to "json_create" will be outputted as a JSON array.
# To output as a JSON dictionary include "-d" as the FIRST argument and then specify an even set of keys and values as arguments (see examples below).
# NOTE: If you do not pass an even set of key and value arguments when creating a dictionary, the final key will have its value set to "null" (see example below).

# If an argument value is a valid JSON dictionary or array string, the data structure will be preserved and nested within the ouput array or dictionary (see examples below).
# If an argument value is a number (integer or float), or is "true", "false", or "null", their native values will be used rather than string values (see examples below).
# All other argument values will be treated as strings (see examples below).
# NOTE: To create nested (multidimensional) data structures, use multiple "json_create" commands via command substitution (see examples below).

# "json_create" can also do SIMPLE modifications to existing JSON input passed via standard input (stdin).
# When a valid JSON array or dictionary string is passed via stdin, it will be used as the initial strucure and any argument values will be added to it.
# NOTE: If stdin IS NOT a valid JSON array or dictionary string, then it will be ignored with no error and the output will be created only from the specified arguments.

# When a JSON array is passed via stdin, all arguments will be ADDED TO THE END of the TOP LEVEL array (see example below). It IS NOT possible to modify existing array elements with by "json_create".
# NOTE: If "-d" is set as the first argument, but an JSON array was passed via stdin then "-d" WILL NOT be honored as a special argument and will be added to the array as a regular value.

# When a JSON dictionary is passed via stdin, all key and value arguments will be added to the TOP LEVEL of the dictionary (see example below).
# If a key already exists in the top level of the input dictionary, it will be overwitten with the newly specified value (see example below).
# It IS NOT possible to modify nested values within a complex input dictionary, only the TOP LEVEL can be modified by "json_create".
# NOTE: When a JSON dictionary is passed via stdin, it IS NOT NECESSARY to specify "-d" as the first argument since the output will always be a dictionary.


# CREATE JSON ARRAY EXAMPLE:
# json_create 'Some String Value' true false null 42

# JSON ARRAY OUTPUT:
# [
#   "Some String Value",
#   true,
#   false,
#   null,
#   42
# ]


# CREATE JSON DICTIONARY EXAMPLE:
# json_create -d 'key1' 'Some String Value' 'key2' true 'key3' false 'key4' null 'key5' 23

# JSON DICTIONARY OUTPUT:
# {
#   "key1": "Some String Value",
#   "key2": true,
#   "key3": false,
#   "key4": null,
#   "key5": 23
# }


# UNEVEN DICTIONARY EXAMPLE (THERE ARE NOT AN EVEN SET OF KEYS AND VALUES):
# json_create -d 'key1' 'Some String Value' 'key2'

# JSON DICTIONARY OUTPUT (FINAL KEY SET TO "null"):
# {
#   "key1": "Some String Value",
#   "key2": null
# }


# CREATE JSON ARRAY OF DICTIONARIES EXAMPLE:
# json_create "$(json_create -d 'nestedKeyA' 'Nested Value A1' 'nestedKeyB' 'Nested Value B1')" "$(json_create -d 'nestedKeyA' 'Nested Value A2' 'nestedKeyB' 'Nested Value B2')"

# JSON ARRAY OF DICTIONARIES OUTPUT:
# [
#   {
#     "nestedKeyA": "Nested Value A1",
#     "nestedKeyB": "Nested Value B1"
#   },
#   {
#     "nestedKeyA": "Nested Value A2",
#     "nestedKeyB": "Nested Value B2"
#   }
# ]


# CREATE JSON DICTIONARY OF ARRAY AND DICTIONARY EXAMPLE:
# json_create -d 'nestedArray' "$(json_create 'Some String Value' true false null 42)" 'nestedDicionary' "$(json_create -d 'key1' 'Some String Value' 'key2' true 'key3' false 'key4' null 'key5' 23)"

# JSON DICTIONARY OF ARRAY AND DICTIONARY OUTPUT:
# {
#   "nestedArray": [
#     "Some String Value",
#     true,
#     false,
#     null,
#     42
#   ],
#   "nestedDicionary": {
#     "key1": "Some String Value",
#     "key2": true,
#     "key3": false,
#     "key4": null,
#     "key5": 23
#   }
# }


# ADD ELEMENTS TO EXISTING JSON ARRAY PASSED VIA STDIN:
# echo '["Existing Value 1", "Existing Value 2"]' | json_create 'New Value A' 'New Value B'

# JSON ARRAY OUTPUT:
# [
#   "Existing Value 1",
#   "Existing Value 2",
#   "New Value A",
#   "New Value B"
# ]


# ADD/MODIFY KEYS OF EXISTING JSON DICTIONARY PASSED VIA STDIN (NOTICE "-d" AS FIRST ARGUMENT IS NOT NECESSARY WHEN A JSON DICTIONARY IS PASSED VIA STDIN):
# echo '{"existingKey1": "Existing Value A", "existingKey2": "Existing Value B"}' | json_create 'newKeyA' 'New Value A' 'existingKey2' 'New Value B'

# JSON DICTIONARY OUTPUT:
# {
#   "existingKey1": "Existing Value A",
#   "existingKey2": "New Value B",
#   "newKeyA": "New Value A"
# }


json_create "$@"
