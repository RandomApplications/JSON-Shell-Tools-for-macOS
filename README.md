# JSON Shell Tools for macOS

Both [**`json_extract`**](https://randomapplications.com/json_extract) and [**`json_value`**](https://randomapplications.com/json_value) utilize [JavaScript for Automation (JXA)](https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/Introduction.html) (via `osascript -l JavaScript`) to parse JSON, so no external dependencies are required and both are fully compatible with all `sh`, `bash`, and `zsh` scripts. They can both be integrated into your own scripts by simply copy-and-pasting the functions into your code, or the script files can executed directly on the command line. Both `json_extract` and `json_value` are tested to be compatible with macOS 10.13 High Sierra and newer (but the `-f` option in `json_extract` is only available on macOS 10.14 Mojave and newer).

## `json_extract`

[**`json_extract`**](https://randomapplications.com/json_extract) is designed to make it easy to do pretty advanced (or quite simple) extractions from JSON structures in a very shell-friendly way. No JavaScript notation or special JSON querying knowledge or syntax is needed. All values can be retrieved using simple command line options with no complicated syntax or special characters.

Each capability of `json_extract` is provided through simple command line options to be able to do things like get all keys of a dictionary using `-k` or all values using `-v` as well as the count/length of a dictionary or array using `-c`. More advanced abilities are also very easy with options for sorting arrays (`-s`), getting unique elements of arrays (`-u`), outputting array contents as lines (`-l`) or NUL (`-0`) separated values, as well as even more interesting advanced capabilities that you can read about and see examples of in the help/usage information in [**`json_extract.sh`**](https://randomapplications.com/json_extract).

If you want to integrate the `json_extract` function into your own scripts, all this powerful functionality only takes up 15 lines! *(When the help information is not included.)*

## `json_value`

[**`json_value`**](https://randomapplications.com/json_value) is designed just to do direct/simple value retrievals from JSON structures in a very shell-friendly way. No JavaScript notation or special JSON querying knowledge or syntax is needed. All values can be retrieved without even needing any command line options, you simply pass the path of keys/indexes that you want to retrieve as individual arguments.

While `json_value` is made to be extremely simple and minimal (without many of the advanced capabilities of `json_extract`), it can still accept both JSON strings or files from *stdin* or as the first or last argument. There are also 2 extra convenience features for arrays, the first is that values can be retrieve from the end of the array using negative indexes and the next is that the count of an array can be retrieved by passing `=` as an argument instead of an index number.

If you want to integrate the `json_value` function into your own scripts, it only takes up 10 lines! Also, there are 5 other variants provided which go down to as few as 3 lines with progressively less and less functionality (such as without reading *stdin*, without reading files, and without the extra array convenience features) if you want a smaller function with only the functionality you need in your script. For more information and examples, see the help/usage information in [**`json_value.sh`**](https://randomapplications.com/json_value). *(Some of the techniques used within `json_value` were originally inspired by [Paul Galow](https://paulgalow.com/how-to-work-with-json-api-data-in-macos-shell-scripts) and [Nathan Henrie](https://twitter.com/n8henrie/status/1529513429203300352).)*


## About JXA Source Files

The formatted JXA source code for `json_extract` and `json_value` without their shell function wrappers are both available at [**`json_extract.jxa`**](https://github.com/RandomApplications/JSON-Shell-Tools-for-macOS/blob/main/JXA%20Source%20Files/json_extract.jxa) and [**`json_value.jxa`**](https://github.com/RandomApplications/JSON-Shell-Tools-for-macOS/blob/main/JXA%20Source%20Files/json_value.jxa). These files *could* be run directly, but are primarily provided as a reference to read the code with the whitespace formatting retained **and are *not recommened* to run directly** since they do not handle errors as nicely as [**`json_extract.sh`**](https://randomapplications.com/json_extract) and [**`json_value.sh`**](https://randomapplications.com/json_value) with the shell function wrappers.
