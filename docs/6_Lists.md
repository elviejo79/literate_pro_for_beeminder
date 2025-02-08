# 6 Lists

Lists are the first nontrivial object structure we will write.
In this chapter,
we will consider what a list is and does,
and then look at one variation of how it can do it:
by using an array.
In Chapter 7, we will do two more implementations.

Eiffel systems usually come with at least one LIST class;
we will be creating our own instead of using those.
Our version of LIST was inspired by their predecessor,
presented in [3],but it offers a slightly different interface.

## 6.1 What a LIST ls and What It Does
While an ARRAY keeps track of objects by an absolute position
(e.g., “the object at position 7”),
a LIST organizes them by relative position (“the object immediately to the right of this object”).
Positions in a *LIST* are *not* numbered.

To support this type of interface, we need to be able to, figuratively,
put a finger on a position in the list and say “I want *this* one!” How can we do that
without numbering the positions and specifying the number?
Consider a radio.
Nowadays, there are radio tuners where one can simply  punch in the frequency of a station
(e.g., “89.5”),
or even just its call letters (“KENW”).
That is the equivalent of just saying “object at position 7”
(well, position 89.5 in this case\).

Believe it or not, radios were not always like that.
They looked like the one shown in Figure 6.1.
A long strip of paper had the stations’ positions marked on it,
but they were so imprecise that the best one could use them for was educated guessing.
It was not possible to just point to a place on this rough scale and get the desired station.
Instead, there was a needle that claimed that if you interpolated between the nearest markings on the scale and figured out what number would appear right under the needle,
you would get the frequency of the carrier wave that was bringing you the noise you were hearing.
To select a different station, you turned a knob.

![Figure 6.1 A good old-fashioned radio](./a_good_old_fashioned_radio.png)
Figure 6.1 A good old-fashioned radio.

If you turned it clockwise, the needle would move to the right;
turning it counterclockwise would move the needle to the left.
You knew you were at a station when the proportion of music to noise was at its best.

In fact, the radio was perfectly operable without the scale:
just turn the knob to change stations in either direction.
Even if you found yourself in a strange city with a receiver in which the scale had fallen off,
you could still make perfectly good use of the radio:
Move the needle all the way to the left,
so that it is off the scale on the left side
(“off-left,” for short), then move it one station to the right,
see if you want to listen to it, and keep moving to the right,
one station at a time, until you find one you like.

We can use a similar user interface to navigate through a LIST:
We start out on the left side
(off-left), and move to the right until we are at the item we want
for whatever reason we want it.
We may end up going all the way offright.
Inside the LIST we also have a needle, but, being sophisticated computer scientists,
we call it a “cursor” instead of a “needle.”
(A **cursor** is something that indicates current position.)

### 6.1.1 Moving the Cursor

Thus, we start out with an external view of a LIST shown in Figure 6.2,
with features *move_left* and *move_right*.
The precondition for *move_left* is that we can be anywhere but off-left,
and for *move_right*, we can be anywhere but off-right.
To be able to specify these preconditions, 
and to give our user a way to check whether or not the cursor is off-left or off-right,
we supply Boolean features *is_off_left* and *is_off_right*.

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map a_list {
    make() =>
    move_left() =>
    move_right() =>
    cursor *-> an_item02
}

a_list *-> an_item01
a_list *-> an_item02
a_list *-> an_item03
a_list *-> an_item04

@enduml
```
Figure 6.2 External view of a LIST object,
take 1: obvious movement routines.
(This one tracks four items, the cursor is on the second one.)

```python
class LIST [ITEM]
create make
feature
    is_off_left:BOOLEAN is
        --Is the cursor off-left?
    do

    end;

    is_off_right: BOOLEAN is
        --Is the cursor off-right?
    do

    end;

    move_left is
        --Move the cursor one step to the left.
    require
        not_off_left:not is_off_left;
    do

    ensure
        not_off_right: not is_off_right;
            --The cursor is one step to the left of where it was.
    end;

    move_right is
        --Move the cursor one step to the right.
    require
        not_off_right: not is_off_right;
    do

    ensure
        not_off_left:not is_off_left;
            --The cursor is one step to the right of where it was.
    end;

    invariant
        not_both_off_left_and_off_right:not(is_off_left and is_off_right\);
