# Orb format

  The bridge tools work with a structured text format which we call Orb.
This is an introduction to that format.


## Metalanguage

  I call Orb a metalanguage, because it can by design include any other
structured text format within it.  Provided it may be represented in utf-8!
This is no stricture in practice.


The Orb format aims to be equally useful for markup, literate programming,
configuration, data exchange, and the sort of interactive notebook which
Jupyter and org-babel can produce.


The first tool to make use of this format, also called orb, is focused on
literate programming.  This will in turn be the format for the tools in the
bettertools suite.


## Goals

  Orb is:


  - Error free:  An Orb document is never in a state of error.  Any valid
                 utf-8 string is an Orb document.
  - Line based:  Orb files may be rapidly separated into their elements
                 by splitting into lines and examining the first few
                 characters.
  - Humane:      Orb is carefully designed to be readable, as is, by
                 ordinary humans.
  - General:     There are no characters such as <>& in HTML which must be
                 escaped.  Orb codeblocks can enclose any other format,
                 including Orb format.  Orb strings are «brace balanced»
                 and can enclose any utf-8 string as a consequence.


While it is possible to do some fancy things with Orb, it is also a
comfortable format to write a blog post, or put a few key-value pairs into
a config file.  If you were to send an email in Orb format, the recipient
might not even notice.


## Encoding

Orb documents are encoded in utf-8.


The core syntax is defined in terms of the reachable keys on a US keyboard.
This tradition is firmly entrenched in the mid teens, and I have no
designs on budging that at present.  The miser in me likes that they're
a byte each.  The lawyer in me insists that this isn't ASCII, which is a
seven-bit legacy encoding.


We aren't at all reluctant to use Unicode characters as part of the format.
Orb «strings» are the most visible example of this, along with drawer
and fold icons, which are actual parts of an Orb document.


Orb is case sensitive and uses lower-snake-case for built-in English
phrases. There is a convention (see classes) that uses capitalization of
user words to affect semantics.


Orb is a format for text.  There are many ways of writing text, but only one
way of encoding it that matters.  There is a long tail of Unicode complexity,
and there are traces of Committee spattered all over it; nonetheless we
should be grateful that utf-8 won, in a world in which we still drive cars on
both possible sides of the road.


