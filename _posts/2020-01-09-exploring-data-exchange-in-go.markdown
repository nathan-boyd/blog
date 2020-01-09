---
layout: single
title:  "Exploring Data Exchange in Go"
date:   2020-01-09 07:28:00 -0500
categories:
  - dev
tags:
  - Go
  - Golang
  - Data
---

A common task for a software engineer is to transform data from one format into another that is suitable for their needs. Some data formats are good for storage, others are easy to edit, and some are ideally suited for transport. Transforming data from a source format and into a target format is known as Data Exchange.

There are many well known, commonly used, data formats YAML, XML, CSV, and JSON are popular text based human readable formats, binary formats like Protobufs and Flatbuffers are are gaining in popularity due to their improved serialization performance and small size when compared to text based formats. The prevalence of JSON in our industry, it makes for an ideal format to focus our exploration.

JavaScript Object Notation (JSON) is a format that is easy for humans to read and write and it is easy for machines to parse and generate. JSON is a language independent text format, but uses conventions that are familiar to programmers of the C-family of languages. Later we'll use JSON to illuminate our exploration of data exchange in GO.

## Data Exchange Definitions

In Computer Science we sometimes employ nebulous terminology to communicate our ideas. The words Encode, Marshal, and Serialize are common terms in discussions about data exchange and in the most general sense these words mean the same thing. Generally we're talking about adding logical structure where it did not exist before. Lets take a look at the difference in meaning across contexts.

### English Verbs

- Encode: to convert from one system of communication into another
- Marshal: to bring together and order in an appropriate or effective way
- Serialize: to arrange or publish in serial form

### Computer Science verbs

- Encode: convert into a coded form
- Marshal: the creation of a representation of data
- Serialize: a marshaling process by which an object is converted into bytes for storage or transmission

### GO Verbs

In the Go standard library we use the terms Encoding and Marshaling for two distinct but similar ideas. GO Encoders provide structure to streams while GO Marshalers provide structure to bytes in memory. The key differentiator is that Encoders are for streams which are unbounded and Marshalers are for arrays of bytes which are bounded.

- Encode: used when working with byte streams
- Marshal: used when working with byte arrays or slices

## Exchanging JSON Data in GO via Serialization