end;
```
Listing 6.1 Definition of class LIST, take 1: essential movement routines.


This leads us to the skeleton in Listing 6.1.
Note that we have not yet committed ourselves to deciding whether is_off_left and is_off_right will be functions or entities:
That is an implementation decision.
These four routines are all the user needs to move around the list.
However, there are two other movements that are often useful:
moving all the way off-left and moving all the way off-right.
We do not have to provide them, because the user can simply use what we already offer in a loop
(we will discuss Eiffel loops in detail in Section 6.3.3),
for example:

```python
from
until the_list.is_off_left
loop
    the_list.move_left;
end
```

Yet, for convenience and efficiency,
we can provide routines *move_off_left* and *move_off_right* that do the job.
These features are common enough that by supplying them in class LIST we can save users from repeating loops like the
preceding one in their code,
thus making the whole system easier to maintain and debug.

```python
move_off_left is
    --Move the cursor to the off-left position.
    do

    ensure
        off _left: is_off_left;
    end;

move_off_right is
    --Move the cursor to the off-right position.
    do

    ensure
        off_right:is_off_right;
    end;
```
Listing 6.2 Additional movement routines for the definition of class LIST.

Besides, when we get to implementing them, we will find that we can do it much more efficiently than stepping through the whole list.
(Even in the radio analogy, one can just spin the knob to the left until the needle stops off-left there is no need to stop at every station on the way!)

Thus, we add the routines in Listing 6.2 to the skeleton in Listing 6.1,
giving us the external view in Figure 6.3.


```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map a_list {
    make() =>
    move_left() =>
    move_right() =>
    move_off_left() =>
    move_off_right() =>
    is_off_left =>
    is_off_right =>
    cursor *-> an_item02
}

a_list *-> an_item01
a_list *-> an_item02
a_list *-> an_item03
a_list *-> an_item04

@enduml
```
Figure 6.3 External view of a LIST object, take 2: all features that support movement.

### 6.1.2 What an Empty LIST Looks Like
Having  described  how *move_left, move_right, move_off_left, move_off_right, is_off_left,* and *is_off_right* interact,
we can specify what an empty *LIST* looks like. If a LIST is empty, then:

1. There are no items in it;
2. It is either off-left or off-right (since there are no items for the cursor to be on);
3. If it is off-left and *move_right* is requested, it will become off-right; and
4. If it is off-right and *move_left* is requested, it will become off-left.

The four features that are most affected by these observations are *make*,
since it has to make a new empty list; *is_empty*, 
which reports if the list is empty; *wipe_out*, which empties a list;
and *length*, which reports how many items are in the list
(the first observation could be written as “length = 0”).

Before we use these properties in pre- and postconditions of specific routines,
let us see if any of them relate to a *LIST* object as a whole,
so that we can list them in the class invariant.
Since the invariant is a Boolean expression,
it can only contain requests of features that are entities or functions
(and not procedures, since procedure calls cannot appear inside an expression).
This restriction eliminates from consideration the *move_...*
features and leaves *is_off_left, is_off_right, is_empty,and length*.
Indeed, these are related for all objects,
so we upgrade the class invariant to the following:

```python
invariant
    not_both_off_left_and_off_right: not(is_off_left and is_off_right\);
    not_on_item_if_empty: is_empty implies (is_off_left or is_off_right\);
    empty_iff_zero_length:is_empty = (length = 0\);
    length_not_negative: length >= 0;
