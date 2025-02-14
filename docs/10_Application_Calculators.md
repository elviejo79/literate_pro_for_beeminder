# 10 Application: Calculators 

Stacks and queues are used practically everywhere in computer science.
If you are a computer science practitioner, I do not need to tell you that.
If you are relatively new to the field, however, you may be impatient to see a good use for them, and justifiably so. 

This chapter presents the design and implementation of two calculators:
a postfix calculator (also called “Reverse Polish Notation,” or “RPN”) and an infix calculator
(one that uses customary arithmetic notation). 

We will not be evolving the code as we did in other chapters—the program is presented as a finished product. 

## 10.1 Postfix Notation (RPN) 

“Reverse Polish Notation” calculators have no parentheses and no ‘=’ key.
To calculate “33 + 22,” the user enters “33” and hits the ‘enter’ key to say that the next digit belongs to a different number,
then enters “22” and then hits the ‘+’ 
key to say “add the last two values.” Such calculators were popularized by Hewlett-Packard,
and were idolized by engineers:
Not only were they built to last forever, but they were also as mystical to most laypeople as were the slide rules they replaced.[^1]

[1]: Let me state for the record, lest this provoke a deluge of hate mail, that I myself favor RPN calculators, and love my HP-16C. 

They do not need an ‘=’ key, because the operator keys (‘+’, ‘—’, ‘x’, etc.) 
invoke computation, using the last values that had been seen.
If the operator is binary, it takes the last two values;
if it is unary, such as ‘CHG’ (change sign, or negate) or ‘Vx, then it takes just the last value.
It then replaces all the values it took with the result. 

They do not need parentheses because the order of evaluation is explicit: 
You do not tell the calculator to perform an operation until all the values it needs are ready.
For example, suppose we need to evaluate “10 — 2 x 4.” We enter “10,” and the value to be subtracted from it is the answer to “2 x 4.” That value has not been computed yet, and we cannot press ‘—’ until it is available. 
Thus, we leave “10” where it is and enter “2” next to it: “10 2.” The “2” is to be multiplied by 4,
so we need to enter “4” and then hit ‘x’: “10 2 4 x.”
Since ‘x’ is an operator, it immediately evaluates its result: “10 8.” Now we can enter the ‘—’: “10 8 —,” which produces “2.” 

Thus, the RPN version of the expression “10 — 2 X 4” is “10 2 4 x —.”
RPN notation is also called “postfix” because the operator appears after its operands;
the customary arithmetic notation is “infix.” 

## 10.2 Converting from Infix to Postfix

There is a mechanical way of determining a postfix equivalent of an infix expression.
Operands are appended to the postfix expression as soon as they are encountered, but evaluation of operands is delayed by pushing operators onto a stack.
If the new operator is lower precedence than the ones that are at the top of the stack, then it is time to evaluate them, so they are popped and appended to the postfix expression.
When the operator at the top is of lower precedence than the new one, then it will have to wait, and the new one is pushed onto the top.
(This algorithm is embodied in feature postfix of class INFIX_CALCULATOR, discussed later.) 

## 10.3 The Design 

A program that implements a postfix calculator needs to read in the expression from the keyboard, separate it into individual entries (numbers and operators),
and use a stack to compute the result. 

A program that implements an infix calculator needs to read in the expression from the keyboard,
separate it into individual entries,
convert it into postscript notation,
then use the stack to evaluate the result. 

```plantuml
class CALCULATOR

CALCULATOR <|-- POSTFIX_CALCULATOR
CALCULATOR <|-- INFIX_CALCULATOR
```
Figure 10.1 The hierarchy of calculator classes. 

The two have enough in common to take advantage of a common ancestor. 
Thus, there are three calculator classes:
the parent CALCULATOR,
and its heirs POSTFIX_CALCULATOR
and INFIX_CALCULATOR (Figure 10.1). 

The calculator builds up a queue of CALCULATOR_ENTRY objects in postfix form, then creates an EXPRESSION from that queue and asks for its value. 
There are two kinds of calculator entries: OPERAND and OPERATOR.
There are two kinds of operators: UNARY_OPERATOR and BINARY_OPERATOR. 
Finally, each specific kind of operator (plus, minus, negate, etc.) is an heir to either the binary or the unary operator class.
This class hierarchy is shown in Figure 10.2. 

