# Subclasses and Subcontracts

We now take a closer look at how classes may be related to each other.
In particular, we will study the inheritance relationship, and what effect it has on the
contract.
In light of that study, we will consider how inheritance can be used and when it should be avoided.
We will then revisit class PAIR, to make it a better heir to ANY.

## 4.1 A More Sophisticated PAIR Structure

The class /PAIR/ presented in Chapter 3 gives us a good general pair object structure.
But suppose we had a program that required something else of its pairs?

For example, we may need to keep track of which position in our object structure was modified last.
Thus, we need a feature, call it last_change, that returns
a 1 if the first position was changed last, and 2 if it was the second position.
If `last_change` is requested before anything changed
(i.e., after the pair is created but before either the first or the second position is set to track an object),
it should result in a 0.

But this need was not anticipated when PAIR was written.
We could hound the author of /PAIR/ to add the feature for us.
If we bought the class from another company, 
the reply we are likely to get is 

> “Sure, we will include it in the next release of the system.
> It is due to come out in the second quarter of next year, and the upgrade will cost a mere $99.95.
> Per user. Per byte.” 

You ask then, 

 “If you could be so kind as to send me the source code for this one little class, 
I could make this tiny little change myself....” 
To this they politely reply that they just cannot do that for these reasons:


1. It is against their company policy.
2. If they gave you the source, you could not really use it unless they gave you this and that and this other thing too, which is also against company policy.
3. Besides, their distribution and support system is not set up to send you all that stuff, because it is just such an unusual request.
4. Not that they think this could happen with you, but what if you screw up
something in their class, then call their support number, and they won't be
able to help you fix it because they don’t know what you had done, and they
don’t get paid to fix your bugs, and it would reflect poorly on them if people
think it’s their bug when it’s actually yours.
5. That is why it is against company policy.

Okay, okay, so I am exaggerating a little.
However, almost anybody who has ever tried to get a bug fix
—not to mention an enhancement, which is what we need—
out of a large software vendor is familiar with this scenario.

Fortunately, object-oriented programming gives us a way to get what we want without disturbing the original PAIR class.
Here is how we do it:

1. We define a new class—let us call it “ENHANCED_ PAIR.”
2. We proclaim ENHANCED_PAIR to be an heir to PAIR, thus inheriting its contract as well as all the guts and the smarts of it.
3. We add the feature last_change to ENHANCED_PAIR.
4. In our code that deals with pair objects, we create an ENHANCED_ PAIR object wherever we used to create a PAIR object.

The resulting class is shown in Listing 4.1.

```python
       $ cd $TESTDIR
       $ ./code-listing for ./ch4_code/enhanced_pair.e ./ch4_code/ch4_code.ecf
       note
         description: "Summary description for {ENHANCED_PAIR}."
         author: ""
         date: "$Date$"
         revision: "$Revision$"
       
       class
         ENHANCED_PAIR [ITEM1, ITEM2]
       
       inherit
       
         PAIR [ITEM1, ITEM2]
       
           redefine
             set_first, set_second
           end;
       create
         make
       feature
       
         last_change: INTEGER;
           -- 1 if the first position was changed last,
           -- 2 if the second,
           -- 0 if neither has been changed (i.e., both are void).
       
         set_first (an_item: ITEM1)
             -- Track an_item as first item.
           do
             first := an_item;
             last_change := 1;
           ensure then
             last_change = 1;
           end; -- set_first
         set_second (an_item: ITEM2)
             -- Track an_item as second item.
           do
             second := an_item;
       
             last_change := 2;
           ensure then
             last_change = 2;
           end
       
       end
```

Note that we do not rewrite the whole class:
We just add our new feature,
last_change, and redefine set_first and set_second to keep it correct.
All the other features are inherited from PAIR with no modification.
To test our new class, we can simply make a copy of PAIR_TESTER and fix it up to beENHANCED_PAIR_TESTER, as shown in Listing 4.2.