```

Now we can look at postconditions of make.
The first and most obvious one is that the list is empty.
According to the class invariant,
this automatically means that its length is zero.
But is it off-left or off-right? 
We must either make a choice and specify it in the contract,
or not specify our choice at all,
thus forcing the user to do an explicit *move_off_left or* *move_off_right* right after the make.
Since any choice we make in the first option is arbitrary,
the second option is the most general one.
However, having make leave the new *LIST*
object in an unknown state makes me nervous,
so let us choose *is_off_left* as a postcondition of *make*.

For consistency, we make the same choice for *wipe_out*.
This adds the features in Listing 6.3 to the class skeleton.

```python
make is
    -- Initialize to get an empty, off-left list.
    do

    ensure
        empty:is_empty;
        off _left:is_off_left;
    end;

    wipe_out is
        --Make this list empty and off-left.
    do

    ensure
        empty:is_empty;
        off _left:is_off_left;
    end;

is_empty: BOOLEAN is
    --Is this list empty?
    do

    end;

length: INTEGER is
    --The number of items currently in this list.
do

end;
```
Listing 6.3 Routines that deal with an empty list.

### 6.1.3 Moving Items In and Out of the Lists

To add a new item to the list,
we insert it near the cursor.
We cannot insert it exactly *under* the cursor,
since there is something there already:
either an item, or an off-left or off-right delimiter.
We can, however, insert the new item immediately to the left or immediately to the right of the cursor.
Not knowing 

whether the insert-on-left or insert-on-right behavior will be more convenient to our user,
we will provide both features: *insert_on_left and insert_on_right*.

Of course, restrictions apply to when these features may be requested:
One cannot insert to the left of an off-left cursor or to the right of an off-right cursor;

and it is impossible to insert into a list that is already full
(we will need to provide an is_full feature to make the latter an enforceable precondition).
Finally, we need to specify what happens to the cursor after the insertion:
Does it stay with the same item,
or move to the new one?
Let us make it stay with the same item.
The skeleton of these features is shown in Listing 6.4.

Feature delete deletes the item under the cursor from the list.
For this to work, the cursor can be neither off-left nor off-right.
Also, it has to move a step either to the left or to the right,
because it cannot stay with the deleted item; 
since the choice is, once again, arbitrary, we will move it a step to the right.
This routine’s skeleton is also shown in Listing 6.4.

```Eiffel
is_full: BOOLEAN is
    --Is there no room in this list for one more item?
do

end;

insert_on_left (new_item:ITEM)is
    --Insert new_item to the left of the cursor.
require
    not_full: not is_ full;
    not_off_left: not is_off_left;
do

ensure
    one_more_item:length = old length + 1;
        --The cursor is on the same item as it was before.
end;

insert_on_right (new_item: ITEM) is
    --Insert new_item to the right of the cursor.
require
    not_full: not is_full;
    not_off_right: not is_off_right;

ensure
    one_more_item: length = old length + 1;
        --The cursor is on the same item as it was before.
    end;

delete is
    --Remove the item under the cursor from the list.
require
    not_off_left:not is_off_left;
    not_off_right:not is_off_right;
do

ensure
    one_less_item:
    length = old length - 1;
        ---The cursor is on the item to the right of the deleted one.
end;


item: ITEM is
    --The item under the cursor.
require
    not_off_left: not is_off_left;
    not_off_right: not is_off_right;
do

end;
    --item
replace (new_item:ITEM) is
    --Replaces the item under the cursor with new_item.
require
    not_off_left:not is_off_left;
    not_off_right:not is_off_right;
do

ensure
    item_replaced:item = new_item;
    length_unchanged:length = old length;
