<p align="center">
    <img src="https://www.hackingwithswift.com/img/brisk/logo.png" alt="Brisk logo" width="413" maxHeight="83" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.1-brightgreen.svg" />
    <img src="https://img.shields.io/badge/macOS-10.15-blue.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-lightgrey.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

Brisk is a *proof of concept* scripting library for Swift developers. It keeps all the features we like about Swift, but provides wrappers around common functionality to make them more convenient for local scripting.

Do you see that 💥 right there next to the logo? That’s there for a reason: Brisk bypasses some of Swift’s built-in safety features to make it behave more like Python or Ruby, which means it’s awesome for quick scripts but a really, really bad idea to use in shipping apps.

This means you get:

1. All of Swift’s type safety
2. All of Swift’s functionality (protocols, extensions, etc)
3. All of Swift’s performance

But:

1. Many calls that use `try` are assumed to work – if they don’t, your code will print a message and either continue or halt depending on your setting.
2. You get many helper functions that make common scripting functionality easier: reading and writing files, parsing JSON and XML, string manipulation, regular expressions, and more.
3. Network fetches are synchronous.
4. Strings can be indexed using integers, and you can add, subtract, multiply, and divide `Int`, `Double`, and `CGFloat` freely. So `someStr[3]` and `someInt + someDouble` works as in scripting languages. (Again, please don’t use this in production code.)
5. We assume many sensible defaults: you want to write strings with UTF-8, you want to create directories with intermediates, `trim()` should remove whitespace unless asked otherwise, and so on.

We don’t replace any of Swift’s default functionality, which means if you want to mix Brisk’s scripting wrappers with the full Foundation APIs (or Apple’s other frameworks), you can.

So, it’s called Brisk: it’s fast like Swift, but with that little element of risk 🙂


## Installation

Run these two commands: 

```
git clone https://github.com/twostraws/Brisk
cd Brisk
make install
```

Brisk installs a template full of its helper functions in `~/.brisk`, plus a simple helper script in `/usr/local/bin`.

Usage:

```
brisk myscriptname
```

That will create a new directory called `myscriptname`, copy in all the helper functions, then open it in Xcode ready for you to edit. Using Xcode means you get full code completion, and can run your script by pressing Cmd+R like usual.

**Warning:** The `brisk` command is easily the most experimental part of this whole package, so please let me know how you get on with it. Ideally it should create open Xcode straight to an editing window saying `print("Hello, Brisk!")`, but let me know if you get something else.


## Examples

This creates a directory, changes into it, copies in an example JSON file, parses it into a string array, then saves the number of items in a new file called output.txt:

```swift
mkdir("example")
chdir("example")
fileCopy("~/example.json", to: ".")

let names = decode(file: "example.json", as: [String].self)
let output = "Result \(names.count)"
output.write(to: "output.txt")
```

If you were writing this using the regular Foundation APIs, your code might look something like this:

```swift
let fm = FileManager.default
try fm.createDirectory(atPath: "example", withIntermediateDirectories: true)
fm.changeCurrentDirectoryPath("example")
try fm.copyItem(atPath: NSHomeDirectory() + "/example.json", toPath: "example")

let input = try String(contentsOfFile: "example.json")
let data = Data(input.utf8)
let names = try JSONDecoder().decode([String].self, from: data)
let output = "Result \(names.count)"
try output.write(toFile: "output.txt", atomically: true, encoding: .utf8)
```

The Foundation code has lots of throwing functions, which is why we need to repeat the use of `try`. This is really important when shipping production software because it forces us to handle errors gracefully, but in simple scripts where you know the structure of your code, it gets in the way.

This example finds all .txt files in a directory and its subdirectories, counting how many lines there are in total:

```swift
var totalLines = 0

for file in scandir("~/Input", recursively: true) {
    guard file.hasSuffix(".txt") else { continue }
    let contents = String(file: "~/Input"/file) ?? ""
    totalLines += contents.lines.count
}

print("Counted \(totalLines) lines")
```

Or using `recurse()`:

```swift
var totalLines = 0

recurse("~/Input", extensions: ".txt") { file in
    let contents = String(file: "~/Input"/file) ?? ""
    totalLines += contents.lines.count
}

print("Counted \(totalLines) lines")
```

And here’s the same thing using the Foundation APIs:

```swift
let enumerator = FileManager.default.enumerator(atPath: NSHomeDirectory() + "/Input")
let files = enumerator?.allObjects as! [String]
var totalLines = 0

for file in files {
    guard file.hasSuffix(".txt") else { continue }
    let contents = try! String(contentsOfFile: NSHomeDirectory() + "/Input/\(file)")
    totalLines += contents.components(separatedBy: .newlines).count
}

print("Counted \(totalLines) lines")
```

Here are some more examples – I’m not going to keep on showing you the Foundation equivalent, because you can imagine it for yourself.

