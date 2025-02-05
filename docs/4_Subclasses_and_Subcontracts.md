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

[1]: A common term for “heir class” is “subclass”; the parent class is frequently called the “superclass.”