end;
```
Listing 6.4 Routines that move items in and out of the list.


Note how the pre- and postconditions and the class invariant cooperate:
It is not necessary to state “**not** is_empty” in the precondition of delete,
since the conjunction of assertions `not_off_left` and `not_off_right`
in the precondition and `not_on_item_if_empty` in the invariant is logically equivalent to “not is_empty.”

Similarly, it would have been redundant to state “not is_empty” in the postcondition of insert_on_left and insert_on_right,
since the conjunction of `length_incremented` with `length_not_negative` and `empty_iff_zero_length` is equivalent to “not is_empty.”

If the user needs to replace an item that is under the cursor with a new one,
the following combination of steps can be taken:

```python
the_list.delete;
the_list.insert_on_left (new_item);
```

However, it is both nice and more efficient to provide a routine to replace the item,
so we added its skeleton to Listing 6.4.

Finally, we need a function that returns to the user the item that is under the cursor.
We will simply call it item, as shown in Listing 6.4.

#### 6.1.4 The String Representation

Next, we provide the routine out,
which returns the string representation of its object.
Among other things, it will allow the user to say “print (the_list)”
and get consistent and meaningful output.
For a list, we will have out result in a string of the form
"< <1st item>.out <2nd item>.out ...<last item>.out >"

As we did with class `PAIR`, we allow void items into the list,
and replace them with "-void-" in out’s result.

### 6.1.5 Comparing and Duplicating

As usual, we provide the is_equal feature.
Two lists are equal if they keep track of the same (not just equal) items in the same order.
We do not insist that their cursors match too-for that we provide a separate cursor_matches feature,
which determines whether the two lists’ cursors are the same number of steps away from the left edge of their respective lists.
(We have to measure the dis tance from a specified end of the list,
since the lists may not be of the same length.)

A copy of a list is a new list that is interchangeable with the original.
That means that the copy and the original are equal (but not the same list),
and their cursors match. As we discussed in Chapter 4, only *copy* needs to be redefined;
clone calls it to do the copying.

We add these skeletons to the class,
as shown in Listing 6.5.

```Eiffel
out: STRING is
    --Returns "< <lstitem>.out...<last item>.out >".
do

end;

is_equal (other: LIST): BOOLEAN is
    --Do this list and other keep track
    --of the same items in the same order?
do

end;

cursor_matches (other: like Current): BOOLEAN is
    --Is this list’s cursor the same distance
    --from off-left as other’s cursor?
do

end;

copy (other:like Current) is
    --Copies other onto Current.
do

ensure then
    copy_same_cursor: cursor_matches (other);
end;
```
Listing 6.5 String representation, comparison and copying features.

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map a_list {
    make() =>
    move_left() =>
    move_right() =>
    is_empty =>
    item => 
    move_off_left() =>
    move_off_right() =>
    is_full =>
    copy() =>
    insert_on_left() =>
    insert_on_right() =>
    cursor_matches =>
    delete()=>
    whipe_out()=>
    length
    cursor *-> an_item02
}

a_list *-> an_item01
a_list *-> an_item02
a_list *-> an_item03
a_list *-> an_item04

@enduml
```
Figure 6.4 Complete outside view of a LIST object.

### 6.1.6 The Contract

This concludes our specification of a LIST.
The resulting outside view is shown in Figure 6.4.
Putting all these skeletons together, we get the contract.
To save printing space, we present it after discussing deferred classes in the next section.

### 6.2 How a LIST Does What It Does: Multiple Implementations
The `LIST` is the first object structure for which we will provide multiple implementations.
First,let us address the logistics of doing that.

One way to do multiple implementations is to have a copy of the class LIST for each implementation,
and simply compile in the one we want to use. 
The problem with this approach is that if we do make changes in the interface
(the contract),
we will have to remember to make them in all three versions.
Alas, experience shows that human memory is not a tool suitable for keeping multiple versions of software synchronized.

### 6.2.1 Using a Deferred Class to Keep the Contract

Instead, what we can do is set up a little hierarchy of classes.
At the top will be a deferred class called “LIST 1”,
which will be the keeper of the contract, but will have no implementation. 
For each implementation, we will create a subclass of LIST.
As subcontractors, objects in those classes will have to follow contracts that are compatible to LIST objects
(see the section on subcontracting).