```plantuml
class CALCULATOR_ENTRY

CALCULATOR_ENTRY <|-- OPERAND
CALCULATOR_ENTRY <|-- OPERATOR

OPERATOR <|-- UNARY_OPERATOR
OPERATOR <|-- BINARY_OPERATOR

UNARY_OPERATOR <|-- OP_NEGATE

BINARY_OPERATOR <|-- OP_PLUS
BINARY_OPERATOR <|-- OP_MINUS
BINARY_OPERATOR <|-- OP_TIMES
BINARY_OPERATOR <|-- OP_DIV
BINARY_OPERATOR <|-- OP_TO_THE
```
Figure 10.2 The hirerachy of calculator entry classes.

## 10.4 The Implementation 
Since the rest of this chapter is mostly Eiffel code, with a few explanations thrown in, the boxed listing format we have been using is too awkward. Instead, the code is presented as normal text flow, with short explanations before or after the code, and with guiding notation in the margins. 

## 10.4.1 CALCULATOR 

This is the main class of the program.
It is a deferred class that provides the running framework for its subclasses, POSTFIX_CALCULATOR and INFIX_ 
CALCULATOR.
The main loop of the calculator is in routine run (the subclasses inherit it and make it their creation routine). 

It defers to the specific calculator features greeting (a string telling the user which calculator is being run) and postfix (the parsed expression in postfix form). 

The  input  features  that  it uses  are  summarized  in Appendix  B. 

```Eiffel
deferred  class  CALCULATOR 

feature 

run  is 

——Main  loop  of the  calculator. 

local 

user_input:  QUEUE_LINKED[CALCULATOR_ENTRY)]; 
postfix_input:  QUEUE_LINKED[(CALCULATOR_ENTRY]; 
expression:  EXPRESSION; 

do 

print (greeting); 
from 
until 

io.end_of_file 

loop 

io.read_line; 
user_input  :=  parsed (io.last_string); 

if wser_input.is_empty  then 

print("Blank  lines  are  ignored.  To  exit,  give  me  end 
of  file. %Nn"); 

else 

print("Input:  "); print("user_input");  print("%N"); 

postfix_input  :=  postfix (user_input); 
print ("Postfix:  "); print (postfix_input);  print("%N"  ); 

'expression.make  (postfix_input); 
print("Value:  "); print (expression.value);  print("%N"  ); 

end; 

end; 

end;  —-run 

feature  {NONE} 

greeting:  STRING  is 

——What  to print  to welcome  the  user. 

deferred 
end;  ——greeting 

postfix (input:  QUEUE_LINKED[CALCULATOR_ENTRY  ]): 

QUEUE_LINKED[CALCULATOR_ENTRY  |is 

——The  postfix  version  of the  input  queue. 

deferred 
end;  ——postfix 

parsed (line:  STRING):  QUEUE_LINKED(|CALCULATOR_ENTRY]  is 

——A  queue  of the  individual  entries  on  the  input  line. 

local 

index:  INTEGER; 
last_number:  INTEGER; 

line_length:  INTEGER; 

parsing_a_number:  BOOLEAN; 
last_character:  CHARACTER; 

entry:  CALCULATOR_ENTRY;; 

zero_code:  INTEGER; 

do 

zero_code  :=  ('0').code; 
from 

index  :=  1; 
line_length  :=  line.count; 
'!Result.make; 
j 
‘anit 
; 
Maree! 

line_length  —  index 

until 
‘ 
é 
index  >  line_length 

loop 

Loop  variants 
are  discussed 
in Section 
12.2.1.  They do 
not affect  loop 
execution,  thus 
can  be  safely 
enomee 

last_character  :=  line.item  (index); 

if last_character  >=  '0’'  and  last_character  <=  '9'  then 

last_number  :=  last_number  *  10  +  (last_character.code—zero_code); 
parsing_a_number  :=  true; 

else 

entry  :=  Void; 

if parsing_a_number  then 

!OPERANDIlentry.make  (last_number); 
Result.enqueue  (entry); 
parsing_a_number  :=  false; 
last_number  :=  0; 
entry  :=  Void; 

end; 

inspect 

last_character 
when  ‘+’  then 

!OP_PLUS!entry.make; 

when  ‘—’  then 

!OP_MINUSlentry.make; 

when  ‘~’  then 

!OP_NEGATElentry.make; 

when  ‘*’  then 

!OP_TIMES!entry.make; 

when  ’/’  then 

!OP_DIVlentry.make; 

when  ‘*~’  then 

!OP_TO_THEentry.make; 

else 

——Skip  it. 

end; 

if entry  /=  Void  then 

Result.enqueue  (entry); 

end; 

end; 

index  :=  index  +  1; 

end; 

if parsing_a_number  then 

!OPERAND!entry.make  (last_number); 
Result.enqueue  (entry); 

end; 

end;  ——parsed 

end  —-—class  CALCULATOR 

```

