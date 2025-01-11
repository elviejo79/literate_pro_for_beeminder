## 12 OBJECT STRUCTURES

Eiffel is not case sensitive, so an Eiffel compiler will understand you if you write “Character” or “character” or even “CHaRaCHTeR” instead of the conventional “CHARACTER”—but other Eiffel programmers may not.
Most software is written in multiprogrammer teams, and flaunting team coding conventions is an easy way to get fired.

In the text, **identifiers** (which is compilerese for “names”) are *italicized* (e.g., *character*) and **keywords** (“words defined for us by the compiler”) are shown in **boldface** (e.g., **feature**).
When a compiler processes Eiffel code, it is usually all in one font, but some Eiffel code editors may offer this typesetting convention to programmers.

Everything between a “——” and the end of a line is a comment and is skipped by the compiler.
Semicolons (“;”) separate program statements.

---

Let us now step through the LETTER example.
As promised, we restrict ourselves to those aspects of EKiffel’s syntax and semantics that are relevant to the subject at hand.
We will use the notation “\<marker\>” to indicate a placeholder for programmer-supplied code.

---

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