The resulting class LIST is shown in Listing 6.6.
While we were at it, we reorganized the routines under several **feature** sections.

```Eiffel
deferred class LIST [ITEM] inherit
    ANY
        undefine --to make them deferred
            out, is_equal, copy
        redefine --to add comments or improve the contract
            out, is_equal, copy
    end;

feature --Creation and initialization
    make is
        --Initialize to get an empty, off-left list.
    deferred
    ensure
        empty: is_empty;
        off _left: is_off_left;
    end;

feature -- Moving through the list
    move _left is
        --Move the cursor one step to the left.
    require
        not_off_left: not is_off_left;
    deferred
    ensure
        not_off_right: **not** is_off_right; --The cursor is one step to the left of where it was.
    end;

move_right is
    --Move the cursor one step to the right.
    require
        not_off_right: not is_off_right;
    deferred
    ensure
        not_off_left: not is_off_left; --The cursor is one step to the right of where it was.
    end;

move_off_left is
    --Move the cursor to the off-left position.
deferred
ensure
off _left:
is_off_left;
end;
--move_off_left
move_off_right is
--Move the cursor to the off-right position.
deferred
ensure
off_right:
is_off_right;
end;
--move_off_right
is_off_left:
BOOLEAN is
--Is the cursor off-left?
deferred
end;
--is_off_left
is_off_right:
BOOLEAN is
--Is the cursor off-right?
deferred
end;
--is_off_right

feature

-- Moving items into and out of the list

insert_on_left
(new_item:
ITEM) is
--Insert new_item to the left of the cursor.
require
not_full:
not is_full;
not_off_left:
not is_off_left;
deferred
ensure
one_more_item:
length = old length + 1;
---The cursor is on the same item as it was before.
end;
--insert_on_left

insert_on_right
(new_item:
ITEM) is
--Insert new_item to the right of the cursor.
require
not_full:
not is_ full;
not_off_right:
not is_off_right;
deferred
ensure
one_more_item:
length = old length + 1;
--The cursor is on the same item as it was before.
end;
---insert_on_right

delete is
--Remove the item under the cursor from the list.
require
not_off_left:
not is_off_left;
not_off_right:
not is_off_right;
deferred
ensure
one_less_item:
length = old length - 1;
--The cursor is on the item to the right of the deleted one.
end;
--delete

Wwipe_out is
--Make this list empty and off-left.
deferred
ensure
empty:
is_empty;

off _left:
is_off_left;
end;
--wipe_out
replace
(new_item:
ITEM) is
--Replaces the item under the cursor with new_item.
require
not_off_left:
not is_off_left;
not_off_right:
not is_off_right;

deferred
ensure
item_replaced:
item = new_item;
length_unchanged:
length = old length;
end;
---replace
item:

ITEM is
--The item under the cursor.

deferred
end;
--item

feature ---Sizing
is_empty:
BOOLEAN is
--Is this list empty?
deferred
end;
--is_empty
is_full:
BOOLEAN is
-~-Is there no room in this list for one more item?

deferred
end;
--is_full

length:
INTEGER is
-~The number of items currently in this list.
deferred
end;
--length
feature --Comparisons and copying
is_equal
(other:
like Current):
BOOLEAN is
--Do this list and other keep track
--of the same items in the same order?
deferred
end;
--is_equal
cursor_matches
(other:
like Current):
BOOLEAN is
--Is this list’s cursor the same distance

--from off-left as other’s cursor?
deferred
end;
--cursor_matches

copy
(other:
like Current) is
--Copies other onto current.
deferred
ensure then
copy_same_cursor:
cursor_matches
(other);
end;
--copy
feature --Conversions
out:
STRING is
--"< <1st item>.out ...
<last item>.out >".

deferred
end;
---out
invariant

not_both_off_left_and_off_right:
not
(is_off_left and is_off_right);
not_on_item_if_empty:
is_empty implies
(is_off_left or is_off_right);
empty_iff_zero_length:
is_empty =
(length = 0);
length_not_negative:
length >= 0;
end --class LIST
```
Listing 6.6 Deferred class LIST with the contract.