```python
       $ cd $TESTDIR
       $ ./code-listing for ./ch4_code/enhanced_pair.e ./ch4_code/ch4_code.ecf
       note
         description: "Summary description for {ENHANCED_PAIR}."
         author: ""
         date: "$Date$"
         revision: "$Revision$"
       
       class
         ENHANCED_PAIR [ITEM1, ITEM2]
       
       inherit
       
         PAIR [ITEM1, ITEM2]
       
           redefine
             set_first, set_second
           end;
       create
         make
       feature
       
         last_change: INTEGER;
           -- 1 if the first position was changed last,
           -- 2 if the second,
           -- 0 if neither has been changed (i.e., both are void).
       
         set_first (an_item: ITEM1)
             -- Track an_item as first item.
           do
             first := an_item;
             last_change := 1;
           ensure then
             last_change = 1;
           end; -- set_first
         set_second (an_item: ITEM2)
             -- Track an_item as second item.
           do
             second := an_item;
       
             last_change := 2;
           ensure then
             last_change = 2;
           end
       
       end
```
Listing 4.2 Class ENHANCED_PAIR_TESTER, built out of a copy of PAIR_TESTER.

All we had to do was modify the type of the local entity pair, and add the code that tests
the new feature last_change.

## 4.2 The “Can Act As a” Relationship

It is certainly convenient to inherit from a parent class all the features that are
already good enough to use with the heir class.[^1] 
But it was mentioned earlier that an heir inherits the parent’s contract too, 
which means that an object of © the heir class must be able to do everything that its ancestor class’s objects can,
and do it under the same circumstances, and do it at least as well.
A user may always substitute an heir’s object for an ancestor's object.

[1]: A common term for “heir class” is “subclass”; the parent class is frequently called the “superclass.”

Thus, by saying that one class is an heir of another,
we say that objects of the heir class can act as objects of the ancestor class.
For example, an `ENHANCED_PAIR` **can act as a** `PAIR`.[^2]

For instance, objects of class ENHANCED_PAIR must be able to pass the test routine of PAIR_TESTER, since PAIR objects do.
To do this test, we modify PAIR_TESTER in only one place: the line

```python
create pair.make
```

where we create a PAIR object and attach it to entity pair.
What we want to attach to pair instead is an ENHANCED_PAIR object.

The Eiffel way to specify what class to use when creating a new object is to
put that class’s name between the two braces marks. 

```python
create pair.make
```

In fact, is really just a shortcut for saying

```python
create {PAIR(LETTER,LETTER]} .pair.make
```

If you do not specify a class name between the “{...}”, 
then the class corresponding to the type of the entity is used.
In this case, since pair is of type `PAIR[LETTER,LETTER)]`, objects of class PAIR[LETTER,LETTER] are created by default.

However, since objects of class `ENHANCED_PAIR` can do whatever `PAIR`
objects can, it is perfectly safe and legal to create an `ENHANCED_PAIR [LETTER,LETTER]` object 
instead of the PAIR[LETTER, LETTER] object:

```python
create {ENHANCED_PAIR(LETTER,LETTER]}.pair.make;
```

The PAIR_TESTER class in Listing 4.3 is just like the one in Listing 3.6, 
but it tests an ENHANCED_PAIR object in its capacity as a PAIR object.
Note that the entity pair is still of type PAIR, not ENHANCED_PAIR.

[2]: Many object-oriented design texts state that the relationship is “...isa..."  instead of “... can act as a...” In Section 4.4 we discuss why that is an inaccurate description.

```python
       $ cd $TESTDIR
       $ ./code-listing for ./ch4_code/pair_runner.e ./ch4_code/ch4_code.ecf
       note
         description: "Summary description for {PAIR_RUNNER}."
         author: ""
         date: "$Date$"
         revision: "$Revision$"
       
       class
         PAIR_RUNNER
       
       create
         test
       feature
         test -- Test a PAIR.
           local
             pair: PAIR [LETTER, LETTER]
             letter1: LETTER
             letter2: LETTER
           do
             create {ENHANCED_PAIR [LETTER, LETTER]} pair.make;
       
             print ("New pair created.%N You should see (-void-,-void-)")
             print (pair);
             print ("%N");
             create Letter1.make ('a');
             pair.set_first (letter1);
             print ("First item set to ’a’.%N You should see’ (a,-void-)")
             print (pair);
             print ("%N");
             create Letter2.make ('b');
             pair.set_second (letter2);
             print (pair);
             print ("%NTestitem set to ‘’b’.%N You should see '’(a,b)’: done. %N")
           end
       
       end
```
Listing 4.3 Testing the ablity of ENHANCED_PAIR objects to act as PAIR objects.

