# 14 Faster Dictionaries

In Chapter 11, we played with linear search,
but saw that it was inefficient.
In this chapter, we look at two other ways to search for items.
The first works on sorted object structures in a manner similar to the way humans search book dictionaries.
It works much faster than a linear search-as long as we use the array implementation of lists.

The second way tends to perform well statistically,
if the nature of the key is known in advance and taken into account
-but, again, only with arrays.

We will look at efficient ways to search for associations in linked object structures in Part IV.

## 14.1 Binary Search

So, how do humans search paper dictionaries?
Most people start by taking a guess about the page the word is on.
If the word sought precedes alphabetically the words on that page,
they make another guess among the preceding pages.
If it follows those words,
they make another guess among the following pages.
They keep doing it until they zero in on a page where they expect the sought word to be,
and scan that page for it.

Well, our dictionary objects do not have pages,
so we can make the algorithm simpler and more efficient.
In fact, we have a much better analogy for it:
the “higher/lower” game.
You pick a number between, say, 1 and 100,
and I have to guess it.
You tell me if each of my guesses is higher or lower than your number.
The fastest way for me to zoom in on your number is to keep dividing the
range in half and asking you about the number in the middle of the range.

That is exactly how the binary search algorithm works.
The recursive version of it is:

```
location (<an item>, <a range>): INTEGER is
    -- Location of the item within the range.
do
    if <the range is empty> then
        Result := <a number that indicates "not found">;
    elseif <the item>.is_equal(<item in the middle of the range>) then
        Result := <the middle index>;
    elseif <the item> < <item in the middle of the range> then
        Result := location(<the item>, <left half of the range>);
    else
        Result := location(<the item>, <right half of the range>);
    end;
end; -- location
```

Looking back at class DICTIONARY_LINEAR in Listing 11.4,
we see that it can be modified into a DICTIONARY_BINARY.

In fact, most of the features are unaffected,
as long as we keep using a LIST to track the items
-for example, `delete` will work exactly the same way,
regardless of whether the version of locate it calls performs a linear search or a binary one.
So let us start by factoring the common routines (most of them) into a common ancestor,
`deferred class DICTIONARY_LIST`, as shown in Listing 14.1.
That class defines associations as LIST[ASSOCIATION[KEY,VALUE]],
so that the subclasses can redefine it as the appropriate subclass of LIST.

```Eiffel
deferred class DICTIONARY_LIST [KEY -> COMPARABLE, VALUE] 
inherit
    DICTIONARY (KEY, VALUE)
feature {DICTIONARY_LIST}
    associations: LIST [ASSOCIATION [KEY, VALUE]];
        --The list of associations.

    locate (key: KEY) is
        --Move associations' cursor to an association for
        --key or off-right if there is no such association.
        deferred
    end; --locate

feature -- Adding, removing, and checking associations
    <same as in Listing 11.4, but without put>

feature --Sizing
    <same as in Listing 11.4>

feature --Comparisons and copying
    <same as in Listing 11.4>

feature --Simple input and output
    <same as in Listing 11.4>

invariant
    have_list: associations /= Void;
end --class DICTIONARY_LIST
```
Listing 14.1 Deferred class DICTIONARY_LIST, the common ancestor of DICTIONARY_LINEAR and DICTIONARY_BINARY.

The new version of class DICTIONARY_LINEAR,
as shown in Listing 14.2, is very short.
It redefines associations to be the subclass of LIST best suited to
the task.
(I have chosen the doubly linked version to keep delete at O(1);
other choices may be better in other circumstances.)
It provides a version of `put` that is optimized for that type of list,
and the linear version of locate.
(The reason make is here and not in the common ancestor is that in class DICTIONARY_LIST it would be interpreted as an attempt to create an object of class LIST,
which is a deferred class and thus cannot have any created objects.)
You should test the new version with DICTIONARY_TESTER,
which you wrote in Exercise 11.1.