## 6.3 An Implementation Using an ARRAY
In our first implementation,
we use an ARRAY object inside the LIST object to keep track of the items.
Recall that in Eiffel, ARRAY objects are resizable,
but the resizing can be very expensive.
Thus, we want to avoid automatic resizing:
Chances are that if the user picked the array implementation,
they know the maximum size they will need.
All we have to do is provide a way for them to specify the list’s capacity when they create it.

For compatibility with the contract,
we will have a `make` routine with no parameters that picks its own capacity.
In addition, we will provide routines `make_capacity` and `resize` that take capacity as a parameter,
allowing our user to specify and explicitly (since it is expensive) change the capacity of a list.

Now that we have decided to use an array of a given capacity (let us name it “items”)
and that the capacity may change during execution
(if the user calls `resize`),
we know that we need an entity capacity,
whose value is the current capacity.
Also, since we will not be using the entire array all of the time,
we need an entity to keep track of the current length of the list-but we already have it:
We can use the feature `length` that we inherited from class LIST.
Thus, the items in the list may be accessed as `items.item(1),...,items.item(length)`.
The current position of the cursor is just a number in the range `[1,...,length]`,
and we will create an entity called “cursor” to hold it.
This gives us the internal view of a list as shown in Figure 6.5.

We now have enough information to get started on writing the code, in particular:
to redefine inherited features is_empty and is_full;
to define new private features `items` and `cursor` and a new public feature capacity as entities;
and to define the inherited feature length as an `INTEGER` entity.

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map a_list {
    make() =>
    move_left() =>
    move_right() =>
    is_empty =>
    item => 
    move_off_left() =>
    move_off_right() =>
    is_full =>
    out =>
    is_off_left =>
    is_off_right =>
    is_equal =>
    delete() =>
    insert_on_left() =>
    insert_on_right() =>
    cursor_matches =>
    copy() =>
    whipe_out()=>
    make_capacity()=>
    resize()=>
    capacity => 5
    cursor => 2
    length => 4
    items =>
    1 *-> an_item01
    2 *-> an_item02
    3 *-> an_item03
    4 *-> an_item04
    5 =>
}

@enduml
```
Figure 6.5 The internal view of a LIST_ARRAY object.
This particular list is of capacity 5,  has 4 items in it
(in positions 1 through 4),
and the cursor is on the item in position 2.

### 6.3.1 Off-Left, Off-Right, and Empty LIST

Before we can write make, though, we need to visualize the empty LIST_ARRAY.
It would have some capacity; the length would be 0; and the cursor
would be either off-right or off-left ... for which we have no position numbers!
How do we indicate “off-left” and “off-right?”

To answer that question, we need to first implement move_left and move_right.
Then, using move_left when the cursor is on the leftmost item 
(position 1 in this implementation)
should yield an off-left cursor;
similarly, using move_right when the cursor is on the rightmost item
(position length) should give us an off-right cursor.

To move a cursor one step to the left,
we simply need to decrement the cursor entity,
and increment it to move one step to the right.
Now we see that the list is off-left when cursor = 0 and off-right when cursor = length + 1,
so the range of the cursor entity is actually `[0,...,length + 1]`.

### 6.3.2 Creating a LIST
Now we are ready to write make and make_capacity:
They need to create an object that looks like the one in Figure 6.6.
In fact, the implementations of *resize, is_off_left,is_off_right, move_off_left, and move_off_right*
also fall into place.
The result is the early version of class LIST_ARRAY, 
which is shown in Listing 6.7.

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map a_list {
    make() =>
    move_left() =>
    move_right() =>
    is_empty =>
    item => 
    move_off_left() =>
    move_off_right() =>
    is_full =>
    out =>
    is_off_left =>
    is_off_right =>
    is_equal =>
    delete() =>
    insert_on_left() =>
    insert_on_right() =>
    cursor_matches =>
    copy() =>
    whipe_out()=>
    make_capacity()=>
    resize()=>
    capacity => 5
    cursor => 0
    length => 0
    items =>
    1 =>
    2 =>
    3 =>
    4 =>
    5 =>
}

@enduml
```
Figure 6.6 An empty LIST_ARRAY object of capacity 5.
This one is off-left, as would be made by make according to its postcondition.

