---
layout: post
title: "A Case Against Go Contracts"
categories: go generics
---

I originally wrote this on the 5th of August 2019 but didn't share it.

After reading about [The Next Steps for Generics] on the Go Blog, which I think
are great next steps by the way, I recalled that last year shortly after the
publication of the [Go Contracts Proposal] I had written down an argument
against contract, explaining why in my view their overlap with interfaces was a
problem, and showing step by step how we could make both concepts be more
orthogonal with each other, which ends in the realisation that contracts are not
needed after all.

I now see some value in sharing it, even though it's a little late, because I
think it provides a rationale for evaluating the updated interface-based
proposal against the previous contract-base one. So here it is, copy-pasted
from a file on my computer!

## Non-orthogonality in the draft generics proposal

An example of the proposal is the [`Stringer` contract](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#contract-introduction),
spelt differently to disambiguate with the interface:

```golang
contract StringerC(T) {
    T String() string
}
```

This is inspired from the standard library `Stringer` interface:

```golang
type Stringer interface {
    String() string
}
```

In fact, any type implements the `Stringer` interface if and only if it
satisfies the `StringerC` contract! The concepts are clearly not orthogonal. I
am not implying that the contract and interface above fulfill the same role
(they don't), I am saying that they express the same information about a type.

OTOH another example given in the proposal is that of a [graph contract](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#mutually-referencing-type-parameters):

```golang
contract G(N, E) {
    N Edges() []E
    E Nodes() (N, N)
}
```

Clearly that relationship between types cannot be expressed with an interface,
because an interface is about specifying method signatures for one type only.

What I want to show is that it is possible to 'factor out' the common part of
contracts and interfaces so that:

- interfaces are the only means of specifying the signature of a set of methods
  for a atype.
- contracts are the only means of specifying relationships between types.

## Factoring method signature out of contracts

The graph contract:

```golang
contract G(N, E) {
    N Edges() []E
    E Nodes() (N, N)
}
```

can be rewritten as the combination of two contracts, each only specifying the
methods of one single generic type:

```golang
contract NodeC(N, E) {
    N Edges() []E
}

contract EdgeC(E, N) {
    E Nodes (N, N)
}

contract G(N, E) {
    NodeC(N, E)
    EdgeC(E, N)
}
```

Now the interfaces `NodeC` and `EdgeC` express information about a type that can
be expressed by generic interfaces:

```golang
type NodeI(type E) interface {
    Edges() []E
}

type EdgeI(type N) interface {
    Nodes() (N, N)
}
```

Now if I only could express in a contract that a type should satisfy an
interface, I could express my graph contract in terms of generic interfaces. So
let's imagine that I can write:

```golang
contract G(N, E) {
    N NodeI(E)  // This means that N implements the NodeI(E) interface
    E EdgeI(N)  // This means that E implements the EdgeI(N) interface
}
```

If we ignore for now the case of types in contracts, I think it is clear that
every contract can be rewritten in terms of generic interfaces like the one
above. It's pretty obvious that the process above can be applied to any
contract.

## The case of types in contracts

According to the principle that what is about one single type should be
specified in an interface, a contract like this one:

```golang
contract SignedIntegerC(T) {
	T int, int8, int16, int32, int64
}
```

should really be an interface:

```golang
type SignedIntegerI interface {
    int, int8, int16, int32, int64
}

contract SignedIntegerC(T) {
    T SignedInteger
}
```

The above means that types that implement `SignedIntegerI` must have one of the
types listed as its underlying type.

```golang
func Sum(type T SignedIntegerC)(s []T) (sum int64) {
    for _, n := range s {
        sum += int64(n)
    }
    return
}
```

Note that it means that in the above we should not be able to choose
`SignedInterfaceI` as the value of `T` as the type `SignedInterfaceI` itself
does not have any of the signed integer types as its underlying type. That is a
bit strange!

## Why use a contract at all?

Say we want to implement a graph data structure using the `G` contract specified above:

```golang
contract G(N, E) {
    N NodeI(E)
    E EdgeI(N)
}

type Graph(type N, E, G) struct { ... }
```

Instead, you could just specify what interfaces the types `N` and `E` should implement:

```golang
type Graph(type N NodeI(E), E EdgeI(N)) struct { ... }
```

In fact many of the contracts in the examples I have seen so far do not express
a relationship of the types they are a contract for. Here is an example from
the [`metrics` package](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#metrics):

```golang
contract cmp3(T1, T2, T3) {
	comparable(T1)
	comparable(T2)
	comparable(T3)
}

type key3(type T1, T2, T3 cmp3) struct {
	f1 T1
	f2 T2
	f3 T3
}

type Metric3(type T1, T2, T3 cmp3) struct {
	mu sync.Mutex
	m  map[key3(T1, T2, T3)]int
}
```

Assuming `comparable` is an interface, using this new syntax you wouldn't need
the contract and could just write the following.

```golang
type key3(type T1 comparable, T2 comparable, T3 comparable) struct {
	f1 T1
	f2 T2
	f3 T3
}

type Metric3(type T1 comparable, T2 comparable, T3 comparable) struct {
	mu sync.Mutex
	m  map[key3(T1, T2, T3)]int
}
```

It's a matter of taste what syntax is nicer, but what is sure is that the
contract version is no more expressive.

[the next steps for generics]: https://blog.golang.org/generics-next-steps
[go contracts proposal]: https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md
