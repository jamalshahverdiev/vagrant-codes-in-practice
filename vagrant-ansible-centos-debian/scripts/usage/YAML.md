[Online YAML Converter to JSON](http://yaml-online-parser.appspot.com/)

#### The following code will convert YAML file to the JSON format:
```bash
$ cat test.yml
# Every YAML file should start with three dashes
---

example_key_1: |
  this is a string
  that goes over
  multiple lines

# Every YAML file should end with three dots
...
$ python -c 'import yaml,pprint;pprint.pprint(yaml.load(open("test.yml").read()))'
{'example_key_1': 'this is a string\nthat goes over\nmultiple lines\n'}
```

#### Multiple lines as a single line:
```bash
$ cat test.yml
# Every YAML file should start with three dashes
---

example_key_1: >
  this is a string
  that goes over
  multiple lines

# Every YAML file should end with three dots
...
$ cat integerYaml.yml
# Every YAML file should start with three dashes
---

example_integer: 1

# Every YAML file should end with three dots
...
```

#### Boolian types in YAML:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

# false, False, FALSE, no, No, NO, off, Off, OFF
# true, True, TRUE, yes, Yes, YES, on, On, ON

# n.b. n does not equal false, y does not equal true

is_false_01: false
is_false_02: False
is_false_03: FALSE
is_false_04: no
is_false_05: No
is_false_06: NO
is_false_07: off
is_false_08: Off
is_false_09: OFF
is_false_10: n
is_true_01: true
is_true_02: True
is_true_03: TRUE
is_true_04: yes
is_true_05: Yes
is_true_06: YES
is_true_07: on
is_true_08: On
is_true_09: ON
is_true_10: y

# Every YAML file should end with three dots
...
```

#### Lists in YAML:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

- item 1
- item 2
- item 3
- item 4
- item 5

# Every YAML file should end with three dots
...
```

#### Inline block format:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

{example_key_1: example_value_1, example_key_2: example_value_2}

# Every YAML file should end with three dots
...
```

#### Lists in YAML:
```bash
$ cat  test.yml
---
# Every YAML file should start with three dashes

[example_list_entry_1, example_list_entry_2]

# Every YAML file should end with three dots
...
```

#### Dictionary with value LIST:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

example_key_1:
  - list item 1
  - list item 2

example_key_2:
  - list item 3
  - list item 4

# Every YAML file should end with three dots
...
```

#### List of dictionaries:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

- example_1:
  - item_1
  - item_2
  - item_3

- example_2:
  - item_4
  - item_5
  - item_6

# Every YAML file should end with three dots
...
```

#### List of dictionary keys with list of items:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

example_dictionary_1:
  - example_dictionary_2:
    - 1
    - 2
    - 3
  - example_dictionary_2:
    - 4
    - 5
    - 6
  - example_dictionary_4:
    - 7
    - 8
    - 9

# Every YAML file should end with three dots
...
```

#### List of items with dict values:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

- Aston Martin:
    year_founded: 1913
    website: astonmartin.com
- Fiat:
    year_founded: 1899
    website: fiat.com
- Ford:
    year_founded: 1903
    website: ford.com
- Vauxhall:
    year_founded: 1857
    website: vauxhall.co.uk

# Every YAML file should end with three dots
...
```

#### Last example:
```bash
$ cat test.yml
---
# Every YAML file should start with three dashes

- Aston Martin:
    year_founded: 1913
    website: astonmartin.com
    founded_by:
      - Lionel Martin
      - Robert Bamford
- Fiat:
    year_founded: 1899
    website: fiat.com
    founded_by:
      - Giovanni Agnelli
- Ford:
    year_founded: 1903
    website: ford.com
    founded_by:
      - Henry Ford
- Vauxhall:
    year_founded: 1857
    website: vauxhall.co.uk
    founded_by:
      - Alexander Wilson

# Every YAML file should end with three dots
...
```

### Links
[YAML official page](http://www.yaml.org/spec/1.2/spec.html)
[WIKI Page](https://en.wikipedia.org/wiki/YAML)
[StackOverFlow](https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-over-multiple-lines)
