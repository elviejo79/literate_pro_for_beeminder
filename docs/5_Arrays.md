# Arrays

Arrays are the one object structure in this text that we will not be implementing because it is already provided to us in standard Eiffel libraries,
and described in the language and library references [5, 6].
We will, however, discuss one possible way to implement it.
We study class ARRAY because we will be using it to implement other object structures in later chapters.

## 5.1 What an ARRAY Is and What It Does

An array keeps track of objects by their relative positions within the array.
The positions are numbered consecutively, and the range of position numbers is
specified when an array is created.
For example, after the entity declaration
x: ARRAY [SOME_TYPE};
y: ARRAY [SOME_OTHER_TYPE)];
the statement
"x.
make (1,100);

creates an array of 100 positions
(“capacity 100”), in which position number 1
(“lower bound”)
is first, and position number 100
(“upper bound”)
is last, and
attaches it to entity x.
Similarly,
!y.
make (-3,3);

attaches to y a new array of capacity 7
(don’t forget to count position 0!), where
the lowest numbered position is number -3, and the highest is number 3.

63