```Eiffel
class DICTIONARY_LINEAR [KEY -> COMPARABLE, VALUE] 
inherit
    DICTIONARY_LIST [KEY, VALUE]
    redefine
        associations,
        locate,
        put
    end;
creation 
    make

feature {DICTIONARY_LIST}
    associations: LIST_DOUBLY_LINKED [ASSOCIATION [KEY, VALUE]];
        --The list of associations.

    locate (key: KEY) is
        --Move associations' cursor to an association for key
        --or off-right if there is no such association.
    do
        from
            associations.move_off_left;
            associations.move_right;
        until
            associations.is_off_right or else key.is_equal (associations.item.key)
        loop
            associations.move_right;
        end;
    end; --locate

feature --Creation and initialization
    <same as in Listing 11.4>

feature -- Adding, removing, and checking associations
    put (new_value: VALUE; key: KEY) is
        --Insert an association of key and new_value into this dictionary.
    local
        association: ASSOCIATION [KEY, VALUE];
    do
        association.make;
        association.set_key (key);
        association.set_value (new_value);

        --Less trouble to go to off-left than to check for off-right.
        associations.move_off_left;
        associations.insert_on_right (association);
    end; --put
end --class DICTIONARY_LINEAR
```
Listing 14.2 Class DICTIONARY_LINEAR as an heir to DICTIONARY _LIST.


With the easy part out of the way,
we can attend to DICTIONARY_BINARY.
The first thing we need is to pick a better class for associations.
We need a subclass of LIST that allows us

1. To sort it;
2. To find its middle quickly; and
3. To specify subranges in it.

We do not have such a subclass,
but we can easily make one by inheriting from
one of the SORTABLE_LIST_ARRAY classes and adding features for zooming
the cursor directly to the middle.
Such a class is shown in Listing 14.3.
Inheritance is useful for enhancing our own classes,
not just those of vendors.

```Eiffel
class INSERTIONSORTABLE_INDEXED_LIST_ARRAY [ITEM -> COMPARABLE]
inherit
    INSERTIONSORTABLE_LIST_ARRAY [ITEM]

creation 
    make,
    make_capacity

feature
    lower: INTEGER is
        --The leftmost array index.
    do
        Result := items.lower;
    end; --lower

    upper: INTEGER is
        --The leftmost array index.
    do
        Result := items.upper;
    end; --upper

    move_to_index (index: INTEGER) is
        --Move the cursor to the item in position index.
    require
        index_in_range: lower <= index and index <= upper
    do
        cursor := index;
    end; --move_to_index

end --class INSERTIONSORTABLE_INDEXED_LIST_ARRAY
```
Listing 14.3 A sortable arrayed-based list class that makes binary searching possible.

This leads us to class `DICTIONARY_BINARY` in Listing 14.4.
The attribute associations is an `INSERTIONSORTABLE_INDEXED_LIST_ARRAY`.
Routine `locate` makes sure `associations` is sorted and starts the recursive binary search routine `binary_locate`.
Since we are restricted to use of an array version of list,
we may as well let the user set the dictionary’s capacity during creation,
so we provide a trivial make_capacity routine.
Routine put is similar to the one in the linear dictionary,
but it inserts items on the right end of the list,
since that is the cheap end for the array-based implementation.