```Eiffel
class LIST_ARRAY [ITEM] inherit
LIST ITEM]
creation make,
make_capacity
feature {LIST_ARRAY} --Visible only to similar lists
items:
ARRAY
(ITEM);
--The array tracking the items.
cursor:
INTEGER;
--Index within items of the item under the cursor.
feature --Creation,
initialization,
resizing

make is
--Initialize to get an empty,
off-left list
--of default capacity.
do
make_capacity
(100);
--Default capacity.
end;
--make

make_capacity
(initial_capacity:
INTEGER) is
--Initialize to get an empty,
off-left list
--of capacity initial_capacity.

require
initial_capacity >= 0;

do
capacity := initial_capacity;

"items.make
(1,initial_capacity);
--First item is always at index 1.
length := 0;
--Start out empty.
cursor := 0;
--Start out off-left.
end;
--make_capacity

resize
(new_capacity:
INTEGER) is
--Resizes the list to new_capacity.
Could be very expensive.
require
new_capacity > = 0;

do
capacity := new_capacity;

items.resize
(1,
new_capacity);
--First item is always at index 1.
--May have to truncate this list to fit the new array.
if cursor > capacity+1 then
cursor := capacity + 1;
end;

if length > capacity then
length := capacity;
end;

end;
--resize
feature --Sizing
capacity:
INTEGER;
--Current capacity.
length:
INTEGER;
--The number of items currently in this list.
is_empty:
BOOLEAN is
--Is this list empty?
do
Result := length = 0;
end;
--is_empty
is_full:
BOOLEAN is
-~Is there is no room in this list for one more item?
do

Result := length = capacity;
end;
--is_full
feature -- Moving through the list
move_left is
--Move the cursor one step to the left.
do
cursor := cursor - 1;

end;
--move_left
move_right is
--Move the cursor one step to the right.
do
cursor := cursor + 1;

end;
--move_right
move_off_left is
--Move the cursor to the off-left position.
do
cursor := 0;

end;
--move_off_left
move_off_right is
--Move the cursor to the off-right position.
do
cursor := length + 1;
end;
--move_off_right

is_off_left:
BOOLEAN is
--Is the cursor off-left?
do
Result := cursor = 0;
end;
--is_off_left
_ts_off_right:
BOOLEAN is
--Is the cursor off-right?
do
Result := cursor = length+1;
end;
--is_off_right
invariant
capacity_not_negative:

0 <= capacity;

length_in_range:
length <= capacity;
cursor_in_range:
0 <= cursor and cursor <= length+1;
good_array:
items /= Void and then
items.count = capacity and items.lower = 1;
end -~class LIST _ARRAY
```
Listing 6.7 Initial sketch of class LIST_ARRAY:
features dealing with initialization, sizing, and movement through lists.

Particular care has to be taken with resize.
What do we do when the new capacity is smaller than the list’s current length?
There are two options:

1. No problem, just truncate the list; or
2. This is an error.

This should be discussed with the user.
If the first option is preferred,
then the implementation of resize used in Listing 6.7 is appropriate:
just truncate the list to fit the smaller capacity.

On the other hand, if it is an error to remake the list into one too small to
continue tracking the same items, then the precondition “new_capacity>=length”
must be added to the description of resize in LIST_ARRAY’s contract.
(This will not disturb LIST’s contract, since resize is not mentioned there at all.
A user who relies on LIST’s contract for list creation will not attempt to resize it.)

