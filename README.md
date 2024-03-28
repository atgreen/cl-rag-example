# cl-rag-example
> A simple demo of LLM+RAG using Common Lisp and OpenAI

This simple demo ingests an annual shareholder report into a
[Chroma](https://www.trychroma.com/) vector database, and then uses
RAG-assisted generative AI to answer questions.

To support this task, we use:
* [cl-embeddings](https://github.com/atgreen/cl-embeddings) for LLM embeddings.
* [cl-completions](https://github.com/atgreen/cl-completions) for LLM completions.
* [cl-chroma](https://github.com/atgreen/cl-chroma) for the vector DB interface.

Usage
------

Install all dependencies with [ocicl](https://github.com/ocicl/ocicl).
To make all of this work I had to submit fixes to `jzon` and
`openapi-generator`, so you will need the very latest versions of
those systems.  They are all available in the ocicl repos.
```
$ ocicl install
```

Now examine `rag.lisp` to find the link to the earnings report we will
analyze.  Download it.

Download and install the Chroma vector DB:
```
$ pip install chromadb
$ chroma run
```

Now run the example:
```
$ sbcl --eval "(asdf:load-system :rag)" --eval "(rag::run)"
```

Author and License
-------------------

``cl-rag-example`` was written by [Anthony
Green](https://github.com/atgreen) and is distributed under the terms
of the MIT license.
