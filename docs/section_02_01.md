## 12 OBJECT STRUCTURES

Eiffel is not case sensitive, so an Eiffel compiler will understand you if you write “Character” or “character” or even “CHaRaCHTeR” instead of the conventional “CHARACTER”—but other Eiffel programmers may not.
Most software is written in multiprogrammer teams, and flaunting team coding conventions is an easy way to get fired.

In the text, **identifiers** (which is compilerese for “names”) are *italicized* (e.g., *character*) and **keywords** (“words defined for us by the compiler”) are shown in **boldface** (e.g., **feature**).
When a compiler processes Eiffel code, it is usually all in one font, but some Eiffel code editors may offer this typesetting convention to programmers.

Everything between a “——” and the end of a line is a comment and is skipped by the compiler.
Semicolons (“;”) separate program statements.

Let us now step through the LETTER example.
As promised, we restrict ourselves to those aspects of EKiffel’s syntax and semantics that are relevant to the subject at hand.
We will use the notation “\<marker\>” to indicate a placeholder for programmer-supplied code.


### 2.1.1 Class Declaration

The format of a class declaration is:

```python
class <class name>
inherit <parent class name>
        <feature adaptations>
creation <names of features that can initialize objects of this class>
feature <feature declarations>
invariant <what must be true about any object of this class>
end
```

---

### 2.1.2 Redefining an Inherited Feature

In an object-oriented software system, classes of objects are related to each other by means of classification.
Briefly (we will study this in more detail in Chapter 4), one class may be an heir of another (the latter is known as the parent of the former).

*Semicolons in Eiffel are optional in most situations.
However, the Eiffel style guidelines [5, Appendix A] recommend their use.*

An heir inherits all features from its parent class, and may provide its own, additional features.  
It may also provide a better way of implementing some of the features that it inherited.  
When that happens, Eiffel insists that we explicitly mention that fact in the `inherit` clause.  
Otherwise, the compiler will assume that we accidentally used a feature name that we already had, thanks to our generous parent.  

But what is this class `ANY` anyway, and why do we need to inherit its features?  
Well, we do not have much choice in the matter.  
`ANY` is the ancestor of all programmer-supplied classes in an Eiffel system: all classes we write will inherit, directly or indirectly, from `ANY`.  
If we omitted the whole `inherit ... redefine ... end` part, we would be inheriting everything from `ANY` by default.  
`ANY` provides many useful features, and this automatic inheritance will save us from writing a lot of code.  

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
