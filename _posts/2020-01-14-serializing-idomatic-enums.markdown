---
layout: single
title:  "Idiomatic Enums in Go"
date:   2020-01-09 07:28:00 -0500
categories:
  - dev
tags:
  - Go
  - Golang
  - Idioms
---

A programming idiom is the usual way to code a task in a specific language. Although Golang does not have built in support for enumerations there is an idomatic way to emulate the feature. The idiomatic way to have enumerations in Go is to use a combination of the [Iota](https://github.com/golang/go/wiki/Iota) and Integer types.

{% highlight go %}

type TaxonomicRank int

const (
    Animalia TaxonomicRank = iota
    Plantae
    Fungi
    Protista
    Archaea
    Bacteria
)

func (m TaxonomicRank) String() string {
	return toString[m]
}

var toString = map[TaxonomicRank]string{
     Animalia:  "Animalia",
     Plantae:   "Plantae",
     Fungi:     "Fungi",
     Protista:  "Protista",
     Archaea:   "Archaea",
     Bacteria:  "Bacteria",
}

var toEnum = map[string]TaxonomicRank{
     "Animalia":  Animalia,
     "Plantae":   Plantae,
     "Fungi":     Fungi,
     "Protista":  Protista
     "Archaea":   Archaea
     "Bacteria":  Bacteria,
}


{% endhighlight %}

For extra credit, as they say, we can add support for serialization support for our enum with the following

{% highlight go %}

// MarshalJSON marshals the enum as a quoted string
func (m TaxonomicRank) MarshalJSON() ([]byte, error) {
	buffer := bytes.NewBufferString(`"`)
	buffer.WriteString(toString[m])
	buffer.WriteString(`"`)
	return buffer.Bytes(), nil
}

// UnmarshalJSON unmarshals a quoted json string to the enum value
func (m *TaxonomicRank) UnmarshalJSON(b []byte) error {
	var j string
	err := json.Unmarshal(b, &j)
	if err != nil {
		return err
	}

	// if the string does not exist in the map return element at index 0
	*m = toEnum[j]
	return nil
}

{% endhighlight %}
