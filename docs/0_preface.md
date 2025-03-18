# Preface

This book serves two basic purposes.
It is a study of applied object-oriented
component design, as well as a treatise of object structures:
ways to organize objects for various purposes,
with an engineering analysis of the trade-offs involved.
It is aimed at students in the undergraduate computer science curriculum,
and at practicing professionals interested in learning object-oriented programming.

A few words now to the professional, the student, and the teacher.
Then I will explain why Eiffel was chosen as the supporting programming language
-a question that is of interest to all three.

## To the Professional
I address you first,
because I think you require the shortest explanation.
You have probably already used data structures in your work;
in fact, you have probably studied them in school.
I expect that you do not need another book on data structures.
*This is not another book on data structures*.

Yes, readers of this text will study the familiar data structures:
arrays, lists, queues, stacks, trees,etc.
But in the process,
they will study good software engineering techniques,
gain an understanding of software component design,
discover how to create interchangeable implementation of components,
and analyze the trade-offs involved in choosing an implementation for a specific job.

Still, if all you want to learn is some object-oriented programming,
then why not practice on something you are familiar with,
like data structures?

## To the Student

You are the reason this book emphasizes what it does.
Chances are that you are enrolled in what in computer-science-education terminology is called
“the CS-2 course”-the second semester of the computer science curriculum recommended by ACM.[^1]
It does not have to be taken precisely in the second semester:

[^1]: ACM stands for “Association for Computing Machinery,” though most of its members are human.

Many schools,including the one where I teach now,
present this course on a different schedule.

There are two reasons for this course.
Its nominal purpose is to teach you the use and analysis of data structures
-a very important topic for any computer scientist.
Its complementary purpose is to give you a chance to practice good computer programming.
See, it makes no sense to have a course in just “programming,”
you have to have something to write programs about!
So, CS-2 makes you write programs with data structures,
which you need to learn anyway.

If you have eavesdropped on what I said to the practitioner,
you know that this text deals with much more than data structures.
Yes, they are important, and you will be studying them.
But at least as important is the skill set this book presents in designing and writing these structures.
The techniques you will learn in this course can be used in development of large software systems,
because they work by organizing software solutions into consistent and manageable components.

If your prior programming experience is limited to programs that fit into one component,
this course will do wonders for your ability to be successful in large software projects.

Finally, allow me to point out a fact that should be obvious,
but somehow always needs to be exposed.
Many students at the CS-2 level still believe the theory of “learning by photosynthesis”:

> If you spend enough time in the presence of brilliance, you will walk away enlightened.

Sorry, folks, it just does not work that way.
You cannot become a decent programmer by attending enough lectures any more than you can become a decent guitar player by attending enough concerts.
Do the exercises. Question each line, and understand its purpose.
Invest the time to do it right.

## To the Teacher

Generally, there are two philosophies for data structure courses:

1. “This is where we subject them to pointers, more programming,
pointers, longer programs, pointers, maybe an abstract data type or two,
a bunch of sorting algorithms, pointers, trees and more recursion, and pointers.”

2. “This is where we play with data structures,
spending as little effort on programming as necessary,
covering as much variety and beauty as possible.”

This blatant straw-man fallacy may lead you to believe that I favor Philosophy 2.
No, not for CS-2-but I do appreciate it.
For a beautiful example of a book that
supports this approach, examine Derick Wood’s excellent text [13].
If I were going to use the second approach,
I would adopt that book and do all programming in ML (though he uses Pascal):
Do binary search trees in 30 minutes and move on!

My students certainly do need additional programming experience at the CS-2 level.

But I do have a problem with Philosophy 1.
Grab a few of your data structures course graduates, and ask them “What is a list?”

Did they say something like “It’s when you take a bunch of records and add
pointers to them to connect them together”?

If so, then they certainly learned their pointers. However,

1. They cannot say what a list is.
They do not distinguish between a definition
of a data structure and its implementation.

2. They do not separate the structure (the container) from the payload.

Not convinced?
Ask them what operations make sense for lists.
I rest my case.

Various textbooks attempt to remedy this problem by introducing data abstraction as an “advanced topic,”
usually in the form of a chapter on stack and queue ADTs.
I have found that students tend to treat it as they do any advanced topic:
“First, I better learn the basics, then I'll worry about abstraction.”
To be fair, abstraction has been working its way toward Chapter 1 in new textbooks,
but I have seen none that use it consistently, from cover to cover.
This book does.

The other problem with typical ADT presentations is that they only examine one implementation for each ADT.
In my experience, that does not get the point across.
Students tend to view abstraction walls as something the teacher invented to make their lives more complicated,
and then tried to back up with proclamations of vague morality.
A typical discussion goes like this:

> “So what if I stuck a pointer into the middle of my data structure; the program works, doesn't it?!”

> “But if you ever changed the implementation, the program may stop working!”

> “Well, when it does, then I'll deal with it!”

My solution to this problem is to get them to deal with it immediately,
by requiring at least two distinct implementations for each structure.
This works remarkably well,
even when using a language with weak (or nonexistent) abstraction enforcement,
such as Pascal or C.

## Putting It All Together

Object-oriented programming allows us to put all of these solutions together
into a consistent and straightforward presentation.

Abstraction *is* “the basics.”
The software just begs to be organized into components.
Containers and payloads stay apart.
And then there is Bertrand Meyer’s *Design by Contract*,
a natural way to allocate responsibility among the building blocks of the system.

