# Common Lisp JSON Parser

Custom, dependency-free JSON parser and serializer written entirely in Common Lisp.

This project implements a recursive descent parser from scratch, providing a practical exploration of compiler theory concepts within a purely functional paradigm. It manually handles the entire pipeline: from character-level tokenization and cleaning, to recursive state tracking for balancing nested structures, and finally evaluating the tokenized input into native Lisp data types. The parsing logic relies heavily on pattern matching and recursive function calls rather than iterative loops, highlighting the strengths of Common Lisp for symbolic computation and low-level text processing.


## Key Features

- **Full JSON Parsing:** Parses stringified JSON objects (`{...}`) and arrays (`[...]`) into tagged Common Lisp lists (`jsonobj` and `jsonarray`).
- **Data Access API:** Provides a straightforward querying function to traverse nested JSON structures dynamically.
- **File I/O Operations:** Read JSON directly from files and serialize (dump) Lisp data structures back into formatted JSON files.
- **Pure Functional Approach:** Leverages heavy recursion, pattern matching, and list processing instead of imperative loops.

## Core API & Functions

Below is a synthesized overview of the main functions driving the parser, demonstrating the recursive descent approach used to evaluate tokens.

### Data Ingestion & Extraction
- `(jsonparse json-string)`: The main entry point. It cleans the input string, identifies whether the root is an object (`{}`) or an array (`[]`), and delegates to the appropriate recursive parser (`parsemembers` or `arrayparse`).
- `(jsonread filename)`: Reads a file character-by-character into a string and automatically passes it to `jsonparse`.
- `(jsondump jsonobj filename)`: Serializes a parsed Lisp JSON structure back into a valid JSON string and writes it out to the specified file.

### Querying Data
- `(jsonaccess obj &rest fields)`: A dynamic accessor function. Pass a parsed JSON object and a sequence of keys (strings for objects, integers for arrays) to traverse deep into nested structures and retrieve the target value.

### Internal Parsing Logic (Recursive Descent)
- `parsemembers` & `arrayparse`: The core recursive engines. They iterate through a list of tokens (characters), balancing open and closed brackets (`{`, `}`, `[`, `]`). When a complete inner structure or a comma is detected, they split the tokens and recursively evaluate the separated parts.
- `parsepair`: Expects a key-value format separated by a colon (`:`). It extracts the string key and defers the value evaluation to `parsevalue`.
- `parsevalue`: Determines the type of a value (nested object, nested array, string, or number) and returns the corresponding parsed Lisp primitive or recursively calls the object/array parsers.

### Tokenization & Cleaning
- Functions like `removespecialchars`, `processsubstrings`, and `processnumbers` work together to clean raw input by removing whitespace outside of strings, grouping characters enclosed in quotes into valid Lisp strings, and parsing numeric characters into integers or floats.

## Getting Started

### Prerequisites
You need a Common Lisp implementation installed on your system, such as **SBCL** (Steel Bank Common Lisp) or **CLISP**.

### Loading the Project

1. Clone the repository and navigate to the directory:
   ```bash
   git clone <your-repository-url>
   cd lisp-json-parser
   ```

2. Open your Lisp REPL (e.g., by typing `sbcl` in the terminal).

3. Load the source file:
   ```lisp
   * (load "jsonparse.lisp")
   ```

4. Try parsing a string:
   ```lisp
   * (jsonparse "{\"name\": \"John\", \"age\": 30}")
   ```
   *Expected Output: `(JSONOBJ ("name" "John") ("age" 30))`*