Note that while we have our [own opinions about utf-8](httk://) our vision of
heaven is backward-compatible with the inferior version foisted upon us by a
jealous software monopoly.


Bidirectional handling in a context that's indentation sensitive is an
example of something subtle. Orb format uses indentation in a few key places,
and a compliant parser will need to detect and respect RTL [tk?] markers.
Exactly how is spelled out under [indentation](httk://)


I'd love to get a Hebrew and/or Arabic fluent hacker on the project
early, to make sure this works correctly.  I'll settle for Aramaic.


Another thing I want to get right is equivalence. If you have a
variable called "Glück" the compiler shouldn't complain if it's
rendered in either of the valid ways. For some sequences that's
"any of the valid ways". If we normalized your prose, you might
have problems later, so we don't want to solve it that way.


This consideration mostly applys to [hashtags](httk://) and
[handles](httk://).  The idea is that Orb files will respect all the
wacky typographic equivalences that Unicode has gifted us with.


#### Tabs

The vexacious ASCII character 8 will never be found in an Orb document.  If
encountered, it will be reduced to two spaces.


It's not an _error_ mind you, it's a well-defined input that will become
two spaces, as part of general housecleaning.


## Prose and Structure

The major distinction in Orb is between prose and structure.


Prose is the default parsing state. It is far from unstructured from the
runtime perspective. Although this needn't be embedded in the parse
tree, Orb understands concepts such as paragraphs, words, punctuation,
capital letters, languages, and anything else proper to prose.


I refer to human languages, but Orb understands programming languages
also. In principle, all of them, it shouldn't be harder to add them than
it is to call them from shell, though getting a runtime rigged up to
another runtime always calls for some finesse to derive a good experience.


"Programming languages" is overly specific.  Orb draws a distinction
between prose and structure. Blocks may contain either, or both.


Something that's nice about a language build on a prose/structure
relationship is that it can be error free.  Anything **grym** can't build into
a structure is just prose.


Markdown has this property.  Sometimes you run into parsers which
build errors into Markdown, which is itself erroneous.  If you [RTFM](http://daringfireball.net/projects/markdown/syntax),
you'll find the word "error" once.  Helpfully explaining how Markdown
keeps you from making one.


We do what we can to make the document look the same as it is
in fact structured.  The intention with Orb files is that we work with them
aided by a linter, which lets us be lazy and still get consistent results.


The most important point in this section is that Orb documents do not have
errors and never fail to parse.  You should be able to literally plug any
Orb parser into a source of entropy and end up with a document, since a
proper utf-8 decoder will drop any invalid bytes it sees.


## Ownership

  The root concept of Orb is a document, which divides into one or more
sections.  A section owns all structure or prose within it.  This
paragraph is owned by «** Ownership» above, as are all the rest of the
blocks until the next section header.


### Blocking

  Orb documents are chunked into sections entirely by their heading lines.
Within a section, prose and structure alike are organized into blocks.
The defining marker of blocks is blank lines.


This second paragraph is the second block of the «*** Blocking» section.
Taking a look at the source document, you'll see that I put (single)
newlines between lines, with an 78 column margin.  That should be considered
good style.  If you prefer to have each paragraph be its own line, have at.


A line is considered blank if it contains only Unicode spacemarks.  Orb
will smoothly remove any such cruft and replace it with «\n\n».  We also
trim trailing whitespace.


#### The Cling Rule

  [Tags](httk://) are used both to provide names to blocks in Orb format
and to specify various actions in knitting and weaving.  They may be placed
above or below the block which they affect, with the exception of sections,
where tags must be placed on or below the header line.


The cling rule specifies that a group 'clings' to another group when
it is closer to that group than the other group. Ties resolve down.


This should make it intuitive to group elements that aren't grouping the
way you expect: put in whitespace until the block is visually distinguished
from the surroundings.


Cling applies between blocks which are at the same level of ownership.
Ownership has precedence over cling: all blocks underneath e.g. a header
line are owned by that line, newlines notwithstanding.


Note that indentation of e.g. lists invokes the cling rule within the
indentation level.

```orb
| x | y | z |

#tag


someprose on a block
```

Tags the table, but

```orb
| x | y | z |


#tag

someprose on a block
```

Tags the block.


Even clings are resolved forwards:

```orb
| x | y | z |

#tag

someprose on a block
```

Tags the prose block.


## Structural elements

  Structure and prose are the figure and ground of Orb format.  We speak of
structure and prose on a block-by-block basis, and within some structure
blocks there are regions of prose.  Prose in turn routinely contains
structural regions.


This section will discuss under what circumstances an Orb parser will create
structure, with some discursions into the semantics these distinctions
represent.


### Headlines

  Headlines divide a document into sections.  The grammar for recognizing
a headline is as follows:

```peg
    headline = WS?  '*'+  ' '  prose  NL
```

The number of ``*`` determine the level of ownership.  This is a declarative
relationship, though I lack a clean syntax to express it other than
functionally at present.


The content within ``prose`` has the luxury of being context-sensitive.  In
particular we treat tags on a headline as though they're on a tagline below
they headline.



### Tags and Taglines

  Tags are the control structures for Orb.  There are ``#hashtags`` which
loosely correspond to functions or messages, and ``@handles`` which more
directly correspond to symbols.


The semantics of tags belong in the [runtime](httk://) section.


For now let us note that the rule

```peg
  hashtag = WS+  '#'  symbol
```

**may** not appear in (all) prose contexts, this is still undecided.  This is
true of handles as well given the state of ``grym`` at the present time,
but I am more firmly convinced of the value of @handle as a short in-place
expansion of a handleline. I don't think trying to parse a mid-block #export
as meaning something is as valuable.


These two rules are currently in use:

```peg
  hashline = WS?  '#'  symbol  ' '  prose  NL
  handleline = WS?  '@'  symbol  ' '  prose  NL
```

Structure is designed to work on a line-by-line basis,
any ``line`` rule has an implied ``^``.


### List

  Lists are both a markup format and a flexible data container.  In the emacs
org-mode, headline-type structures do the heavy lifting for TODO lists and
the like.  This was org's original purpose, with document markup coming later.


Orb lists come in unnumbered and numbered.  Unnumbered lists follow this rule:

```peg
  listline-un = WS? '- ' prose NL
```

While numbered lists match this:

```peg
  listline-li = WS? digits '. ' prose NL
```

For lists, as with any structure group, the semantics of the prose section are
somewhat flexible.  The cling rule for lists parses indentation so that
multi-line entries are possible:

```orb
  - list entry
   prose directly under, bad style
```

vs.

```orb
  - list entry
    continues list entry
```

As in Markdown, the parser will accept any numbers as a numbered list without
checking their order.


#### List Boxes

  Lists can have, as a first element, a box, either a checkbox ``[ ]`` or a
radio box ``( )``.  These are either empty with whitespace or have contents
from a limited pallete of symbols.  Their function is described in the
[runtime](httk://) section.

```orb
  - [ ] #todo finish orb.orb
    - [X] Metalanguage
    - [X] Prose and Structure
    - [REVISE] Link
    - [ ] Code Block

  - Fruits
    - ( ) Bananas
    - (*) Coconuts
    - ( ) Grapes
```

These two types can't meaningfully mix on the same level of a list.  The one
the parser sees first will be applied.


The radio button is contagious, if the parser encounters one all lines on
that level get one.


The check box is not, it's ok to include it on some lines but not others.  If
the parser sees a check box and then a radio button, it will turn the radio
button into a check box.


The radio button can only have one ``*``; the parser will ignore, and the
linter remove, any others.


#### Key/value pairs

  A list element can consist of key/value pairs, separated with a ``:``.

```orb
 - first key:
   - value : another value
   - 42 : the answer
```

From the runtime perspective the left and right sides are basically strings,
as we build out the Clu runtime we'll have better expectations for what
keys and values would look like as data.


### Code Block

  The reason Orb exists is literal programming.  We do codeblocks
carefully.


A codeblock looks like so:

```orb
#!orb
*** Some Orb content
#/orb
```

Try that trick in Git-Flavored Markdown...


The number of initial ``!!`` needs to match the closing ``//``, allowing any
utf-8 string at all to be enclosed with this method.  We consider this an
important property to have in an enclosure encoding.


Code blocks must be opened, but needn't be closed, as a parser will recognize
EOF as a code block closure.  This has a fortunate side effect, as this:

```sh
#!/usr/bin/python

from future import bettertools
```

Is a valid Orb document containing a python script.


Codeblock headers and footers, unlike most structure lines, cannot begin
with whitespace.


### Table

  Tables are our matrix data structure.  I have no immediate use for
spreadsheets that I can't meet with other software, but admire their
inclusion in Org and do use tables in markup from time to time.


I don't intend to do much more than recognize them in the near future,
but a glance at what Org offers with tables should give a sense of how
we want to use them within ``bridge``.

```orb
| 2  | 4  | 6  | 8  |
| 10 | 12 | 14 | 16 |
```

With a couple small refinements, this one should render with a line
between the header and therows:

```orb
| a  | b  | c  | d  |
~ 3  | 6  | 9  | 12 |
| 18 | 21 | 24 | 27 |
```

To extend a row virtually over two or more text lines

```orb
| cat, | chien,  | gato,    \
| hat  | chapeau | sombrero |
```

The only way to slip a ``|`` into a table cell is to put it inside a
«string». Other than that it's prose country.


### Link

  The most [basic link](httk://) follows a simple «[description](url)» pattern.  Markdown gets this right.  In HTML you'll see the
href before the link text, but looking at HTML is a mistake.


Org-mode follows the opposite convention.  This breaks the flow of text for
the reader and Orb format must be legible in raw form.


tk other Org-iastic link types.


### Categories

While [handles](httk://) define a user-level global namespace, and
[hashtags](httk://) an Orb-wide vocabulary of actions, categories are a
simple tagging system for classification.


Categories always refer to themselves, like a lisp ``:keyword``.  Handles always
refer to other Orb structures, while hashtags do things.


Categories are delineated ``:Like:so:for:Several:Categories:``.  They inherit,
like hashtags, on the basis of capitalization.  Like handles, they are parsed
within prose.  This is in contrast to hashtags, which are not.


The characters allowed in a category are broadly intended to be alphasymbolic,
and exclude markup and links.  Nor may hashtags or handles be used as categories.


I haven't implemented categories in the parser yet, but my intention is that
`` :Category:anotherCategory:[bad category]:aFourthCategory: `` won't break the parse
of ``:aFourthCategory:`` and will structurally attach it to the other two good ones,
with the bad one parsed prosaically.


### Drawer

  A drawer is a block that's hidden by default. The computer sees it,
the user sees ⦿, or a similar rune.

```orb
:[a-drawer]:
contents
:[a-drawer]:
```

This closes to a single Unicode character, such as ⦿, which can't be deleted
without opening it. Deleting into an ordinary fold marker opens the fold,
deleting towards a drawer marker skips past it.


``a-drawer`` is a handle, the @ isn't needed here but you could include it.
It's ok to just leave it blank: ``:[ ]:``.


The only purpose of a drawer is to draw a folding layer around some text
that's normally kept closed.  If you're doing something fancy you might
have a long header of imports and configs that you don't want to look at
all the time.


























