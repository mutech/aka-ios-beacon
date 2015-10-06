AKAControls
===========

AKAControls is a binding framework.

[Spend spare time here]

## Bindings
[tbd]

## Binding Expressions

Binding expressions specify the source of a binding.

### Syntax


```
<binding-expression> ::=
	<primary-expr>?  ('{' <attribute-list> '}')?
	
<primary-expr> ::=
	<constant-expr> | <keypath-expr> | <array-expr>

<constant-expr> ::=
	number |
	'"' string '"' |
	'<' class '>' |
	'$' identifier |
	'[' <binding-expression-list> ']'

<keypath-expr> ::=
	<keypath> | <scope> ('.' <keypath>)

<attribute-list> ::=
	<attribute> | <attribute-list> ',' <attribute>

<attribute> ::=
	<identifier> ':' <binding-expression>
```
