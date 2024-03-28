# cl-rag-example
> A simple demo of LLM+RAG using Common Lisp and OpenAI

This simple demo ingests an annual shareholder report into a
[Chroma](https://www.trychroma.com/) vector database, and then uses
RAG-assisted generative AI to answer questions.

To support this task, we use:
* [cl-embeddings](https://github.com/atgreen/cl-embeddings) for LLM embeddings.
* [cl-completions](https://github.com/atgreen/cl-completions) for LLM completions.
* [cl-chroma](https://github.com/atgreen/cl-chroma) for the vector DB inteface.

You can install each of these with
[ocicl](https://github.com/ocicl/ocicl):

```
$ ocicl install
```

Author and License
-------------------

``cl-rag-example`` was written by [Anthony
Green](https://github.com/atgreen) and is distributed under the terms
of the MIT license.
