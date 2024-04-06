;;; rag.lisp
;;;
;;; SPDX-License-Identifier: MIT
;;;
;;; Copyright (C) 2024  Anthony Green <green@moxielogic.com>
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to deal
;;; in the Software without restriction, including without limitation the rights
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in all
;;; copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;;; SOFTWARE.
;;;

(in-package :rag)

;; Install and run the chroma vector DB locally.  We will talk to it
;; via a REST API using cl-chroma.

(defparameter +chroma-server+ "http://localhost:8000")
(defparameter +collection-name+ "nvidia-rag-db")
(defparameter +openai-api-key+ (uiop:getenv "OPENAI_API_KEY"))

(defun ingest (pdf-file)
  (let ((chunks (text-splitter:split (text-splitter:make-document-from-file pdf-file)
                                     :size 5000
                                     :overlap 200))
        (embedder (make-instance 'embeddings:openai-embeddings :api-key +openai-api-key+))
        (collection (chroma:create-collection :name +collection-name+ :get-or-create t :server +chroma-server+)))
    (loop with i = 0
          for chunk in chunks do
            (progn
              (chroma:add (gethash "id" collection)
                          :documents (list chunk)
                          :embeddings (list (embeddings:get-embedding embedder chunk))
                          :ids (list (write-to-string (+ 1000 (incf i))))
                          :server +chroma-server+)))))

;; For this example, I downloaded the 2023 NVidia annual report from here:
;; https://s201.q4cdn.com/141608511/files/doc_financials/2023/ar/2023-Annual-Report-1.pdf
;;
;; First we ingest the annual report into the Chroma vector database in 3 page chunks

(ingest "2023-Annual-Report-1.pdf")

;; Next, we define a function that can be invoked by the LLM in order to learn from the NVidia report.

(completions:defun-tool rag-lookup ((query string "A description of the information you need about NVidia"))
  "Useful when you need information about NVidia"
  (let* ((collection (chroma:create-collection :name +collection-name+ :get-or-create t :server +chroma-server+))
         (id (gethash "id" collection))
         ;; Create a vector for the query string.
         (embedder (make-instance 'embeddings:openai-embeddings :api-key +openai-api-key+))
         (embedding (embeddings::get-embedding embedder query)))
    ;; Return the text of the best match for the query embedding.
    (let ((result (chroma:get-nearest-neighbors id :n-results 1 :query-embeddings (list embedding))))
      (aref (aref (gethash "documents" result) 0) 0))))

;; Now let's just ask a question from the LLM, telling it about our rag-lookup tool.

(defun run ()
  (print (let ((c (make-instance 'completions:openai-completer
                                 :api-key +openai-api-key+
                                 :tools '(rag-lookup))))
           (completions:get-completion c "Is NVidia growing?  Show some evidence."))))

#|
The above code will emit something like the following:

NVidia's business is showing strong growth, which can be evidenced by the following points:

1. Expansion into new markets: NVidia is diversifying its product range and entering new markets. They have developed the NVidia Omniverse and the NVidia cuLitho line. The Omniverse is aimed at the automotive industry, aiming to help them modernize all processes to take advantage of computing and AI. For instance, big players such as BMW Group and Mercedes-Benz are already using Omniverse for their operations. cuLitho is a new library that supercharges computational lithography, an immense computational workload in chip design and manufacturing. This is very beneficial for the industry as it accelerates computational lithography by over 40X and paves the way for the industry to go to 2nm and beyond.

2. Growth in user base: The number of developers working with CUDA (a parallel computing platform and application programming interface model created by Nvidia) has doubled in the last two and a half years. Four million developers are working with CUDA, and it has been downloaded more than 40 million times.

3. Increased Activity: NVidia's data center AI and accelerated workloads are continuing to skyrocket as developers are shifting to NVidia accelerated computing.

4. Financial Performance: Despite a tough 2022 due to economic headwinds, geopolitical tension, and a fluctuating product supply chain, NVidia managed to keep its revenue nearly flat, at around $26.97 B.

5. Library and models: NVidia now offers 300 acceleration libraries and 400 AI models, with 100 added or updated in the past year alone.
|#