```Eiffel
class DICTIONARY_BINARY [KEY -> COMPARABLE, VALUE] 
inherit
    DICTIONARY_LIST [KEY, VALUE]
    redefine
        associations,
        locate,
        put,
        is_equal
    end;

creation 
    make,
    make_capacity

feature {DICTIONARY_LINEAR}
    associations: INSERTIONSORTABLE_INDEXED_LIST_ARRAY [ASSOCIATION [KEY, VALUE]];
        --The list of associations.

    binary_locate (key: KEY; leftmost, rightmost: INTEGER) is
        --Move to the association with key if it is in the range
        --[leftmost, ..., rightmost], or off-right if it is not in the range.
    local
        middle: INTEGER;
    do
        if leftmost > rightmost then
            --It is not there.
            associations.move_off_right;
        else
            middle := (leftmost + rightmost) // 2;
            associations.move_to_index (middle);

            if key < associations.item.key then
                --Look for it in the left half of the range.
                binary_locate (key, leftmost, middle-1);
            elseif key > associations.item.key then
                --Look for it in the left half of the range.
                binary_locate (key, middle+1, rightmost);
            end;
        end;
    end; --binary_locate

    locate (key: KEY) is
        --Move associations' cursor to the association for key
        --or off-right if there is no such association.
    do
        if not associations.is_sorted then
            associations.sort;
        end;

        binary_locate (key, associations.lower, associations.lower+associations.length-1);
    end; --locate

feature --Creation and initialization
    make is
        --Create a new, empty dictionary.
    do
        !!associations.make;
    end; --make

    make_capacity (initial_capacity: INTEGER) is
        --Create a new, empty dictionary of capacity initial_capacity.
    do
        !!associations.make_capacity (initial_capacity);
    end; --make_capacity

feature --Adding, removing, and checking associations
    put (new_value: VALUE; key: KEY) is
        --Insert an association of key and new_value into this dictionary.
    local
        association: ASSOCIATION [KEY, VALUE];
    do
        !!association.make;
        association.set_key (key);
        association.set_value (new_value);

        --Insert at the cheap end.
        associations.move_off_right;
        associations.insert_on_left (association);
    end; --put

    is_equal (other: like Current): BOOLEAN is
        --Does this dictionary and other associate the same values
        --with the same keys?
    local
        association, other_association: ASSOCIATION [KEY, VALUE];
    do
        if size /= other.size then
            Result := false;
        else
            if not associations.is_sorted then
                associations.sort;
            end;

            if not other.associations.is_sorted then
                other.associations.sort;
            end;

            from
                Result := true;
                associations.move_off_left;
                associations.move_right;
                other.associations.move_off_left;
                other.associations.move_right;
            until
                Result = false or else associations.is_off_right
            loop
                association := associations.item;
                other_association := other.associations.item;

                Result := association.is_equal (other_association) and then
                          association.value.is_equal (other_association.value);
                associations.move_right;
                other.associations.move_right;
            end;
        end;
    end; --is_equal
end --class DICTIONARY_BINARY
```
Listing 14.4 Class DICTIONARY_BINARY, which uses binary search to locate keys.


A nice benefit of the sortable list implementation is that we can get a much more efficient implementation of `is_equal`.
Since duplicate keys are disallowed
(this is important because association comparisons only look at keys),
two equal association lists will align into parallel lists.
Then a single loop that compares the keys and associations pairwise can determine if the association lists are equal.

### 14.1.1 Performance Analysis

The linear search algorithm is O(N) in time:
If we charted its execution,
we would get a straight line of markers under the array.
Its space complexity is $O(1)$,
since it uses no variable-length object structures and no recursion.
What are the complexities of the binary search algorithm?

As the execution chart in Figure 14.1 shows,
at each level of recursion we visit one list position
(the one in the middle).
Each time we go down a level, 
we cut the problem in half.
We can do that $O(\log N)$ times before the list becomes empty,
so the time complexity is $O(\log N)$.

Since the recursion gets $O(\log N)$ levels deep and a constant amount of space is used at each level,
the space complexity is also $O(\log N)$.
However, unlike the sort algorithms in Chapter 13,
the binary search algorithm can be easily done nonrecursively,
with a single loop, resulting in $O(1)$ space complexity.