This fetches the contents of Swift.org and checks whether it was changed since the script was last run:

```swift
let html = String(url: "https://www.swift.org")
let newHash = html.sha256()
let oldHash = String(file: "oldHash")
newHash.write(to: "oldHash")

if newHash != oldHash {
    print("Site changed!")
}
```

This creates an array of names, removes any duplicates, then writes the result out to a file as JSON:

```swift
let names = ["Ron", "Harry", "Ron", "Hermione", "Ron"]
let json = names.unique().jsonData()
json.write(to: "names.txt")
```

This checks whether a string matches a regular expression:

```swift
let example = "Hacking with Swift is a great site."

if example.matches(regex: "(great|awesome) site") {
    print("Trufax")
}
```

Loop through all files in a directory recursively, printing the name of each file and its string contents:

```swift
recurse("~/Input") { file in
    let text = String(file: "~/Input"/file) ?? ""
    print("\(file): \(text)")
}
```

Print whether a directory contains any zip files:

```swift
let contents = scandir("~/Input")
let hasZips = contents.any { $0.hasSuffix(".zip") }
print(hasZips)
```

This loads Apple’s latest newsroom RSS and prints out the titles of all the stories:

```swift
let data = Data(url: "https://apple.com/newsroom/rss-feed.rss")
if let node = parseXML(data) {
    let titles = node.getElementsByTagName("title")

    for title in titles {
        print(title.data)
    }
}
```


## Wait, but… why?

I was working on a general purpose scripting library for Swift, following fairly standard Swift conventions – you created a struct to represent the file you wanted to work with, for example.

And it worked – you could write scripts in Swift that were a little less cumbersome than Foundation. But it still wasn’t *nice*: you could achieve results, but it still felt like Python, Ruby, or any number of alternatives were better choices, and I was choosing Swift just because it was Swift.

So, Brisk is a pragmatic selection of wrappers around Foundation APIs, letting us get quick results for common operations, but still draw on the full power of the language and Apple’s frameworks. The result is a set of function calls, initializers, and extensions that make common things trivial, while allowing you to benefit from Swift’s power features and “gracefully upgrade” to the full fat Foundation APIs whenever you need.


## Naming conventions

This code has gone through so many iterations over time, because it’s fundamentally built on functions I’ve been using locally. However, as I worked towards an actual proof of concept I had to try to bring things together a cohesive way, which meant figuring out How to Name Things.

* When using long-time standard things from POSIX or C, those function names were preserved. So, `mkdir()`, `chdir()`, `getcwd()`, all exist.
* Where equivalent functions existed in other popular languages, they were imported: `isdir()`, `scandir()`, `recurse()`, `getpid()`, `basename()`, etc.
* Where functionality made for natural extensions of common Swift types – `String`, `Comparable`, `Date`, etc – extensions were always preferred.

The only really problematic names were things for common file operations, such as checking whether a file exists or reading the contents of a file. Originally I used short names such as `exists("someFile.txt")` and `copy("someFile", to: "dir")`, which made for concise and expressive code. However, as soon as you made a variable called `copy` – which is easily done! – you lose visibility to the function

I then moved to using `File.copy()`, `File.exists()` and more, giving the functions a clear namespace. That works great for avoiding name collisions, and also helps with discoverability, but became more cumbersome to read and write. So, after trying them both for a while I found that the current versions worked best: `fileDelete()`, and so on.

I’d be more than happy to continue exploring alternatives!



## Reference

This needs way more documentation, but hopefully this is enough to get you started.


### Extensions on Array

Removes all instances of an element from an array:

```swift
func remove(_: Element)
```

### Extensions on Comparable

Clamps any comparable value between a low and a high value, inclusive:

```swift
func Comparable.clamp(low: Self, high: Self) -> Self
```

### Extensions on Data

Calculates the hash value of this `Data` instance:

```swift
func Data.md5() -> String
func Data.sha1() -> String
func Data.sha256() -> String
```

Converts the `Data` instance to base 64 representation:

```swift
func Data.base64() -> String
```

Writes the `Data` instance to a file path; returns true on success or false otherwise:

```swift
func write(to file: String) -> Bool
```

Creates a `Data` instance by downloading from a URL or by reading a local file:

```swift
Data(url: String)
Data?(file: String)
```


### Extensions on Date

Reads a `Date` instance as an Unix epoch time integer:

```swift
func unixTime() -> Int
```

Formats a `Date` as a string:

```swift
func string(using format: String) -> String
```

### Decoding

Decodes a string to a specific `Decodable` type, optionally providing strategies for decoding keys and dates:

```swift
func decode<T: Decodable>(string input: String, as type: T.Type, keys: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dates: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> T
```

The same as above, except now loading from a local file:

```swift
func decode<T: Decodable>(file: String, as type: T.Type, keys: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dates: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> T
```