### 10.4.2  POSTFIX_CALCULATOR 

Since  with  a postfix  calculator  the user  is entering  a postfix  expression,  feature 
postfix  has  nothing  to  do in  class  POSTFIX_CALCULATOR.  This  makes  for  a 
very  simple  class. 

```Eiffel
class  POSTFIX_CALCULATOR  inherit  CALCULATOR 

creation  run  ——inherited 
 
APPLICATION: CALCULATORS 

183 

inspect 
last_character when ‘+’ then 
!OP_PLUS!entry.make; 

when ‘—’ then 
!OP_MINUSlentry.make; 

when ‘~’ then 
!OP_NEGATElentry.make; 

when ‘*’ then 
!OP_TIMES!entry.make; 

when ’/’ then 
!OP_DIVlentry.make; 

when ‘*~’ then 
!OP_TO_THEentry.make; 

else 
——Skip it. 

end; 

if entry /= Void then 
Result.enqueue (entry); 

end; 

end; 

index := index + 1; 

end; 

if parsing_a_number then 
!OPERAND!entry.make (last_number); 
Result.enqueue (entry); 

end; 

end; ——parsed 
end —-—class CALCULATOR 
```

### 10.4.2 POSTFIX_CALCULATOR 

Since with a postfix calculator the user is entering a postfix expression, feature postfix has nothing to do in class POSTFIX_CALCULATOR.
This makes for a very simple class. 

```Eiffel
class POSTFIX_CALCULATOR inherit CALCULATOR 

creation run ——inherited 

-- A string can be split between two lines by putting a % at the end of the first part and at the beginning of the second. 

feature {NONE} 

greeting: STRING is 
"Enter a postfix (RPN) expression and hit RETURN%SN% 

$Hit end-of-file (control-d in Unix) to exit.3N"; 

postfix (input: QUEUE_LINKED[CALCULATOR_ENTRY)): 

QUEUE_LINKED(CALCULATOR_ENTRY] is 
——Same as input. 

do 
——The parsed line is already in postfix. 
Result := input; 

end —— postfix 
end —-—class POSTFIX_CALCULATOR 
```

### 10.4.3 INFIX_CALCULATOR 

The infix calculator is, basically, the postfix calculator with an infix-to-postfix conversion.
The conversion is performed by feature postfix, which scans its input queue and tells each entity in it to modify the resulting queue and the operator stack appropriately. 

An operand will immediately enqueue itself into Result.
An operator will pop all items of greater (or perhaps equal—see the discussion in Section 10.4.7) 
precedence off the operator stack, enqueuing them into Result, and then push itself onto the stack.
After the last entry has done its part, feature postfix transfers the operators still on the stack to the end of the postfix expression. 

