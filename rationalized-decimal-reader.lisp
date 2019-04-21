;;;; rationalized-decimal-reader

(in-package #:rationalized-decimal-reader)

(defun invalid-leading-char (str)
  (error "RATIONALIZED-DECIMAL-READER:

The first character must be #\- or a digit.

Instead ~s was found" str))

(defun invalid-exponent (str)
  (error "RATIONALIZED-DECIMAL-READER:

The exponent must be a positive integer
Instead ~s was found" str))

(defun invalid-fractional-part (str)
  (error "RATIONALIZED-DECIMAL-READER:

The fractional part of the number must be an integer optionally
followed by a exponent.

Instead ~s was found" str))

(defun invalid-integer-part (str)
  (error "RATIONALIZED-DECIMAL-READER:

The integer part of the number must be an integer. This may
optionally be followed by a decimal point and fractional part
with or without an exponent

Instead ~s was found" str))

(defun read-rational (stream)
  (let* ((decimal-count 0)
         (exponent 0)
         (integer-part-str
          (with-output-to-string (integer-part-stream)
            (let ((head-char
                   (loop
                      :for c := (read-char stream nil)
                      :when (graphic-char-p c)
                      :return c)))
              (unless (or (char= head-char #\-) (digit-char-p head-char))
                (invalid-leading-char head-char))
              (write-char head-char integer-part-stream))
            (let ((is-decimal nil))
              (loop
                 :for c := (read-char stream nil)
                 :while
                 (cond
                   ((null c)
                    nil)
                   ((char= c #\.)
                    (setf is-decimal t)
                    nil)
                   ((alphanumericp c)
                    (unless (digit-char-p c)
                      (invalid-integer-part c))
                    (write-char c integer-part-stream)
                    t)
                   (t
                    (unread-char c stream)
                    nil)))
              (let ((has-exponent))
                (when is-decimal
                  (loop
                     :for c := (read-char stream nil)
                     :while
                     (cond
                       ((null c)
                        nil)
                       ((or (char= c #\e) (char= c #\E))
                        (setf has-exponent t)
                        nil)
                       ((alphanumericp c)
                        (unless (digit-char-p c)
                          (invalid-fractional-part c))
                        (write-char c integer-part-stream)
                        (incf decimal-count)
                        t)
                       (t
                        (unread-char c stream)
                        nil))))
                (when has-exponent
                  (let ((exponent-str
                         (with-output-to-string (exponent-stream)
                           (loop
                              :for c := (read-char stream nil)
                              :while
                              (cond
                                ((null c)
                                 nil)
                                ((alphanumericp c)
                                 (invalid-exponent c)
                                 (write-char c exponent-stream)
                                 t)
                                (t
                                 (unread-char c stream)
                                 nil))))))
                    (setf exponent
                          (handler-case (parse-integer exponent-str)
                            (error () (invalid-exponent exponent-str)))))))))))
    (* (/ (parse-integer integer-part-str)
          (expt 10 decimal-count))
       (expt 10 exponent))))

(defun rational-reader (stream char n)
  (declare (ignore char n))
  (read-rational stream))

(named-readtables:defreadtable :rationalized-decimal-reader
    (:merge :standard)
  (:dispatch-macro-char #\# #\% #'rational-reader))