## 4.3 Subcontracting: Obligations of the Heir

As the previous section illustrates, because an heir inherits the contract of its ancestor,
its objects may be called on to act as subcontractors for the ancestor.
Specifically, if in a given situation a user routine is allowed to request a feature
of an ancestor object
(i.e., that feature’s precondition is satisfied),
then it is also allowed to request that feature of an heir object in the same situation.
Therefore, if the heir redefines that feature, it may not add more restrictive preconditions to its part of the contract.

On the other hand, the subcontractor is certainly allowed to accept the job under circumstances that the contractor would have rejected.
For example, suppose you rent a dwelling from Olde Fashioned Rentals Corporation and the contract for the “accept my rent” feature
(if you may call it that)
says: “Rent is paid by check.” 
If Olde subcontracts the management of your abode to Plastiphile Property Management, Inc., 
they may modify the requirement in your favor:
“Rent is paid by check **or else** rent is paid by credit card.” 
You would not complain about that, would you?
If your regular routine is to pay by check, you will not be affected by the looser precondition.

Eiffel lets the heir class loosen the precondition of its heir for a routine by using a **require else** part.
Since you are not permitted to completely disregard the heir’s preconditions, 
a simple **require** part is not allowed in a redefined routine.

The opposite is true for postconditions.
If Olde promised you a specific
place to live as a postcondition of the “accept my rent” feature, 
Plastiphile will have to do at least that much.
They are not allowed to say “... **or else* you get a clock radio.” 
On the other hand, if they said “... **and then** you will have a place to park your car,” 
that would hardly be cause for litigation.

So the ensure part is not allowed in a redefined routine, but an **ensure then** part is.
For example, *ENHANCED_PAIR’s* `set_first` can add another promise to its part of the contract:

```python
ensure then
  last_change = 1;
```

To summarize, when an heir (the subcontractor) redefines a feature,

* Its precondition may be the same as (no require part at all) or more forgiving than (a **require else** part) what it was in the parent (the contractor); and

* Its postcondition may be the same as (no ensure part at all) or stricter than (an **ensure then** part) what it was in the parent.

## 4.4 When Subclassing Should Nof Be Used

It is tempting to call the “can act as a” relationship the “is a” relationship instead, and many texts do just that.
After all, an `ENHANCED_PAIR` is a `PAIR`, is it not?

Yes, it is.
But the “is a” relationship includes situations that the “can act as a” relationship excludes, and vice versa.
For example, a square is a rectangle, but a square cannot subcontract for a rectangle:
a rectangle may be asked to take on a 2:1 aspect ratio, but a square is incapable of doing that.
So, defining SQUARE as an heir to RECTANGLE is impossible.

On the other hand, a rectangle can do anything a square can do, 
so declaring RECTANGLE as an heir to SQUARE is perfectly reasonable.
Note, however, that while “a rectangle can act as a square” holds, it makes no sense to say that “a rectangle is a square.”

It is unfortunate that many object-oriented texts claim that the relationship between an heir and a parent is “is a.” That claim is just a really old but bad habit.
One of the “godfathers” of object-oriented programming is the discipline known as “semantic networks,” 
and connections between nodes of those networks were actually meant to indicate “is a” relationships.
(In computer science, as in many things, if something does not make sense, look for historical reasons.)

So, don’t worry about what is a what, and think in terms of subcontracting instead.

## 4.5 What PAIR Should Do As Subcontractor to ANY

So, we have written PAJR as an heir to the predefined class ANY.
Recall that we did not have much choice in the matter:
*every* programmer-written class in Eiffel inherits directly or indirectly from `ANY`.

So far, being an heir to `ANY` has been nothing but advantageous.
Since `ANY` defines out in its contract, all other classes are obligated to support it,
so we can write our PAIR’s out feature in terms of *ITEM1* and *ITEM2’s* out features.
We don’t know what results they'll provide, but we know they exist.

It has also eased our implementation:
Because `ANY` implements a *print*  feature that prints out the result of out,
we did not have to do anything to implement print in PAIR or LETTER.
With a good implementation of *out*,
no class needs to redefine print,
it can just inherit its implementation from *ANY*.