This is what distinguishes a course in object structures from one in data structures:
the methodical and systematic way in which each structure is defined, analyzed, and executed.

## The Choice of Language

This aspect is important for the practitioner, and the student, and the teacher.

This book uses Eiffel,
a purely object-oriented programming language designed specifically for software engineering.
The job at hand is to teach good software engineering through the study of object structures.
As I write this,Eiffel is the best tool for this job.

A common notion is that we should “teach a language” that is most likely
to be used by the students when they get jobs in the industry.
At the time of this writing,
Eiffel is *not* such a language.
Shouldn't I use the language that
will be in most demand?

Hmmm ... that would be FORTRAN or COBOL. Oh,sorry ...wrong year, wrong generation of students.

Oh, yes... PL/I or COBOL. No...wrong year,wrong generation.

Ah: BASIC or COBOL! Uhm, no, wrong year, wrong generation.

Let’s see ... Pascal or COBOL? No, wrong year, wrong generation.

Well, here’s a sure thing: Ada and COBOL! Nope, wrong year, wrong (and short) generation.

Got it. It’s C and COBOL. Missed again: wrong year, wrong generation.

No, it’s C++ and SQL. Home, sweet home. “Talkin’ bout my generation!”

Well, folks, that’s six wrong generations in 45 years.
Planning for a very early retirement?

When it comes to choosing a language,
I am a pragmatist.
Under the circumstances and for the task at hand,
Eiffel is the best choice.
There are languages with more theoretically appealing features,
but Eiffel combines simplicity and power with pragmatism.
There are languages that are more widespread,
but none of them is nearly as well suited to designing and implementing object structures.
They lack important features or mix in a large number of distractions irrelevant to the topic at hand 
(this is especially true of hybrid objectoriented languages such as C+ +).

There are also languages that arguably improve on Eiffel,
but Eiffel is the most widespread among the languages most suitable for learning object structures.

After you learn object structures with Eiffel,
you can pick up a book about the bandwagon language of the day,
and learn it in a couple of weeks.
Then, for practice,
you may want to go back and reimplement some of the object structures in that language
-by then you will understand the material sufficiently not to get lost in language-imposed details.
Then you will have the best of both worlds.

## Prerequisites

Since this text’s primary target audience is the CS-2 student,
it does assume a minimal background in programming.
In particular, I expect the reader to be familiar with such concepts as step-by-step execution,
assignment statements, loops, and parameter passing.

I do not expect prior exposure to object-oriented programming;
the book is written to be a thorough introduction into that paradigm.
Nor do I expect prior experience with Eiffel
-but I do expect the reader to use the language reference manual on occasion.

## To My Friends and Colleagues

I greatly appreciate your assistance in creating this book.
My thanks go to Bertrand Meyer
for laying the foundation for the utilized methodology and
for the numerous discussions on various aspects of Eiffel and their implications.
I also thank other folks at Interactive Software Engineering whose help
was timely and instrumental in my utilization of the ISE compiler system,
especially David Quarrie, Darcy Harrison, and Annie Meyer.

The help of Steve Tynor of Tower Technology has been prompt and invaluable.
It extended way beyond support of the Tower compiler system-discussions with Steve helped me understand many of the subtleties of Eiffel.
I am also grateful to him for communicating with the NICE standards committees on my behalf.
My thanks also go to Rock Howard of Tower, whose personal attention helped me on many occasions,
and made it possible for my class to use a fine Eiffel environment when our budget was lacking.

Frieder Monninger of SIG Computer GmbH provided timely help in
making sure that SIG’s shareware Eiffel compiler could also be used with the
examples in this book.

Doug Jackson helped me hash out and clarify many of the ideas and approaches used in this book,
and he double-checked the mathematical claims.
I hope our students appreciate his skill in the foundations of computer science as much as I do.
Pavel Dolgonos also helped me out with some of the algebraic background
(it’s amazing how rusty it gets if you don’t use it).

Many of the improvements in the book were suggested by the reviewers:
Richie Bielak of CAL FP (US), Inc.,
Henry A. Etlinger of Rochester Institute of Technology,
Jim McKim of the Hartford Graduate Center,
Jacques LaFrance of Oklahoma State University,
Jean-Jacques Moreau of HewlettPackard Laboratories,
Kathy Stark of Sun Microsystems,
Ernesto Surribas of UNAM (Universidad Nacional Auténoma de México),
and Chris Van Wyk of Drew University.

All of the folks in the Department of Mathematical Sciences at Eastern
New Mexico University have been very supportive of my efforts,
and provided an excellent working environment.
I am especially grateful to Thurman Elder and Doug Jackson
(whom I have already thanked, but not enough).
I want to thank Betty Lyon for lending me her antique radio to photograph,
Solomon White, a student in the department, for helping me photograph it
(and lending his camera),
and Pavel and Lior Dolgonos for developing the prints.

Speaking of students-they may not be able to tell by the grades they got,
but I am grateful to those who went through the course while the lecture notes
and then the manuscript were in development.
I especially want to thank Erin Powers,
who read the material carefully and pointed out mistakes and unclear passages.

I am grateful to Leon Farfel, my partner in ToolCASE Computing,
for fielding some of the projects in which he would much rather have let me partake.

I thank Mike Hendrickson at Addison-Wesley for helping to keep the project on track and for subtly coercing me into writing a better book.
I wish to express my appreciation to Katie Duffy for facilitating the project.
Finally, I am grateful in advance to everybody else on the Addison-Wesley team who will be putting this book into print and delivering it to market.