```Eiffel
class INFIX_CALCULATOR inherit CALCULATOR 

creation run ——inherited 
feature {NONE} 

greeting: STRING is 
"Enter an arithmetic expression and hit RETURN%SN% 

SHit end-of-file (control-d in Unix) to exit.%N"; 

postfix (the_input: QUEUE_LINKED(CALCULATOR_ENTRY)): 

QUEUE_LINKED[(CALCULATOR_ENTRY] is 
local 
waiting_operators: STACK_LINKED[(OPERATOR]; 
input:
like the_input; 

do 
——Make a local copy of the_input to prevent side effects. 
input := clone (the_input); 

-- Statements bracketed with debug... end are executed only if the class was compiled  with debugging enabled in the Ace file (see Appendix D),

from 
''Result.make; 
'waiting_operators.make; 

variant 
input.length 
until 
input.is_empty 
loop 
input.front.modify_infix (Result, waiting_operators); 
input.dequeue; 

debug 
; 

a Ae print Result);
print ("SN"); 
print (waiting_operators);
print ("%N"); 

Boras 
end; 

eri: 
: 

——Flush out the operators still waiting. 
from variant 
waiting_operators.size 
until 
waiting_operators.is_empty 
loop 
Result.enqueue (waiting_operators.top); 
waiting_operators.pop; 

end; 

end; ——parsed 
end ——class INFIX_ CALCULATOR 
```

### 10.4.4 EXPRESSION 

An expression consists of the calculator entries in postfix order.
It is made out of a queue that is already in that order, which it clones for future reference.
Its feature make also evaluates the expression, using a stack. 

The evaluation is done by creating an empty stack of operands, and then telling each entry in the queue to modify it according to its own definition: 

* Operands will just push themselves onto the stack;
* operators will pop the right number of operands, use them in computation, and push the result. 

```Eiffel
class EXPRESSION inherit 
ANY 

redefine 
out 
end; 

creation make 
feature {NONE} 

queue: QUEUE[CALCULATOR_ENTRY ]; 

——So that out knows the original expression. 

feature 
value: INTEGER is 
——The result of computing this expression. 

make (postfix: QUEUE [CALCULATOR_ENTRY }) is 
——Create a new expression out of the entries of postfix, 
——and compute its value. 

require 
input_not_empty:
not postfix.is_empty; 

local 
results: STACK_LINKED[OPERAND)]; 

do 
——Keep a copy of the queue. 
queue := clone (postfix); 

from 
'results.make; 

variant 
postfix.length 
until 
postfix.is_empty 
loop 
debug 
print (results);
print ("SN"); 

end; 

postfix.front.modify_ postfix (results); 
postfix.dequeue; 

end; 

check 
one_result_left:
results.size = 1; 

end; 

value := results.top.value; 

end; ——make 
out: STRING is 
——Same as out of the original queue. 

do 
Result := queue.out; 

end; ——out 
invariant 
have_queue:
queue /= Void; 

end —-—class EXPRESSION 
```

### 10.4.5 CALCULATOR_ENTRY 

Every feature in CALCULATOR_ENTRY is deferred to its heirs.
It only provides the contract for operators and operands. 

The two primary routines it defines are modify_postfix, which operates on a stack of operands (it is used while computing the value of a postfix expression),
and modify_prefix, which operates on a stack of operators and adds to the queue that holds the postfix expression. 

The remaining routines are there only to allow the heirs to specify mean
ingful preconditions. 