Thus, we took advantage of one inherited feature without redefining it,
and redefined another one.
We didn’t have to redefine *out*:
*ANY’s* implementation will result in something that represents the entities in the pair,
but it may not be particularly legible, will probably not be visually attractive,
and is certain not to look the way we expect a pair to look(**“(x,y)”**).

But print and out were not the only inherited features that we used:
We also used the entity *Void* and the feature *is_equal*.
What other features are in *ANY*, and how do we know what they do?
We may want to redefine some of them, just like we redefined out!

The answer lies in The Eiffel Library Standard [2].
Appendix B of this book reproduces the standard interface to ANY for easy reference.
A detailed narrative of how some of these features interact with each other appears in Section 13.3 of Reusable Software [6].

Note that some of *ANY’s* features are marked with the keyword **frozen**.
Heirs are not permitted to redefine those features.
Why? Well, observe that many of these are just features of convenience, like print.
For example,

`equal (a,b)`

is just a shortcut for
```python
(a = Void and b = Void)
or else
((a /= Void and b /= Void )and then a.is_equal (b))
```

so it saves you the trouble of making sure that is_equal is not applied to a void
entity, and defines two void entities as equal.
Since this shortcut is the same 
for all objects, there is never a reason to redefine equal
(which is why it is frozen).
If the way to compare two objects of a new class is different from the
inherited way, is_equal is the feature to redefine.

Another category of frozen features is that of features having names prefixed with *“standard_”*.
They are provided and frozen so that any heir class can get to ANY’s original way of doing things.
In this way, a class that normally uses a redefined *is_equal* can easily get to *ANY’s* version by using `standard_is_equal`.

Finally, there are features that are frozen because Eiffel relies on a specific method of their operation.
These include *default, tagged_out and do_nothing*.

Of what remains, besides some system-level stuff,
there are features that deal with object comparison and those that deal with object copying.
The two categories are intimately related:

* Shallow copying of an object results in an object that is shallowly equal to the original.
* Deep copying of an object results in an object that is deeply equal to the original.

Let us study them using PAIR as the example, and see if any of them needs to be redefined in PAIR.

## 4.5.1 Comparing Pairs

Two object structures are considered equal if they track the same items in the same order.
Let us see if we already have something like that in our inheritance from *ANY*.

*ANY* provides for two levels of comparisons: deep equality
(indicated by a “deep_” prefix in entity name)
and shallow equality (no prefix).
Two objects have shallow equality if each corresponding entity within them has the same value.
For example, PAIR objects a and b, are shallowly equal if and only if[^3]:

1. <a’s first> = <b’s first>, and
2. <a’s second> = <b’s second>.

Recall that since first and second are nonexpanded entities, the *=* means “track *the same* object,”
not “track an equal object.”
Thus, a shallow copy of a pair is another pair that tracks the same items in the same order
—which is just what we want!
We do not need to redefine is_equal.

Unlike shallow equality checking, deep equality does not stop at the level of the first object.
Instead, each pair of corresponding entities is checked for deep equality.
Thus, deep_equal (a,b) is true if and only if:

1. deep_equal (<a’s first>,<b’s first>), and
2. deep_equal (<a’s second>,<b’s second>).

We do not need to redefine that either.
In fact, comparing all object structures for deep equality is done the same way.
We will never have to redefine deep_equal.
However, we will soon encounter structures where the shallow equality is too shallow and will need to be redefined.

### 4.5.2 Copying Pairs

The section of ANY that lists duplication features requires some explanation.

The feature that does actual work is copy.
If anything needs to be redefined to support heir-specific copying, it is copy.
The deep duplication routines, deep_copy and deep_clone, are frozen
(and we would not want to mess with them anyway).
The rest of the features in this portion of ANY are just shortcuts that call on copy to do real work.
The command `a.copy (b)`

Copies all entities of object b into the corresponding entities of object a.
If b has entities that refer to nonexpanded objects, then only the references are copied,

[3]: avoid the notation “a.first” because it only makes sense when first is an exported
feature. In this case, all of PAIR’s entities are exported, but we will have other object
structures that keep some entities private. Equality checks apply to all entities, exported or private.