The invariant in Listing 6.7 is different from invariants we have seen before,
in that it talks about hidden features: cursor and items.
This is known as an **implementation invariant**.
When the program short extracts the interface of this class,
it leaves out assertions that talk about hidden features
(we do not want to tie our hands by giving out details of our current implementation, do we?).
They are not part of the contract; they are just safety checks we put in for our own benefit.
Our user will never see them (unless we show him or her our source code).

### 6.3.3 Inserting and Deleting ITEMs
With move_left and move_right,
we started with a routine that would work in the middle of the list,
and then adapted the internal object structure so that the same routines work at both ends
(thus defining “off-left” and “off-right”).
We will use the same strategy with insert_on_left, insert_on_right, and delete.

Let us consider insert_on_left first. We start with the list in Figure 6.7a.
To insert new_item to the left of the cursor, we need to make room for it.
The easiest way to do this is to “smudge” the object references by one position to the right,
as shown with the arrows.
Great care must be taken in the order in which this copying to the right is done:
If we start with cursor and copy its item to the right,
then we will lose the connection to the item that was on the right of the cursor!
We will end up with the cursor’s item smudged all the way to offright.
Instead, we must copy the last item’s reference one position to the right,
then the one before it, then the one before it, and so on, as shown in the figure.
This results in Figure 6.7b.
Finally, we attach new_item to the slot we made available,
giving us Figure 6.7c.

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map Current {
    capacity => 5
    cursor => 2
    length => 4
    items => (an arary)
    1 *-> an_item01
    2 *-> an_item02
    3 *-> an_item03
    4 *-> an_item04
    5 =>
}
@enduml
```
a. The order of copying needed to make room for new_item.

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04

map Current {
    capacity => 5
    cursor => 2
    length => 4
    items => (an arary)
    1 *-> an_item01
    2 *-> an_item02
    3 *-> an_item02
    4 *-> an_item03
    5 *-> an_item04
}
@enduml
```
b. Room has been made for new_item to the left of cursor.

Figure 6.7 Responding to request “insert_on_left(new_item)”.
(The object’s routines are still there, they were omitted to save page space.)

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04
object an_item05

map Current {
    capacity => 5
    cursor => 2
    length => 4
    items => (an arary)
    1 *-> an_item01
    2 *-> an_item05
    3 *-> an_item02
    4 *-> an_item03
    5 *-> an_item04
}
@enduml
```
c. Item new_item is in the correct place. Current

```plantuml
@startuml
object an_item01
object an_item02
object an_item03
object an_item04
object an_item05

map Current {
    capacity => 5
    cursor => 3
    length => 5
    items => (an arary)
    1 *-> an_item01
    2 *-> an_item05
    3 *-> an_item02
    4 *-> an_item03
    5 *-> an_item04
}
@enduml
```
d. A promise is a promise


Are we done? Well, let’s check the postconditions:

1. length = old length + 1 (oops!)
2. --The cursor is on the same item as it was before (oops again!)

We are not done yet.
We need to increment /ength to keep up with the new list length,
and increment cursor to keep it at the same item as it was before.
This takes us into Figure 6.7d.
Now are we done?
That depends on whether we are still obeying the class invariant
(otherwise, we cause the list to be invalid).
A check of the class invariant shows that it was not affected by these changes.

Knowing what needs to be done, we write the Eiffel routine `insert_on_left`,
as shown in Listing 6.8.

The repetitive copying of object references within the array is done using
the Eiffel **loop** statement.
Its form is[^1]

```Eiffel
from
    <things to do before the loop starts>
until
    <exit condition>
loop
    <things to do repetedly until the exit condition is true (loop body)>
end
```

[1]: This is a simplified form of loop. The complete form is presented in Section 12.2.1.