```
deferred class CALCULATOR_ENTRY inherit ANY 

undefine 
out ——Force subclasses to implement out. 

end; 

feature ——Dealing with the postfix-to-value stack 
modify_postfix (stack: STACK[OPERAND)) is 
——Modify the operand stack appropriately. 

require 
stack_not_void:
stack /= Void; 
stack_big_enough:
postfix_stack_is_big_enough (stack); 
stack_small_enough:
postfix_stack_is_small_enough (stack),


deferred end; ——modif'y_postfix 

-- postfix_stack_is_big_enough (stack: STACK[OPERAND)): BOOLEAN is ——Are there enough items on the stack for this entry to work? 

require 
stack_not_void:
stack /= Void; 

deferred end; ——postfix_stack_is_big_enough 
postfix_stack_is_small_enough (stack: STACK[OPERAND)]): BOOLEAN is 
——Is there enough room on the stack for this entry to work? 

require 
stack_not_void:
stack /= Void; 

deferred end; ——postfix_stack_is_small_enough 
feature —— Dealing with the infix-to-postfix queue and stack 
modify_infix (postfix: QUEUE(CALCULATOR_ENTRY]; 

waiting: STACK[OPERATOR)) is 
——Modify the postfix queue and the waiting operator stack appropriately. 

require 
queue_not_void:
postfix /= Void; 
queue_small_enough:
infix_queue_is_small_enough (postfix,waiting); 
stack_not_void:
waiting /= Void; 
stack_small_enough:
infix_stack_is_small_enough (waiting); 

deferred end; ——postfix_stack_is_small_enough 
infix_stack_is_small_enough (stack: STACK|OPERATOR]): BOOLEAN is 
——Is there enough room on the stack for this entry to work? 

require 
stack_not_void:
stack /= Void; 

deferred end; ——infix_stack_is_small_enough 
infix_queue_is_small_enough (queue: QUEUE[CALCULATOR_ENTRY]; 

stack: STACK[OPERATOR]): BOOLEAN is 
——Is there enough room in the queue for this entry to work? 

require 
queue_not_void:
queue /= Void; 

deferred end; ——infix_queue_is_small_enough 
end —-class CALCULATOR_ENTRY 
```

### 10.4.6 OPERAND 

An operand has a numeric value (an integer in this example).
During evaluation of the postfix expression, it pushes itself onto the stack.
During infix-topostfix conversion, it enqueues itself into the postfix queue. 

```Eiffel
class OPERAND inherit CALCULATOR_ENTRY 

creation make 
feature 
make (the_value: INTEGER) is 
——Make a new operand with value the_value. 

require 
value_not_void:
the_value /= Void; 

do 
value := the_value; 

end; ——make 
value: INTEGER; 

——The numeric value of this operand. 

out: STRING is 
——value.out. 

do 
Result := value.out; 

end; ——out 
feature —-—Dealing with the postfix-to-value stack 
modify_postfix (stack: STACK[OPERAND)) is 
——Push the operand onto stack. 

do 
stack. push (Current); 
end; ——modify_postfix 
postfix_stack_is_big_enough (stack: STACK[OPERAND)): BOOLEAN is 
——The stack is always big enough. 

do 
Result := true; 

end; ——postfix_stack_is_big_enough 
postfix_stack_is_small_enough (stack: STACK[|OPERAND)): BOOLEAN is 
—~Is there room for one more operand? 

do 
Result := not stack.is_full; 

end; ——postfix_stack_is_small_enough 


feature —— Dealing with the infix-to-postfix queue and stack 
modify_infix (postfix: QUEUE[CALCULATOR_ENTRY ]; 

waiting: STACK[OPERATOR)) is 
——Add the operand to postfix. 

do 
postfix.enqueue (Current); 

end; ——modify_infix 
infix_stack_is_small_enough (stack: STACK[OPERATOR]): BOOLEAN is 
——The stack is not used, so it is always small enough. 

do 
Result := true; 

end; ——infix_stack_is_small_enough 
infix_queue_is_small_enough (queue: QUEUE[CALCULATOR_ENTRY ]; 
stack: STACK|OPERATOR)): BOOLEAN is 
——Is there room for one more? 

do 
Result := not queue.is_full; 

end; ——infix_queue_is_small_enough 
invariant 
value_not_void:
value /= Void 
end —-—class OPERAND 
```

### 10.4.7 OPERATOR 

Class OPERATOR defers modify_postfix to the specific operator classes.
Feature modify_infix performs this operator’s part in the infix-to-postfix conversion scheme described in Section 10.4.3. 

