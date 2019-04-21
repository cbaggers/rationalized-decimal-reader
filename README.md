# rationalized-decimal-reader

A reader-macro to read a decimal as a rational.

    #%0.3    -> 3/10
    #%0.275  -> 11/40
    #%-1.5   -> -3/2
    #%-1.5e3 -> -1500

Useful in cases where the decimal form is preferable for readability but the rational precision is required.

To use add `(named-readtables:in-readtable :rationalized-decimal-reader)` to your file.

### Context

I was watching a talk by Joe Armstrong and he pointed out a fun example of floating point approximations really hurting an computation. I've summarized it below but a nice example is here: https://www3.nd.edu/~markst/castaward/text8n.html

If we have `f(x,y) = 333.75y^6 + x^2(11x^2y^2 - y^6 -121y^4 - 2) + 5.5y^8 + x/2y` and we say x = 77617 and y = 33096

then using 32bit floats we get `f = 1.172603...`

and with double precision, we get `f = 1.1726039400531...`

But the correct answer is `f = -0.827396059946...`

We didnt even get the sign correct!

Now of course we can do it correctly in CL using rationals (please excuse the very rudimentary translation).

    (let ((x 77617)
          (y 33096))
      (+ (* 1335/4 (expt y 6))
         (* (expt x 2) (- (* 11 (expt x 2) (expt y 2))
                          (expt y 6)
                          (* 121 (expt y 4))
                          2))
         (* 11/2 (expt y 8))
         (/ x (* 2 y))))

Which gives `-54767/66192` which is `-0.82739604` as a single-float.

So we are correct, **however** it's a shame that we have to write the numbers in that form when the original has them as decimals. It can be important when the written representation of a thing may more easily show a pattern that may be of interest to the reader.

To get around this we can use the reader-macro from this system:

    (let ((x 77617)
          (y 33096))
      (+ (* #%333.75 (expt y 6))
         (* (expt x 2) (- (* 11 (expt x 2) (expt y 2))
                          (expt y 6)
                          (* 121 (expt y 4))
                          2))
         (* #%5.5 (expt y 8))
         (/ x (* 2 y))))

Which of course gives `-54767/66192` which is the answer we were looking for.

## Future Work

Supporting radix would be a good idea. If you are interested in that please file an issue.
