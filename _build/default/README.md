# Markdown Parser

A lightweight Markdown-to-HTML converter written in OCaml.

## Features

- Headers (# ## ###)
- Bold (**text**) and italic (*text*) formatting
- Inline code (`code`)
- Unordered lists (- item)
- Proper paragraph spacing

## Usage

```bash
# Build the project
make build

# Convert a markdown file
dune exec bin/main.exe input.md output.html

# Run tests
make test
```

## Project Structure

```
├── src/
│   ├── parser.ml     # Core parsing logic
│   ├── io.ml        # File I/O operations
│   └── styles.ml    # CSS styling
├── bin/
│   └── main.ml      # CLI interface
└── test/
    └── test.md      # Test file
```

## Dependencies

- OCaml
- Dune build system
- Str library (standard library)