Serialization and deserialization are common practices for exchanging data across a [web API](https://play.golang.org/p/IHurTV69Mpm). JSON is a popular format for REST-ful API's. The GO standard library contains an [encoding package](https://golang.org/pkg/encoding/) which defines interfaces shared by other packages that convert data to and from byte-level and textual representations.

### JSON Marshaling

To encode JSON data we use the [Marshal](https://golang.org/pkg/encoding/json/#Marshal) function.

{% highlight go %}
func Marshal(v interface{}) ([]byte, error)
{% endhighlight %}

If we have a struct called Cat

{% highlight go %}
type Cat struct {
    Name string
    Color string
}
{% endhighlight %}

and an instance of a Cat

{% highlight go %}
c := Cat{"Sophie", "Black" }
{% endhighlight %}

we can use Marshal to create an array of bytes that represents our cat as a json object

{% highlight go %}
b, err := json.Marshal(c)
{% endhighlight %}

if this function call succeeds then err will be nil and b will be a byte array containing our JSON data

{% highlight go %}
b = []byte(`{"Name":"Sophie","Color":"Black"}`)
{% endhighlight %}

If we put these snippets together we get a simple program to demonstrate JSON serialization

{% highlight go %}
package main

import (
	"encoding/json"
	"fmt"
)

type Cat struct {
	Name  string
	Color string
}

func main() {
	c := Cat{"Sophie", "Black"}
	b, err := json.Marshal(c)
	if nil != err {
		fmt.Println(err)
	}
	fmt.Println(b)
	fmt.Println(string(b))
}
{% endhighlight %}

To see this code running live explore this [GO Playground](https://play.golang.org/p/szJrdNo-LE6)

### JSON Unmarshaling

To decode JSON data we use the [Unmarshal](https://golang.org/pkg/encoding/json/#Unmarshal) function.

{% highlight go %}
func Unmarshal(data []byte, v interface{}) error
{% endhighlight %}

first we create an instance of our cat

{% highlight go %}
var c Cat
{% endhighlight %}

and call Unmarshal with our array of bytes and a pointer to our cat

{% highlight go %}
err := json.Unmarshal(b, &c)
{% endhighlight %}

If b is valid JSON that fits in our definition of a cat then err should be nil and the data from our byte array will be represented in c just as it would have been if we assigned the values ourselves.

{% highlight go %}
c = Message{
    Name: "Sophie",
    Color: "Black",
}
{% endhighlight %}

Here is an example of using the JSON format to unmarshal an array of bytes into a Go Struct

{% highlight go %}
package main

import (
	"encoding/json"
	"fmt"
)

type Cat struct {
	Name  string
	Color string
}

func main() {

	b := []byte{
		123, 34, 78, 97, 109, 101, 34, 58, 34, 83, 111,
		112, 104, 105, 101, 34, 44, 34, 67, 111, 108, 111,
		114, 34, 58, 34, 66, 108, 97, 99, 107, 34, 125,
	}

	var c Cat
	err := json.Unmarshal(b, &c)
	if nil != err {
		fmt.Println(err)
	}

	fmt.Printf("%+v\n", c)
}
{% endhighlight %}

See the example above live in a [GO Playground](https://play.golang.org/p/fOHjG4EQW3b)

## Custom Marshaling and Unmarshaling

### Unmarshaling with field tags

A tag allows you to attach metadata to the field which can be read using reflection. Often these tags are used to provide information used during transformation activities like encoding to or decoding from another format. For more information about field tags in GO see the Resources section

{% highlight go %}
type Cat struct {
    Name  string `json:"pet_name"`
    Color string `json:"pet_color"`
}
{% endhighlight %}

Unmarshaling with json tags [Go Playground](https://play.golang.org/p/jvsN6TyyFPV)

Marshaling GO with json tags allows you to transform the object during encoding and decoding. This transform is symmetric, meaning the Cat above will always Marshal with the tag values

{% highlight go %}
{"pet_name":"Sophie","pet_color":"Black"}
{% endhighlight %}

If you want to decode values one way and encode them another we’ll need to GO a little further.

### Marshaling with embedded interfaces

Decoding pet_name to our object’s field Name is useful, but when we encode back to a serialized format we transform Name back to  to `pet_name`. This may or may not be the behavior you’re looking for. What if we wish to maintain fidelity to our object’s field names and encode Name just as  Name?

GO has a plan for that. Within the encoding/json package you’ll find the [Marshaler](https://golang.org/pkg/encoding/json/#Marshaler) and [Unmarshaler](https://golang.org/pkg/encoding/json/#Unmarshaler) interfaces which may be implemented by your structs to perform encoding operations to suit your needs. When the encoding/json package finds a type that implements the Marshaler / Unmarshal interface, it uses that type’s MarshalJSON() and UnMarshalJSON() functions instead of the built in functions to transform the object. If you’re familiar with some object oriented languages you might think of method overriding. The end result is effect is similar but GO calls this practice [embedding](https://golang.org/doc/effective_go.html#embedding).

The following example demonstrates how to embed the Marshaler and Unmarshaler interfaces within our Cat object

{% highlight go %}
package main

import (
	"encoding/json"
	"fmt"
)

type Cat struct {
	Name  string `json:"pet_name"`
	Color string `json:"pet_color"`
}

func (c Cat) MarshalJSON() ([]byte, error){

	return nil, nil
}


func (c Cat) UnmarshalJSON([]byte) error {

	return nil
}

func main() {
	json_string := `
	{
		"pet_name": "Sophie",
		"pet_color": "Black"
	}`

	c := &Cat{}
	json.Unmarshal([]byte(json_string), c)
	fmt.Printf("Unmarshal: %s\n", c)

	json, _ := json.Marshal(c)
	fmt.Printf("Marshal: %s\n", json)
}
{% endhighlight %}

Explore the preceding code for yourself in this [Go Playground](https://play.golang.org/p/TTlPumYZ27B)

### Custom Marshaling

Now that we understand how to embed the Marshaler interface we implement our own functionality like decoding pet_name to Name and encode while keeping fidelity with our object’s field names. When we embed our own Marshaler we can control the marshaling process.

{% highlight go %}
{"Name":"Sophie","Color":"Black"}
{% endhighlight %}

In practice this looks like the following
{% highlight go %}
package main

import (
	"encoding/json"
	"fmt"
)

type Cat struct {
	Name  string `json:"pet_name"`
	Color string `json:"pet_color"`
}

func (c Cat) MarshalJSON() ([]byte, error) {

	return json.Marshal(&struct {
		Name  string
		Color string
	}{
		Name:  c.Name,
		Color: c.Color,
	})
}

func main() {
	json_string := `
	{
		"pet_name": "Sophie",
		"pet_color": "Black"
	}`

	c := &Cat{}
	json.Unmarshal([]byte(json_string), c)
	fmt.Printf("Unmarshal: %s\n", c)

	json, _ := json.Marshal(c)
	fmt.Printf("Marshal: %s\n", json)
}
{% endhighlight %}

Check it out for yourself in this [Go Playground](https://play.golang.org/p/jHiqUN7BJdF)

Go provides a Marshaler and Unmarshaler interface for most data exchange formats. So if you’re working with YAML, XML, or Protobufs the same pattern will likely available.

## Further Reading

### Go Subclassing and Overriding via Embedding

- [GO Embedding](https://golang.org/doc/effective_go.html#embedding)

### Tags in Go Struct types

- [Go well known Struct Tags](https://github.com/golang/go/wiki/Well-known-struct-tags)
- [Gopher Con Presentation Slides: The Many Faces of Go Tags](https://github.com/gophercon/2015-talks/blob/master/Sam%20Helman%20%26%20Kyle%20Erf%20-%20The%20Many%20Faces%20of%20Struct%20Tags/StructTags.pdf)
- [GopherCon 2015: Sam Helman & Kyle Erf - The Many Faces of Struct Tags](https://www.youtube.com/watch?v=_SCRvMunkdA)
- [Go Struct Types](https://golang.org/ref/spec#Struct_types)

### JSON IN GO

- [Encoding / Json Package](https://golang.org/pkg/encoding/json/)
- [JSON and GO GoBLOG](https://blog.golang.org/json-and-go)
