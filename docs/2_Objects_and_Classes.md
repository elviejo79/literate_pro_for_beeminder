# Objects and Classes

The language used in this text is Eiffel. 
We chose Eiffel because it offers far-reaching support for the methodology presented. 
It is easy to learn and will not distract the student from the task at hand. 
While one may use a less suitable language in the workplace, once the foundation is laid, 
adapting to the syntax and limitations or advantages of a different language should be relatively easy; 
it is just a matter of reading a good book on that language and working with it. 

We will introduce aspects of Eiffel as needed. 
Readers who are uncomfortable with this approach are referred to Robert Switzer's "Eiffel: An Introduction" [^10]. 
The definitive book on the language Eiffel (meant to be detailed enough for Eiffel compiler writers) is Bertrand Meyer's "Eiffel: The Language" [^5]. 
As an illustration, we will create a class of letters 
(the kind that make up words, not the kind that get delivered). 
We will use letter objects in later chapters, 
where our object structures will need "guinea pigs" to track.

[^10]: TODO
[^5]: TODO

## 2.1 Objects and Classes in Eiffel

How do we define objects? In Figure 1.4,  there were many objects, 
but they fell into two types: cars and lists. 
It would be madness to have to define every single car "from scratch," 
since they are all quite similar. 
What we do instead is define a whole class of *cars* by describing their common *features*. 
Features are the set of questions and actions that can be asked of an object. 
Cars have many features, 
so before we present a class definition, 
let us pick a more manageable example.
While we are at it,
we will create an object that we can easily use to test our object structures in the following chapters. 

For our purposes, 
a class of letters is very convenient 
(we can use it later as something to track with our object structures).
What can a letter object be asked?
As a start, it can be programmed as follows:


* To report the letter it stores as a character 
  (Characters are built into Eiffel,
  so they are off-the-shelf building blocks and donot need to be defined by us);
* To set the letter it stores to another character
* To report if it is upper case
* To report if it is lower case
* To identify its position in the alphabet
* To report a string representation of itself

The entire Eiffel definition of this class is presented in Listing 2.1. 
Note the naming and capitalization conventions: 

- Class names are all upper case. 
- The predefined entity /result is capitalized
    (we will encounter other predefined entities later). 
- Everything else is lower case. 
- Underscores are used to separate words within a name.


```python
      $ cd $TESTDIR
      $ ec -config ./2_code_examples/project.ecf -pretty ./2_code_examples/letter2.e | expand -i --tabs 2
      class LETTER
      
      inherit
        ANY
          redefine
            out
          end;
      creation
        make
      feature
        character: CHARACTER;
          --The character representation of the letter.
        make (initial: CHARECTER)
            --Create a new letter, load it with initial.
          require
          do
            character := initial
          end;
      
        set_character (new: CHARACTER)
            -- Change the letter to new.
          require (('a' <= new and new <= 'z') or ('A' <= new and new <= 'Z')) do
            character := new
          end;
      
        is_lower_case: BOOLEAN
            -- Is this a lower case letter?
          do
            Result := 'a' <= character and character <= 'z'
          end;
      
        is_upper_case: BOOLEAN
            -- Is this an upper case letter?
          do
            Result := 'A' <= character and character <= 'Z'
          end;
      
        alphabet_position: INTEGER
            -- Relative position in the English alphabet (A = 1).
          do
            if is_upper_case then
              Result := character.code - ('A').code + 1
            else
              Result := character.code - ('a').code + 1
            end;
          end;
      
        out: STRING
            -- String representation of this letter.
          do
            Result := character.out
          end;
      
      invariant
        either upper_or_lower: is_upper_case /= is_lower_case
      
      end
    
```

Eiffel is not case sensitive, 
so an Eiffel compiler will understand you if you write “Character” or “character” or even “CHaRaCHTeR” instead of the conventional “CHARACTER”
—but other Eiffel programmers may not.
Most software is written in multiprogrammer teams, 
and flaunting team coding conventions is an easy way to get fired.

In the text, 
**identifiers** (which is compilerese for “names”) 
are *italicized* (e.g., *character*) and 
**keywords** (“words defined for us by the compiler”) 
are shown in **boldface**  (e.g., **feature**).
When a compiler processes Eiffel code, 
it is usually all in one font, 
but some Eiffel code editors may offer this typesetting convention to programmers.

Everything between a “——” and the end of a line is a comment and is skipped by the compiler.
Semicolons (“;”) separate program statements. [^semicolons]

