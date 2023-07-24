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
# When integrating into a scripts, the help info at the top can be omitted so it's only a 15 line function, but the comment with the version and copyright should be retained.

# The following "json_extract" function is best for doing pretty advanced (or quite simple) extractions from JSON structures,
# if all you need is very simple capabilites, check out https://randomapplications.com/json_value instead.

json_extract() { # Version 2023.7.24-1 - Copyright (c) 2023 Pico Mitchell - MIT License - Full license and help info at https://randomapplications.com/json_extract
	if [ "$#" -eq 0 ] && [ -t 0 ]; then
		/usr/bin/less -F << 'JSON_EXTRACT_HELP_EOF'
json_extract: Version 2023.7.24-1
Copyright (c) 2023 Pico Mitchell - MIT License
https://randomapplications.com/json_extract

USAGE: json_extract [-i input (or STDIN)] [operation options] [output options]

NOTE: To view this help info, run "json_extract" with no input or options.


INPUT OPTIONS:

NOTE: Since the JSON input (and each key or index) are all passed as arguments (or STDIN) instead of being placed directly in the code,
no input will be interpreted as code which means NO ARBITRARY CODE EXECUTION IS POSSIBLE AND NO SPECIAL CHARACTERS NEED TO BE ESCAPED.

-i  < JSON string or FILE PATH >
    Omit this option or specify "-" to read from STDIN.
    Tested to be able to read up to 2GB file and 1GB string via STDIN, but when passing JSON string as an "-i" argument,
    it is limited by ARG_MAX which is about 256KB on macOS 10.15 Catalina and older and about 1MB on macOS 11 Big Sur and newer.


OPERATION OPTIONS:

NOTE: When multiple operations are specified, they are performed sequentially in the specified order with the next operation
being performed on the result of the previous one (like piping the output of one command to the input of another).
Also, options can be grouped together, for example "-fsu" is equivalent to "-f -s -u".
If you include an option that takes a parameter (such as "-i" or "-e"), it must be the last option in the group, for example "-fe 1" is equivalent to "-f -e 1".
Options and their parameters can be separated by whitespace, equals, or combined without using a separator, for example "-e1", "-e=1", and "-e 1" are all equivalent.

-e  < KEY or INDEX >
    EXTRACT VALUE for KEY or INDEX from dictionary or array (negative indexes are supported for arrays to easily extract the last value or any value starting from the end).
    This option only extracts a SINGLE KEY or INDEX at a time, it IS NOT used for a key path using dot or bracket notation.
    Instead, use multiple "-e" options sequentially for each individual key or index which together are equivalent to a key path.
    For example, a key path of "thisKey.thatKey[2]" would be equivalent to "-e thisKey -e thatKey -e 2".
    This means that there are no special characters that need to be escaped in any specified key, you can retrieve keys that contain literal dots or brackets without needing to escape anything.
      EXAMPLE: json_extract -i '{"topKey":[{"keyOfDictInArray":42}]}' -e 'topKey' -e '0' -e 'keyOfDictInArray'
        OUTPUT: 42

-E  < KEY or INDEX >
    EXTRACT VALUES for KEY or INDEX from within ALL elements of an ARRAY of DICTIONARIES or an ARRAY of ARRAYS.
    This type of "array of dictionaries" or "array of arrays" structure is common when dealing with a set of records, such as for users or equipment, etc.
    When using this option, the length of the output array will always be equal to the length of the orignal array.
    If the specified key or index does not exist in some dictionary or array element or if an element is not an a dictionary or array, a "null" value will be put in its place.
    That means that unlike "-e", this option will never error if you specify a key or index that does not exist.
      EXAMPLE A: json_extract -i '[{"keyA":"value1"},{"keyA":"value2"},{"keyA":"value3"}]' -E 'keyA'
        OUTPUT (but as a formatted JSON string): ["value1","value2","value3"]
      EXAMPLE B: json_extract -i '[["valueA0","valueA1"],["valueB0"],["valueC0","valueC1"]]' -E '1'
        OUTPUT (but as a formatted JSON string): ["valueA1",null,"valueC1"]

-N  Remove NULL ELEMENTS from ARRAY value.
    This option can be useful to use after "-E" which may leave unwanted "null" values in an array from nested dictionaries or arrays that didn't have the specified key or index.
      EXAMPLE A: json_extract -i '["string",null,true,null,42,null,false,null,23,null]' -N
        OUTPUT (but as a formatted JSON string): ["string",true,42,false,23]
      EXAMPLE B (after "-E" argument output includes "null" values): json_extract -i '[["valueA0","valueA1"],["valueB0"],["valueC0","valueC1"]]' -E '1' -N
        OUTPUT (but as a formatted JSON string): ["valueA1","valueC1"]

-S  STRIP off any top level DICTIONARIES that only contain one key and any ARRAYS with only one value leaving the previously nested value as the new top level.
    In other words, this extracts the shallowest dictionary or array with more than one value, or the deepest individual value if all dictionaries and arrays have only one value.
      EXAMPLE: json_extract -i '{"topKey":{"nestedKey":[["A","B","C"]]}}' -S
        OUTPUT (but as a formatted JSON string): ["A","B","C"]
      EXAMPLE (grouped with "-i" argument): json_extract -Si '{"topKey":[{"keyOfDictInArray":42}]}'
        OUTPUT: 42

-f  FLATTEN ARRAY of nested ARRAYS to a single layer array.
    NOTE: This option is only available on macOS 10.14 Mojave or newer (which supports JavaScript ES2019).
    For more information, see: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/flat
      EXAMPLE: json_extract -i '["B",["A","E"],"F",["G",["C",["E","D","B"],"H"],"A"]]' -f
        OUTPUT (but as a formatted JSON string): ["B","A","E","F","G","C","E","D","B","H","A"]

-s  SORT ELEMENTS of ARRAY value.
    NOTE: Elements will be sorted as strings in the current locale (using "localeCompare" https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort#sorting_non-ascii_characters).
    Any dictionary or array elements will also be sorted strings using their JSON string representations (and sorting very large data structures could be time consuming).
      EXAMPLE A: json_extract -i '["Kale","broccoli","Cauliflower","tomato","cabbage"]' -s
        OUTPUT (but as a formatted JSON string): ["broccoli","cabbage","Cauliflower","Kale","tomato"]
      EXAMPLE B: json_extract -i '[1,30,4,21,100000]' -s
        OUTPUT (but as a formatted JSON string): [1,100000,21,30,4]
      EXAMPLE C (grouped with "-f" argument): json_extract -i '["B",["A","E"],"F",["G",["C",["E","D","B"],"H"],"A"]]' -fs
        OUTPUT (but as a formatted JSON string): ["A","A","B","B","C","D","E","E","F","G","H"]

-u  UNIQUE ELEMENTS of ARRAY value.
    NOTE: This only removes duplicate individual values (such as strings and integers), but duplicate nested dictionaries or arrays will be left in the array (and removing duplicates from very large arrays could be time consuming).
      EXAMPLE A: json_extract -i '["this","that","other",true,false,null,23,42,42,23,null,false,true,"other","that","this"]' -u
          OUTPUT (but as a formatted JSON string): ["this","that","other",true,false,null,23,42]
      EXAMPLE B (grouped with "-f" and "-s" arguments): json_extract -i '["B",["A","E"],"F",["G",["C",["E","D","B"],"H"],"A"]]' -fsu
          OUTPUT (but as a formatted JSON string): ["A","B","C","D","E","F","G","H"]

-k  KEYS of DICTIONARY or ARRAY value as an array.
    NOTE: When outputting array keys, an array of indexes is outputted.
      EXAMPLE: json_extract -i '{"key1":"value1","key2":"value2","key3":"value3"}' -k
        OUTPUT (but as a formatted JSON string): ["key1","key2","key3"]

-v  VALUES of DICTIONARY or ARRAY value as an array.
    NOTE: When outputting array values, the same input array is outputted.
      EXAMPLE: json_extract -i '{"key1":"value1","key2":"value2","key3":"value3"}' -v
        OUTPUT (but as a formatted JSON string): ["value1","value2","value3"]

-c  COUNT of DICTIONARY or ARRAY value as an integer.
    NOTE: The count of a dictionary will be the count of its keys.
      EXAMPLE: json_extract -i '["A","B","C"]' -c
        OUTPUT: 3
      EXAMPLE (grouped with "-i" argument): json_extract -ci '{"key1":"value1","key2":"value2"}'
        OUTPUT: 2


OUTPUT OPTIONS:

NOTE: Do not specify any output option to output dictionary or array values as JSON or individual values as raw strings.
Tested to be able to output up to 1GB of JSON, trying to output more may error and not output anything.
When outputting dictionary or array values (NOT using either the "-l" or "-0" option), they will be outputted as a formatted multi-line JSON string (indenting 2 spaces per level).
When "-l" or "-0" is specified for some array value, any nested dictionary or array values will be represented as an unformatted single line JSON string (rather than a formatted JSON string).
All individual values are always represented as their raw string values, including boolean or null values which will be represented as the literal strings "true", "false", or "null".
Unlike the operation options, the order of these options does not matter, but if both "-l" and "-0" are specified, "-0" will take precedence and if both "-t" and "-T" are specified, "-T" will take precedence.

-l  Output elements of an ARRAY value as strings separated by NEWLINES (\n) instead of as a JSON string.
    If the final output value is not an array, this option is ignored without error.
    This option can be useful for clean output for display, or for convenient looping in the shell when values won't have line breaks.

-0  Output elements of an ARRAY value as strings separated by NULL CHARACTERS (\0) instead of as a JSON string.
    Using this option will also print a terminating/trailing NULL character.
    If the final output value is not an array, specifying this option will still print a terminating/trailing NULL character instead of a newline character.
    This option is useful for looping in the shell even if values could have line breaks.

-t  TRIM whitespace (spaces, tabs, newlines, etc) from the beginning and end of individual output values (ignored for dictionary and array values).
    When this option is specified along with "-l" or "-0", whitespace will also be trimmed from each individual value being listed.

-T  TRIM whitespace from beginning and end AND ALSO replace each internal sequence of whitespace with only single spaces (ignored for dictionary and array values).
    This is similar to piping the output to "tr -s '[:space:]' ' '" but will not ever leave a single space at the beginning or end since it also trims whitespace.
    When this option is specified along with "-l" or "-0", whitespace will also be trimmed and sequential whitespace replaced with single spaces for each individual value being listed.
JSON_EXTRACT_HELP_EOF

		return 0
	fi

	{ set -- "$(/usr/bin/osascript -l JavaScript -e 'ObjC.import("unistd");var run=argv=>{const args=[];let p;argv.forEach(a=>{if(!p&&/^-[^-]/.test(a)){a=a.split("").slice(1);for(const i in a){args.push("-"+a[i' \
	-e ']);if(/[ieE]/.test(a[i])){a.length>+i+1?args.push(a.splice(+i+(a[+i+1]==="="?2:1)).join("")):p=1;break}}}else{args.push(a);p=0}});let o,lA;for(const i in args){if(args[i]==="-i"&&!/^-[eE]$/.test(lA)){o=' \
	-e 'args.splice(+i,2)[1];break}lA=args[i]}const fH=$.NSFileHandle,hWS="fileHandleWithStandard",rtS="respondsToSelector";if(!o||o==="-"){const rdEOF="readDataToEndOfFile",aRE="AndReturnError";const h=fH[hWS+' \
	-e '"Input"];o=$.isatty(0)?"":$.NSString.alloc.initWithDataEncoding(h[rtS](rdEOF+aRE+":")?h[rdEOF+aRE](ObjC.wrap()):h[rdEOF],4).js.replace(/\n$/,"")}if($.NSFileManager.defaultManager.fileExistsAtPath(o))o=$' \
	-e '.NSString.stringWithContentsOfFileEncodingError(o,4,ObjC.wrap()).js;if(/^\s*[{[]/.test(o))o=JSON.parse(o);let e,eE,oL,o0,oT,oTS;const strOf=(O,N)=>typeof O==="object"?JSON.stringify(O,null,N):(O=O["to"+' \
	-e '"String"](),oT&&(O=O.trim()),oTS&&(O=O.replace(/\s+/g," ")),O),ext=(O,K)=>Array.isArray(O)?/^-?\d+$/.test(K)?(K=+K,O[K<0?O.length+K:K]):void 0:O instanceof Object?O[K]:void 0,ar="array",dc="dictionary"' \
	-e ',iv="Invalid option",naV="non-"+ar+" value";if(o||args.length){args.forEach(a=>{const isA=Array.isArray(o);if(e){o=ext(o,a);if(o===void 0)throw(isA?"Index":"Key")+" not found in "+(isA?ar:dc)+": "+a;e=' \
	-e '0}else if(eE){o=o.map(E=>(E=ext(E,a),E===void 0?null:E));eE=0}else if(a==="-l")oL=1;else if(a==="-0")o0=1;else if(a==="-t")oT=1;else if(a==="-T")oT=oTS=1;else{const isO=o instanceof Object;if(isO&&a===' \
	-e '"-e")e=1;else if(isA&&a==="-E")eE=1;else if(isA&&a==="-N")o=o.filter(E=>E!==null);else if(isO&&a==="-S")while(o instanceof Object&&Object.keys(o).length===1)o=o[Object.keys(o)[0]];else if(isA&&a==="-f"' \
	-e '&&typeof o.flat==="function")o=o.flat(Infinity);else if(isA&&a==="-s")o.sort((X,Y)=>strOf(X).localeCompare(strOf(Y)));else if(isA&&a==="-u")o=o.filter((E,I,A)=>A.indexOf(E)===I);else if(isO&&/^-[ckv]$/.' \
	-e 'test(a))o=a==="-c"?Object.keys(o).length:a==="-k"?Object.keys(o):Object.values(o);else if(/^-[eSckv]$/.test(a))throw iv+" for non-"+dc+" or "+naV+": "+a;else if(/^-[ENfsu]$/.test(a))throw iv+" for "+naV' \
	-e '+": "+a;else throw iv+": "+a}});const d=o0?"\0":"\n";o=((oL||o0)&&Array.isArray(o)?o.map(E=>strOf(E)).join(d):strOf(o,2))+d}o=ObjC.wrap(o).dataUsingEncoding(4);const h=fH[hWS+"Output"],wD="writeData";h[' \
	-e 'rtS](wD+":error:")?h[wD+"Error"](o,ObjC.wrap()):h[wD](o)}' -- "$@" 2>&1 >&3)"; } 3>&1; [ "${1##* }" != '(-2700)' ] || { set -- "json_extract ERROR${1#*Error}"; >&2 printf '%s\n' "${1% *}"; false; }
}

json_extract "$@"


# SOME ADVANCES EXAMPLES THAT COMBINE MULTIPLE OPTIONS IN POWERFUL WAYS (SEE HELP INFO FOR EXPLANATION OF EACH OPTION ALONG WITH SIMPLE EXAMPLES):

# List all unique device names from the entire IPSW.me API firmware listing (see https://api.ipsw.me/v3/firmwares.json for raw structure):
# curl -sfL 'https://api.ipsw.me/v3/firmwares.json/condensed' | json_extract -e 'devices' -v -E 'name' -u -s -l

# List all unique download URLs from the entire IPSW.me API firmware listing (see https://api.ipsw.me/v3/firmwares.json for raw structure):
# curl -sfL 'https://api.ipsw.me/v3/firmwares.json/condensed' | json_extract -e 'devices' -v -E 'firmwares' -E '0' -E 'url' -u -l

# List the name of every currently detected Wi-Fi network:
# system_profiler -json 'SPAirPortDataType' | json_extract -Se 'spairport_airport_interfaces' -E 'spairport_airport_other_local_wireless_networks' -NfE '_name' -ul

# List every SATA or NVMe drive model name:
# system_profiler -json 'SPNVMeDataType' 'SPSerialATADataType' | json_extract -vfE '_items' -fE 'device_model' -Tl

# List every connected screen name:
# system_profiler -json 'SPDisplaysDataType' | json_extract -e 'SPDisplaysDataType' -E 'spdisplays_ndrvs' -fNE '_name' -l

# List every (primary) account name on this system:
# dscl -plist . -readall /Users RecordName | plutil -convert json -o - - | json_extract -E 'dsAttrTypeStandard:RecordName' -E '0' -l
