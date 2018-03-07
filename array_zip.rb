require 'awesome_print'

a = [ 1, 2, 3, 4, 5 ]
b = [ 1, 2, 3, a, b ]

x = a.zip(b)

ap x