Let us now step through the LETTER example.
As promised, 
we restrict ourselves to those aspects of Eiffel’s syntax and semantics that are relevant to the subject at hand.
We will use the notation “\<marker\>” to indicate a placeholder for programmer-supplied code.


### 2.1.1 Class Declaration

The format of a class declaration is:

```python
class <class name>
inherit 
    <parent class name>
    <feature adaptations>
creation
    <names of features that can initialize objects of this class>
feature 
    <feature declarations>
invariant 
    <what must be true about any object of this class>
end
```

### 2.1.2 Redefining an Inherited Feature

In an object-oriented software system, 
classes of objects are related to each other by means of **classification**.
Briefly (we will study this in more detail in Chapter 4), 
one class may be an heir of another (the latter is known as the parent of the former).

An heir inherits all features from its parent class, 
and may provide its own, additional features.  
It may also provide a better way of implementing some of the features that it inherited.  
When that happens, 
Eiffel insists that we explicitly mention that fact in the `inherit` clause.  
Otherwise, the compiler will assume that we accidentally used a feature name that we already had, 
thanks to our generous parent.  

But what is this class `ANY` anyway, 
and why do we need to inherit its features?  
Well, we do not have much choice in the matter.  
`ANY` is the ancestor of all programmer-supplied classes in an Eiffel system: 
all classes we write will inherit, directly or indirectly, from `ANY`.  
If we omitted the whole `inherit ... redefine ... end` part, we would be inheriting everything from `ANY` by default.  
`ANY` provides many useful features, 
and this automatic inheritance will save us from writing a lot of code.  

For example, the `print` feature we will use in Listing 2.2 is inherited by `LETTER_TESTER` from `ANY`.  
One of the features that `ANY` provides is `out`, which reports the preferred character string representation of the object.  
That representation is used by the inherited feature `print` to display the object.  
Feature `out` will be redefined in most of the classes we write because we will want to customize it so that each object’s string representation is most obvious to the reader.  

### 2.1.3 Feature Declarations

The section headed with keyword **`feature`** lists features of objects of class `LETTER` that may be requested by other objects.  
There are two types of features: entities and routines.  
Class `LETTER` contains only one entity: `character`, which is a member of the predefined class `CHARACTER`.  
Entity declarations take the form:

```python
<entity name>: <class name>;
```

After a declaration `e: C`, we say that entity `e` is of type `C`.  
This means that `e` may keep track of objects that are members of class `C`.  

Routines themselves generally fall into two categories:  
1. The kind that modify the state of the object (commonly referred to as “procedures”).  
2. Those that compute and return a value without altering the object (“functions”).  

Routine declarations take the form:

```python
<routine name>(<parameter declarations>): <type of Result> is ——Brief description.
require
    <what must be true before this routine is invoked>
local
    <declarations of entities local to this routine>
do
    <steps to take to perform this routine>
ensure
    <what is promised to be true after this routine exits>
end; ——<routine name>
```

If the routine takes no parameters, omit `(<parameter declarations>)`.  
If it does not compute and return a value, omit `: <type of Result>`.  
Parameter declarations look just like entity declarations, but they do not declare new entities.  
They name values that are passed to the routine by the object that invoked it.  
The first value passed gets the first name, the second gets named with the second name, and so on.  

Class `LETTER` does not have routines that require more than one parameter.  
The invoking object is responsible for seeing that the value passed through a parameter is allowable for that parameter’s type.  

The Boolean expressions (called “assertions”) listed in the `require` section are known as the preconditions of the routine.  
The object that requests this feature must assure that all the preconditions are true.  
Otherwise, the whole program may crash or produce unpredictable results.  
If there are no preconditions, then the whole `require` section can be omitted.  

The `local` section can be used to introduce temporary entities to use in the `do` section of this routine.  
It is also omitted when no local entities are needed.  
The statements in the `do` section are performed when the routine is invoked.  
If the routine computes a value, it must assign that value to the predefined local entity `Result`, from where it will be passed by the Eiffel system back to the calling object.  

The `ensure` section states what must be true after the routine is executed.  
We will discuss it in detail in Section 3.1.1.  

### 2.1.4 The Class Invariant

The expressions listed in the class invariant must be true about any object of that class.  
They define what it means for an object of this class to be valid.  
A feature may make these assertions temporarily untrue while it is executing, but it must restore their truthfulness before it is finished.  

[semicolons]: Semicolons in Eiffel are optional in most situations.
However, the Eiffel style guidelines [5, Appendix A] recommend their use.*