An important detail of the priority scheme is that most operators are leftassociative, which means that when two operators of the same precedence appear side by side, the one on the left is to be performed first, but some are right-associative, meaning that among equal-precedence operators the one on the right is done first.
For example, ‘+’ and ‘—’ are the same priority and left-associative, so “1 — 2 + 3” means “(1 — 2) + 3,” not “1 — (2 + 3).” On the other hand, exponentiation (“’) is right-associative, so “2°” means “2°,” not “(aa yee 
Thus, when a left-associative operator is popping the stack, it needs to pop off all items of greater or equal precedence, while a right-associative operator needs to pop off items of strictly greater precedence. 

```Eiffel
deferred class OPERATOR inherit CALCULATOR_ENTRY 

feature —— Dealing with the postfix-to-value stack 
postfix_stack_is_small_enough (stack: STACK[OPERAND]): BOOLEAN is 
——Will be popping at least as many as pushing. 

do 
Result := true; 

end; ——postfix_stack_is_small_enough 
feature —-— Dealing with the infix-to-postfix queue and stack 
precedence: INTEGER is 
——In infix expressions, higher precedence operations are done first. 

deferred end; ——precedence 
is_right_associative: BOOLEAN is 
——When two of these are in a row, does the one on the right have precedence? 

do 
Result := false; --Good default for most operators. 

end; ——is_right_associative 
modify_infix (postfix: QUEUE|CALCULATOR_ENTRY ]; 

waiting: STACK[OPERATOR)) is 
——Pop operators that are higher in precedence than this one from waiting ——and add them to postfix, then push this operator onto waiting. 

do 
from variant 
waiting.size 
until 
waiting.is_empty or else precedence > waiting.top.precedence or else (is_right_associative 
and then precedence = waiting.top.precedence) 

loop 
postfix.enqueue (waiting.top); 
waiting.pop; 

end; 

waiting.push (Current),


end; ——modify_infix 
infix_stack_is_small_enough (stack: STACK[OPERATOR]): BOOLEAN is 
——Will either pop or need room for one more. 

do 
Result := stack.is_empty 
or else precedence < stack.top.precedence or else not stack.is_full; 

end; ——infix_stack_is_small_enough 
infix_queue_is_small_enough (queue: QUEUE[CALCULATOR_ENTRY]; 

——May need to add as many as stack.size vacancies in queue. 

stack: STACK[OPERATOR]): BOOLEAN is 
do 
——There is no easy way to check if there are enough vacancies in ——queue.
The condition below is better than nothing, but ——the result may be true when it should have been false. 

Result := not queue.is_full; 

end; ——infix_queue_is_small_enough 
end —-class OPERATOR 
```

### 10.4.8 Binary Operator Classes 

During the evaluation of a postfix expression, all of the binary operators do the same thing to the operand stack:
pop off two operands, use them to determine the answer, and push the answer back onto the stack.
Thus, modify_postfix is implemented in BINARY_OPERATOR using the private deferred feature answer to compute the actual answer to push.
The specific OP_... classes implement function answer as is appropriate for each operator. 

```Eiffel
deferred class BINARY OPERATOR inherit OPERATOR 

feature 
make is 
——Initialization. 

do 
——Nothing. 
end; ——make 
feature —- Dealing with the postfix-to-value stack 
modify_ postfix (stack: STACK[OPERAND)) is ——Replace top two items with the answer. 

local 
left: OPERAND; 
right: OPERAND; 
the_answer: OPERAND; 

do 
right := stack.top;
stack.pop; 
left := stack.top;
stack.popn; 

"the_answer.make (answer (left.value,right.value)); 
stack. push (the_answer); 

end; ——modify_postfix 
postfix_stack_is_big_enough (stack: STACK[OPERAND)]): BOOLEAN is 
——Are there at least two operands? 
do 
Result := stack.size > 1; 

end; ——postfix_stack_is_big_enough 
feature {NONE} 

answer (left: INTEGER;
right: INTEGER): INTEGER is ——Redefined by heirs to do the actual computation. 

deferred end; ——answer 
end ——class BINARY_OPERATOR 

class OP_PLUS inherit BINARY_OPERATOR 

creation make 
feature 
precedence: INTEGER is 2; 

out: STRING is " 

" 

at 
do 
Result := clone("+"); 

end; ——out 
d; 

feature {NONE} 

answer (left: INTEGER;
right: INTEGER): INTEGER is 
——left + right. 

do 
Result := left + right; 

end; ——answer 
end —-—class OP_PLUS 

-- It does not matter what numbers are used for precedence, as long as that of ‘~’ is greatest, followed by ‘~  then ‘*’ and ‘/’, then ‘+’ 

class OP_MINUS inherit BINARY_OPERATOR 

creation make 
feature 
precedence: INTEGER is 2; 

out: STRING is 
if aa 
. 

a 
do 
Result := clone("-"); 

end; ——out 
feature {NONE} 

answer (left: INTEGER;
right: INTEGER): INTEGER is 
——left — right. 

do 
Result := left — right; 

end; ——answer 
end —-—class OP_MINUS 

class OP_TIMES inherit BINARY_OPERATOR 

creation make 
feature 
precedence: INTEGER is 5; 

out: STRING is 
do 
Result := clone("*"); 

end; ——out 
feature {NONE} 

answer (left: INTEGER;
right: INTEGER): INTEGER is 
——left * right. 

do 
Result := left * right; 

end; ——answer 
end —-class OP_TIMES 


class OP_DIV inherit BINARY_OPERATOR 

creation make 
feature 
precedence: INTEGER is 5; 

out: STRING is ey 
do 
Result := clone("/"); 

end; ——out 
feature {NONE} 

answer (left: INTEGER;
right: INTEGER): INTEGER is 
——left // right. 

do 
Result := left // right; 

end; ——answer 
end —-—class OP_DIV 

class OP_TO_THE inherit BINARY_OPERATOR 

creation make 
feature 
precedence: INTEGER is 8; 

is_right_associative: BOOLEAN is 
——Exponentiation is right-associative. 

do 
Result := true; 

end; ——is_right_associative 
out: STRING is 
do 
Result := clone("*"); 

end; ——out 
feature {NONE} 

answer (left: INTEGER;
right: INTEGER): INTEGER is 
——left * right. 
do 
Result := (left * right).floor; 

end; ——answer 
end —-class OP_TO_THE 
```

### 10.4.9 Unary Operators 

Unary operators are very similar to binary operators, except they only pop one operand off the stack and base the answer on just that one operand.
The division of labor between UNARY_OPERAND and its heirs (only OP_NEGATE 
in this example) is the same as it was with binary operators and their parent class. 

```Eiffel
deferred class UNARY OPERATOR inherit OPERATOR 

feature 
make is 
——Initialization. 

do 
Nothing. 
end; ——make 
feature —— Dealing with the postfix-to-value stack 
modify_ postfix (stack: STACK[OPERAND)) is ——Replace top item with the answer. 

local 
operand: OPERAND; 
the_answer: OPERAND; 

do 
operand := stack.top;
stack.pop; 

'!the_answer.make (answer (operand.value)); 
stack.push (the_answer); 

end; ——modify_ postfix 
postfix_stack_is_big_enough (stack: STACK[OPERAND)): BOOLEAN is 
——Is there at least one operand? 

do 
Result := not stack.is_empty; 
end; ——postfix_stack_is_big_enough 
feature {NONE} 

answer (operand: INTEGER): INTEGER is 
——Redefined by heirs to do actual computation. 

deferred end; ——answer 
end; ——class UNARY_OPERATOR 

class OP_NEGATE inherit UNARY_OPERATOR 

precedence: INTEGER is 10; 

creation make 
feature 
out: STRING is 
" 

" 
= 

do 
Result := clone("~"); 

end; ——out 
feature {NONE} 

answer (top: INTEGER): INTEGER is 
———top. 

do 
Result := —top; 

end; ——answer 
end ——class OP_NEGATE 
```

# Exercises 
1. Convert by hand (without using the computer) 
    1. the infix expression “9 — 4 x 2 + 52” to postfix; 
    2. the postfix expression “1 2 3 4 * —/2™ to infix. 

2. Add the binary operator “remainder” to the calculators.
Use the symbol ‘\’ 
(e.g., the infix expression “5\2” should evaluate to 1).
Its precedence is the same as that of multiplication and division, and it is left-associative. 

3. The classes presented in this chapter are very intolerant to user errors. 
Modify them so that a user mistake results in a polite error message instead of a crashed program. 
4. Add the ability to handle parentheses to the infix calculator. 
5. Create a prefix calculator. 