![plantuml ditaa diagram](https://img.plantuml.biz/plantuml/svg/SoWkIImgISaiIKnKqDNDozSjJYr8B4eioSpFW_8p4bFooukvj7L100T93C5Lew1WgA0098t0f368rDFJ0x4Ly10G9Nv05XNS03K21q2enAy4vXtSe2RPqT4Hhme5c6mDiMv28v2Km4t2Qo72rXfSJaIuYR19-1r6YflGNOVgi1g5dFnqOFm3HKWo2wlxo78LallWJYCbf0YuZaAJq1n6gKaeyQZDvP2Qbm8k7RW0)[source](https://editor.plantuml.com/uml/SoWkIImgISaiIKnKqDNDozSjJYr8B4eioSpFW_8p4bFooukvj7L100T93C5Lew1WgA0098t0f368rDFJ0x4Ly10G9Nv05XNS03K21q2enAy4vXtSe2RPqT4Hhme5c6mDiMv28v2Km4t2Qo72rXfSJaIuYR19-1r6YflGNOVgi1g5dFnqOFm3HKWo2wlxo78LallWJYCbf0YuZaAJq1n6gKaeyQZDvP2Qbm8k7RW0)

##### Figure 14.1 A worst case execution chart for the binary search algorithm.


### 14.1.2 Linked Implementation Is Useless

It would be easy to have a binary search dictionary that uses an indexed sortable linked list instead of an indexed sortable array-based list.
However, even if we are very, very clever about it,
moving to the middle of a range will take half as many steps as the length of that range.
(If we are not clever about it and just implement a “move to position *p*” feature as we did with the array, the performance gets even worse.)

As Figure 14.2 shows,
the time complexity of the linked implementation of the binary search algorithm is $O(N)$.

![](https://img.plantuml.biz/plantuml/svg/hPH12iCW44NtdcBsHQ7jliGBv0vI0yr6InIwyV3LcAIIr3Yn_OkFCeEyFwADiMAmihT20ALAKzCznI1ihzMqVmYfNuQSQ536CKOSm1d0-sNqQt36M5Z3ZiMMrg_-m30TaT6diz3Yizmvvx2HBzx0XPhR5XF5Q5YQbIKjyPWS3HOEGuD0EaQJHPhl7i5J83lEip0bKEZf5BZgQBxEgPOcGLgILMhridVL5kg_Pqg2aQPJSlpG725l)

[source](https://editor.plantuml.com/uml/hPH12iCW44NtdcBsHQ7jliGBv0vI0yr6InIwyV3LcAIIr3Yn_OkFCeEyFwADiMAmihT20ALAKzCznI1ihzMqVmYfNuQSQ536CKOSm1d0-sNqQt36M5Z3ZiMMrg_-m30TaT6diz3Yizmvvx2HBzx0XPhR5XF5Q5YQbIKjyPWS3HOEGuD0EaQJHPhl7i5J83lEip0bKEZf5BZgQBxEgPOcGLgILMhridVL5kg_Pqg2aQPJSlpG725l)

#### Figure 14.2 The binary search is O(J) in time for a linked list implementation. (The arrows indicate the search for the middle of each subrange.)

Given that the linear search is $O(N)$ too and much simpler,
binary search is useless for this implementation.
But there is a way to do binary search on linked structures in $O(\log N)$,
and we will study it in Chapter 15.

## 14.2 Hashing

While we are on the subject of array-based dictionaries,
let us indulge in some wishful thinking.
Binary search gives us $O(log N)$ performance,
which is the second best we have seen so far.
But suppose we had a function that took the key and in O(1) time resulted in the index at which the association with that key resides.
In goes the key, 
out comes the correct index-wouldn't it be nice?

Well, in extremely rare cases we are lucky enough to have a key for which
such a function exists.
For example, if we run a car dealership,
and we need to look up the technical characteristics of a car,
we may be able to rig up a function that converts a model name into a number between 1 and, say, 75
(or what ever the number of possible models is).
Then we just use an array of size 75,
and we get O(1) performance.
This is called a “**perfect hash function.**”

In general, 
we will not be able to find a perfect hash function for our keys.
An imperfect hash function is one that maps more than one key to the same array index.
For example, if our keys are “person” objects,
their years of birth could be used as the hash values.
This would schedule people born within the same year for the same array position.
Just how imperfect is this function?
If we need to keep track of historical figures,
it is pretty good.
If we are keeping track of this year’s class of kindergarten students,
then it is horrible:
It will send them all into two or three array positions.

So when we are hashing, we need to worry about two things:

1. Finding a hash function that results in the fewest collisions
(i.e., assigning a key to a position that is already occupied).

2. When there is a collision,
finding another place for the incoming association.

### 14.2.1 Choosing the Hash Function

If a function is to provide array indices,
its results must be integers within the index range of the array.
That means, for example,
that we cannot have it just generate 32-bit integers,
unless we want a 4 billion position array,
and have a system that can accommodate it.

However, if we can map our key to some integer,
then there is a common trick to cutting it down to size:
Divide that number by the length of the array,
and use the remainder as the index
(similar to the way we forced the indices to fit in the circular array implementation of queues in Chapter 9).
In fact, that is the most commonly used solution in situations where nothing is known about the keys.

How a key is converted to an integer depends on the class of the key.
It is done by the standard [^1] feature `hash_value`
(inherited from class ANY) which returns a nonnegative integer number.

[^1]: Actually, it is not in the standard at the time this is written, but is likely to be in its 1996 vintage.


For class `INTEGER` this feature is quite easy-just return the integer’s
value.
For other classes it may be trickier.
Since we have been using STRING keys in our examples,
you may want to look at your vendor’s implementation of hash_value in class STRING
(if its source code is available).
An easy thing to do is to add up the character codes of all the letters in the string.

Once the hash value is obtained,
the index is computed as the hash value modulo the length of the array provides the index.
For example, if the length of the array is 100,
then keys 9816104, 171970, 4904907, and 465404 will be assigned to indices 4, 70, 7, and 4, respectively
(thus, there is a collision).
Thus, if the array length is 100,
only the last two decimal digits of the number are used.
That cannot be helped,
it is the nature of the remainder operation;
besides, we only have 100 positions to fill in the array anyway.

We would like, however, to make sure that the numbers are distributed
among the array positions as evenly as possible,
to minimize the likelihood of collision.
We can control that by carefully choosing the array length.

Suppose we have a 12-position array
(indices 0 through 11, since we are using the remainder function).
Let us see how certain subsets of integers will map onto it,
starting with keys whose hash values are multiples of 5:

Here's the hash table translated into markdown format:

| Hash value | 0 | 5 | 10 | 15 | 20 | 25 | 30 | 35 | 40 | 45 | 50 | 55 | 60 |
|------------|---|---|----|----|----|----|----|----|----|----|----|----|----| 
| Index      | 0 | 5 | 10 | 3  | 8  | 1  | 6  | 11 | 4  | 9  | 2  | 7  | 0  |

We see that the hash values are assigned to distinct indices until we hit 60,
at which point the assignment cycle starts at 0 again.
But the period of this cycle is 12,
which is the length of the array
-we did not get a collision until the whole array was filled!
This is as good as it gets.

If we try the set of multiples of 7,
we get a similar situation:

# Hash Table

| Hash value | 0 | 7 | 14 | 21 | 28 | 35 | 42 | 49 | 56 | 63 | 70 | 77 | 84 |
|------------|---|---|----|----|----|----|----|----|----|----|----|----|----| 
| Index      | 0 | 2 | 9  | 4  | 11 | 6  | 42 | 1  | 8  | 3  | 10 | 5  | 0  |




But now let us look at multiples of 2:

| Hash value | 0 | 2 | 4 | 6 | 8 | 10 | 12 |
|------------|---|---|---|---|---|----|----|
| Index      | 0 | 2 | 4 | 6 | 8 | 10 | 0  |


This is a cycle with a much shorter period -only 6-
and half of the array is untouched!
But it gets worse.
With multiples of 3 we get a cycle period of only 4:

| Hash value | 0 | 3 | 6 | 9 | 12 |
|------------|---|---|---|---|----|
| Index      | 0 | 3 | 6 | 9 | 0  |

with 2/3 of the array wasted.
With multiples of 6 we get a cycle period of only 2:


| Hash value | 0 | 6 | 12 |
|------------|---|---|----|
| Index      | 0 | 6 | 0  |

And with multiples of 12 we get the shortest possible cycle period:


| Hash value | 0 | 12 |
|------------|---|----|
| Index      | 0 | 0  |


If we are looking at how multiples of $n$ behave with an array of length $M$,
the greater the common divisor of $n$ and $M$ is,
the shorter the cycle (culminating in a cycle period of 1 when $n = M$,
so $M$ is the greatest common divisor).
Thus we get the longest cycles when $n$ and $M$ are relatively prime.

This means that we should *always use prime numbers for the length of the
array*
-that way we will get the maximum cycle period for multiples of everything except $M$ itself.

### 14.2.2 One Way to Deal with Collisions

Having done our best to minimize collisions,
we need to accommodate the cases when they do occur.
There are two common ways to deal with them.
The first is to make the array track not associations,
but object structures containing associations.
For example,
we could use an `ARRAY[LIST_SINGLY_LINKED[ASSOCIATION[KEY,VALUE]]`.

When an association gets assigned to a position,
we just insert it into the list tracked by that position.
There is no collision because there is plenty of room at that position for all comers.

When a lookup is done, the hash value modulo table length
(“*M*” as we called it in the previous section)
tells us which list to search.
It is a linear search,
but if the hashing distributed the array indices evenly,
then each list will be roughly *N/M* in length.
If $M >= N$,
then the performance should approach $O(1)$:
Most lists would be either empty or have only one association each,
and the more “crowded” ones should still have only two or three associations in them.

The worst case is when all keys get mapped to the same index.
In that situation,
all associations fall into the same position in the hash table and the
search degenerates to a linear search.

Of course, a singly linked list is not the only kind of object structure we can use with the hash table’s array.
We could use more complicated structures with better search time complexity.
However, with a decent hash function and a sufficiently large table,
the lists should be short enough for the singly linked version to suffice.

### 14.2.3 Another Way to Deal with Collisions

The second method for accommodating collisions is to redirect the incoming
association to another position within the same array.
The algorithm for finding the available position is:

```
from
    position := key.hash_value \\ associations.length;
until
    associations.item( position) = Void
loop
    position := (position + offset) \\ associations.length;
end
```

The several variations on this theme have to do with how the value of *offset* is chosen.

The simplest thing to do is to use *offset=1*.
The hash function directs us to a position.
If that position is occupied, 
we try the one immediately to its right.
We keep moving one step to the right
(wrapping around the edge of the array)
until we find an empty spot.
During the search,
we start at the mapped position and keep looking to the right until we find an equal association.

This approach is OK,
but it has a vulnerable spot.
If several associations
are mapped into the same index,
they will cluster together right at that position and to its right.
Any associations mapped into that cluster will have to be placed at its end,
making the cluster longer yet.
Searches for those associations will be slowed down by collision of associations to the left of their intended positions.
(Consider what happens when a big game ends and all the spectators get
in their cars and onto the nearby highway;
not only is that particular highway
entrance crowded,
but so are several entrances downstream.)

For example, if five associations are mapped into position 0,
they will be placed into positions 0, 1, 2, 3, and 4.
If an association is then mapped to position 1,
then the loop will try to place it into positions 1, 2, 3, and 4 before managing to drop it into position 5.

The clustering problem can be eased a little by picking wider offsets.
Again, we want the offset to be relatively prime with respect to the array length,
otherwise we will get shorter period cycles,
but since we have picked a prime length,
we do not have to worry about that.

However, constant offsets do not solve the clustering problem completely.
Suppose we use *offset=2* and we hit position 0 with five associations.
They will be placed into positions 0,2,4,6, and 8.
Then if an association is mapped into position 1,
it is not affected-an improvement. 
But if one is mapped into position 2,
the loop will try positions 2, 4, 6, and 8 before finally placing the new
association into position 10
-no improvement at all.

A common solution to this problem is to make offset depend on the key.
We compute it by sending the key through a secondary hash function.
That function must be carefully written so that it does not result in a multiple of the array size,
lest the loop become infinite.
This pitfall is impossible to avoid
inside class `KEY`,
because the latter in general knows nothing about hash tables and their sizes.
Thus, the function is part of the hash table class:

```
offset := secondary_hash_value(key)

(and not “key.secondary_hash_value”).
    As long as associations.length is prime, a good secondary hash function is 
1 + key.hash_value \\ (associations.length - 1)
```

I refer you to Derick Wood’s *Data Structures, Algorithms, and Performance* [13, Section 9.3.2] for details.

### 14.2.4 Implementation Details

Since the array size is crucial to decent hash table performance,
it is essential to include feature make_capacity in the contract for class `HASH_TABLE`.
The default feature `make` can be provided,
as long as it calls `make_capacity` with a prime number.

There is no reason to make `HASH_TABLE` deferred:
A default implementation of `secondary_hash_value` can simply result in a constant (probably 1, 2, or 3).
Users can easily redefine it in a subclass to compute a value based on the key.

# Summary
This chapter introduced two methods for fast searching.
Binary search works on sorted arrays by comparing the median with the item sought.
The comparison eliminates one-half of the region as the possible place to find the item,
and the item is recursively sought in the other half.
This method’s time complexity is $O(\log N)$.

Hashing provides performance approaching O(1), if done carefully.
A function is applied to the key to get an array index.
Since several keys may get mapped to the same index,
it may be necessary to try for another index,
several positions away, and so on.
The distance between the successive attempts can be a constant, 
or determined by a secondary function of the key.

# Exercises
1. Write a nonrecursive version of routine `binary_locate`.
2.
a. Write classes `HASH_TABLE` and `HASH_TABLE_TESTER`.
b. Write a subclass of `HASH_TABLE` that uses the function

1 + key.hash_value \\ (associations.length - 1)

as the secondary hash function. Test it with HASH _TABLE_TESTER.

3. Write a hash table class that uses `SINGLY_LINKED_LIST`s to handle collisions.
