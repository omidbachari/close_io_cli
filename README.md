### Introduction

This is a script to list or create custom fields for a close.io account.

### Getting started

Install deps
```bash
bundle
```

Rename `.env.sample` to `.env`. Add keys.

### Usage

To list custom fields:
```bash
ruby fields.rb list
```

To create custom field:
```bash
ruby fields.rb create <NAME> <TYPE>
```

To only run the script to create a custom field for staging, add `sandbox`. Example:
```bash
ruby fields.rb create "US Goods" number sandbox
```

Note: add quotes when the name uses whitespace. Example:
```bash
ruby fields.rb create "US Goods" number
```

### TODO

- Add tests
- Organize directory structure
- Add more actions