Creates a `Decodable` instance by fetching data a URL:

```swift
Decodable.init(url: String, keys: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dates: JSONDecoder.DateDecodingStrategy = .deferredToDate)
```


### Directories

The user’s home directory:

```swift
Directory.homeDir: String
```

Makes a directory:

```swift
@discardableResult func mkdir(_ directory: String, withIntermediates: Bool = true) -> Bool
```

Removes a directory:

```swift
@discardableResult func rmdir(_ file: String) -> Bool
func getcwd() -> String
```

Returns true if a file path represents a directory, or false otherwise:

```swift
func isdir(_ name: String) -> Bool
```

Changes the current working directory:

```swift
func chdir(_ newDirectory: String) -> Bool
```

Retrieves all files in a directory, either including all subdirectories or not:

```swift
func scandir(_ directory: String, recursively: Bool = false) -> [String]
```

Runs through all files in a directory, including subdirectories, and runs a closure for each file that matches an extension list:

```swift
func recurse(_ directory: String, extensions: String..., action: (String) throws -> Void) rethrows
```

Same as above, except now you can pass in a custom predicate:

```swift
func recurse(_ directory: String, predicate: (String) -> Bool, action: (String) throws -> Void) rethrows
```


### Extensions on Encodable

Converts any `Encodable` type to some JSON `Data`, optionally providing strategies for encoding keys and dates:

```swift
func Encodable.jsonData(keys: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dates: JSONEncoder.DateEncodingStrategy = .deferredToDate) -> Data
```

Same as above, except converts it a JSON `String`:

```swift
func Decodable.jsonString(keys: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dates: JSONEncoder.DateEncodingStrategy = .deferredToDate) -> String
```


### Files

Creates a file, optionally providing initial contents. Returns true on success or false otherwise:

```swift
@discardableResult func fileCreate(_ file: String, contents: Data? = nil) -> Bool
```

Removes a file at a path; returns true on success or false otherwise:

```swift
@discardableResult func fileDelete(_ file: String) -> Bool
```

Returns true if a file exists:

```swift
func fileExists(_ name: String) -> Bool
```

Returns all properties for a file:

```swift
func fileProperties(_ file: String) -> [FileAttributeKey: Any]
```

Returns the size of a file:

```swift
func fileSize(_ file: String) -> UInt64
```

Returns the date a file was created or modified:

```swift
func fileCreation(_ file: String) -> Date
func fileModified(_ file: String) -> Date
```

Returns a temporary filename:

```swift
func tempFile() -> String
```

Returns the base name of a file – the filename itself, excluding any directories:

```swift
func basename(of file: String) -> String
```

Copies a file from one place to another:

```swift
@discardableResult func fileCopy(_ from: String, to: String) -> Bool
```


### Numeric operators

A series of operator overloads that let you add, subtract, multiply, and divide across integers, floats, and doubles:

```swift
func +<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F
func +<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F
func -<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F
func -<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F
func *<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F
func *<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F
func /<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F
func /<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F
```


### Processes

Returns the current process ID:

```swift
func getpid() -> Int
```

Returns the host name:

```swift
func getHostName() -> String
```

Returns the username of the logged in user:

```swift
func getUserName() -> String
```

Gets or sets environment variables:

```swift
func getenv(_ key: String) -> String
func setenv(_ key: String, _ value: String)
```


### Extensions on Sequence

Returns any sequence, with duplicates removed. Element must conform to `Hashable`:

```swift
func Sequence.unique() -> [Element]
```

Returns all the indexes where an element exists in a sequence. Element must conform to `Equatable`:

```swift
func Sequence.indexes(of searchItem: Element) -> [Int]
```

Returns true if any or none of the items in a sequence match a predicate:

```swift
func any(match predicate: (Element) throws -> Bool) rethrows -> Bool
func none(match predicate: (Element) throws -> Bool) rethrows -> Bool
```

Returns several random numbers from a sequence, up to the number requested:

```swift
Sequence.random(_ num: Int) -> [Element]
```


### Extensions on String

The string as an array of lines:

```swift
var lines: [String]
```

An operator that lets us join strings together into a path:

```swift
static func / (lhs: String, rhs: String) -> String
```

Calculates the hash value of this `String` instance:

```swift
func md5() -> String
func sha1() -> String
func sha256() -> String
```

Converts the `String` instance to base 64 representation:

```swift
func base64() -> String
```

Writes a string to a file:

```swift
@discardableResult func write(to file: String) -> Bool
```

Replaces all instances of one string with another in the source `String`:

```swift
func replacing(_ search: String, with replacement: String) -> String
mutating func String.replace(_ search: String, with replacement: String)
```

Replaces `count` instances of one string with another in the source `String`:

```swift
func replacing(_ search: String, with replacement: String, count maxReplacements: Int) -> String
mutating func String.replace(_ search: String, with replacement: String, count maxReplacements: Int)
```

Trims characters from a string, whitespace by default:

```swift
mutating func trim(_ characters: String = " \t\n\r\0")
func String.trimmed(_ characters: String = " \t\n\r\0") -> String
```

Returns true if a string matches a regular expression, with optional extra options:

```swift
func matches(regex: String, options: NSRegularExpression.Options = []) -> Bool
```

Replaces matches for a regular expression with a replacement string:

```swift
replacing(regex: String, with replacement: String, options: NSString.CompareOptions) -> String
mutating func String.replace(regex: String, with replacement: String, options: NSString.CompareOptions)
```

Subscripts to let us read strings using integers and ranges:

```swift
subscript(idx: Int) -> String
subscript(range: Range<Int>) -> String
subscript(range: ClosedRange<Int>) -> String
subscript(range: CountablePartialRangeFrom<Int>) -> String
subscript(range: PartialRangeThrough<Int>) -> String
subscript(range: PartialRangeUpTo<Int>) -> String
```

Expands path components such as `.` and `~`:

```swift
expandingPath() -> String
```

Creates a `String` instance by downloading from a URL or by reading a local file:

```swift
String.init(url: String)
String.init?(file: String)
```

Removes a prefix or suffix from a string, if it exists:

```swift
deletingPrefix(_ prefix: String) -> String
deletingSuffix(_ suffix: String) -> String
```

Adds a prefix or suffix to a string, if it doesn’t already have it:

```swift
func String.withPrefix(_ prefix: String) -> String
func String.withSuffix(_ suffix: String) -> String
```


### System functionality

Many functions will print a message and return a default value if their functionality failed. Set this to true if you want your script to terminate on these problems:

```swift
static var Brisk.haltOnError: Bool
```

Prints a message, or terminates the script if `Brisk.haltOnError` is true:

```swift
func printOrDie(_ message: String)
```

Terminates the program, printing a message and returning an error code to the system:

```swift
func exit(_ message: String = "", code: Int = 0) -> Never
```

If Cocoa is available, this opens a file or folder using the correct app. This is helpful for showing the results of a script, because you can use `open(getcwd())`:

```swift
func open(_ thing: String)
```

### Extensions on URL

Add a string to a URL:

```swift
static func +(lhs: URL, rhs: String) -> URL
static func +=(lhs: inout URL, rhs: String)
```

### XML parsing

Parses an instance of `Data` or `String` into an XML, or loads a file and does the same:

```swift
func parseXML(_ data: Data) -> XML.XMLNode?
func parseXML(_ string: String) -> XML.XMLNode?
func parseXML(from file: String) -> XML.XMLNode?
```

The resulting `XMLNode` has the following properties:

- `tag`: The tag name used, e.g. `<h1>`.
- `data`: The text inside the tag, e.g. `<h1>This bit is the data</h1>`
- `attributes`: A dictionary containing the keys and values for all attributes.
- `childNodes`: an array of `XMLNode` that belong to this node.

It also has a tiny subset of minidom functionality to make querying possible.

This finds all elements by a tag name, looking through all children, grandchildren, and so on:

```swift
func getElementsByTagName(_ name: String) -> [XMLNode]
```

This returns true if the current node has a specific attribute, or false otherwise:

```swift
func hasAttribute(_ name: String) -> Bool
```

This reads a single attribute, or sends back an empty string otherwise:

```swift
func getAttribute(_ name: String) -> String
```


## Contribution guide

Any help you can offer with this project is most welcome – there are opportunities big and small so that someone with only a small amount of Swift experience can help.

Some suggestions you might want to explore, ordered by usefulness:

- Write some tests.
- Contribute example scripts.
- Add more helper functions.
 
 
## What now?

This is a proof of concept scripting library for Swift developers. I don’t think it’s perfect, but I do at least hope it gives you some things to think about.

Some tips:

1. If you already write scripts in Bash, Ruby, Python, PHP, JavaScript, etc, your muscle memory will always feel like it’s drawing you back there. That’s OK – learning anything new takes time.
2. Stay away from macOS protected directories, such as your Desktop, Documents, and Photos.
3. If you intend to keep scripts around for a long period of time, you can easily “upgrade” your code from Brisk’s helpers up to Foundation calls; nothing is overridden.
4. The code is open source. Even if you end up not using Brisk at all, you’re welcome to read the code, learn from it, take it for your own projects, and so on.
 

## Credits

Brisk was designed and built by Paul Hudson, and is copyright © Paul Hudson 2020. Brisk is licensed under the MIT license; for the full license please see the LICENSE file.

Swift, the Swift logo, and Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.

If you find Brisk useful, you might find my website full of Swift tutorials equally useful: [Hacking with Swift](https://www.hackingwithswift.com).
