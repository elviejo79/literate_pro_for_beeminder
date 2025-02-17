# 15 Binary search Trees 

We saw in Chapter 14 how effective binary search can be on a sorted array, but how the advantage is lost on linked lists (see Section 14.1.2).
Well, we do not have to lose that advantage.
We can have the best of both worlds. 

## 15.1 Two-Dimensional Linking 
What slowed us down in Section 14.1.2 was finding the middle of the range: We had to start at the left end and move right to half of the range’s length.
What we need is a shortcut—a reference straight to the middle node, as shown in Figure 15.1a (the object references that were there before are shown in gray, to keep them out of the way of this discussion).
From there we may need to go halfway to the left or halfway to the right.
Let us make the middle node track both of the half-range middle nodes (Figure 15.1b). 

Suppose we checked the node at the middle of the list, and saw that the key we seek is “<” its key.
That means that the association we want is in the left half-list (if it is in the list at all).
Next we find the middle of the left half-list, 
which is an O(1) operation now.
If we do not hit the association we want, we will need to find the middle of either the left quarter-list, or the right quarterlist, depending on how the keys compare.
So we make the mid-half-list node track the two mid-quarter-list nodes (Figure 15.1c),
and so on. 

When we finish threading the list this way, we get the structure shown in Figure 15.1d. 

##### TODO
a. Track the middle of the list. 

##### TODO

b. The middle node tracks the middles of the two half-lists . 

##### TODO

c. ... and those nodes track the middles of the quarter-lists . 

##### TODO

d. ...andso on. 

##### TODO

e. Cleaning up the diagram, we get a binary search tree. 

#### Figure 15.1 The derivation of a binary search tree. 

If we use this structure only for searching, then only the new links, shown in black, are needed.
The old, gray links, which each node uses to track its immediate left and right neighbors, can be dropped.
With those out of the way, 
we can stretch the structure vertically to make the new links easier to see (envision constraining the nodes to moving only up and down, and then grabbing the incoming link to the middle of the list and pulling it up).
The result, shown in Figure 15.1e, is one possible representation of a binary search tree (commonly abbreviated “BST”). 

## 15.2 Tree Terminology 

Though we arrived at this representation purely pragmatically by solving a problem with binary searches of linked structures, there are other kinds of trees, other representations of trees, and other purposes for trees.
Let us nail down a few of the definitions. 

### 15.2.1 Trees 

A tree is a structure in which there is exactly one node that cannot be reached from any of the other nodes in the tree—this node is called “the root of the tree”—and every node except the root can be reached from exactly one other node.
This means that in a diagram of the linked representation of a tree, all nodes except the root will have one arrow going to them.
There is no restriction on the number of arrows coming from a node:
a node can be tracked by at most one other node in the same tree, but it can track several nodes in it, or none at all (a tree node that tracks no others is called a “leaf”).
This is what makes Figure 15.1e a tree. 

When node n, tracks nodes nz and nz, n, is called the “parent” of nz and ng.
Following through with this terminology, nz and n3 are children of n, and each other’s siblings. 

If n;
is the root of tree t,, then nz and ng are roots of subtrees of ¢t,. (A root of a tree cannot be tracked by a node in the same tree, but we never said that it cannot be tracked by an outside object.
The root of a subtree has no parent in that subtree, but has one in a larger tree.) 

The size of a tree is the number of items in it, and the height of a tree is the number of items along the longest path from the root to a leaf (for example, 
the height of the tree in Figure 15.1e is 4). 

That wraps up our list of general tree buzzwords. 
We can use the subtree concept to define trees more precisely and compactly.
A tree is either 

1. Empty, or 
2. A root plus a list of subtrees (each subtree is itself a tree). 

(Using this definition, a leaf is a tree in which all subtrees are empty.)
Note that this is a recursive definition.
As with binary search, recursion is very useful. for binary trees—in fact, for all trees.
Furthermore, while in a binary search, recursion is easily replaced with a loop,
in tree operations it is practically indispensable. 

### 15.2.2 Binary Trees 

A binary tree is a tree where: 

1. No node has more than two children. 

2. Every child of a node is designated as either its left child or its right child. 
(This is important when a node has only one child:
the child cannot just hang directly below the parent, it must be below and to the left, or below and to the right.) 

Rephrasing this definition in terms of subtrees, a binary tree is either 
1. Empty, or 
2. A root plus a left subtree plus a right subtree, where each subtree is a binary tree. 

### 15.2.3 Binary Search Trees 

Finally, a **binary search tree** is a binary tree that is set up for binary searching: If its root tracks item i,, then its left subtree is a binary search tree that holds only items that are < i,, and its right subtree is a binary search tree that holds only items that are >= i_1 [^1]

[1]: We could have chosen to put equal items into the left subtree instead of the right subtree. The choice does not matter as long as we use it consistently. 

## 15.3 What a BINARY_SEARCH_TREE is and What It Does 

There are two good ways to model a tree.
The first is to use the cursor concept with its set of move_. .. commands, just as we did with lists.
The other is to follow the recursive definition, and use a recursive model.
Let us do the latter. 


#### 15.3.1 The BINARY_TREE Contract 

Because binary search trees are just one type of binary tree, we can anticipate a future need for class BINARY_TREE from which BINARY SEARCH_TREE and others can inherit.
The definition says that the tree can be either empty, or be a root item and a left subtree and a right subtree.
Thus, we provide features is_empty, root_item, left, and right. 

These are the essential operations for traversing a populated binary tree. 
But how do we add items to it?
Well, that depends on what kind of a binary tree it is.
For binary search trees, we want a simple `insert (<item>)` operation;
the tree will know where to put the item.
For other kinds of trees, we may want to provide `set_root_item`, `set_left`, and `set_right` operations—but we do not want them in BINARY_TREE because we do not want `BINARY_SEARCH_TREE` 
to inherit them
(unlike sortable lists, a BST is always sorted, so we cannot allow its users arbitrary tree manipulation).
Thus, we must leave BINARY_TREE with just read-only features.
There are enough of those to make a useful contract. 

A number of other useful features are available that can not only be specified in the contract, but provided with a default implementation
(no problem as long as they use the deferred routines left, right, and root_item instead of relying on a specific representation).
These are `out`, `size`, and `height`. 

Most of deferred class BINARY_TREE is given in Listing 15.1;
the rest is left as an exercise. 

```Eiffel
deferred class BINARY_TREE[ITEM] inherit 
ANY 

undefine copy redefine 
out, is_equal 
end; 

feature ——Creation and initialization 
make,wipe_out is 
——Make this an empty tree. 

deferred ensure 
empty:
is_empty; 

end; ——make,wipe_out 
feature —— Accessing the components 

left:
like Current is 
——The left subtree. 

deferred end; —-left 
right:
like Current is 
——The right subtree. 

deferred end; —-right 
root_item: ITEM is 
——The item at the root. 

deferred end; ——root_item 
feature ——Sizing 
is_empty: BOOLEAN is 
——Is this tree empty? 

deferred end; ——is_empty 
size: INTEGER is 
——The number of items in this tree. 

——Left as an exercise. 

height: INTEGER is 
——The number of levels in this tree. 

do 
if is_empty then Result := 0; 

else 
Result := 1 + left.height.max (right. height); 

end; 

end; ——height 
feature ——Comparisons and copying 
is_equal (other:
like Current): BOOLEAN is 
——Do this tree and other have identical structures ——and track the same items at the corresponding nodes? 

—-Left as an exercise. 

feature ——Simple input and output 
out: STRING is 
——"(left.out / root_item.out \ right.out)" or "" if empty. 

do 
if is_empty then Result := ""; 
else 
Result := clone("("); 
Result.append_string (left.out); 
Result.append_string("/"); 

Result.append_string (root_item.out); 

Result.append_string ("\"); 
Result.append_string (right.out); 
Result.append_string(")"); 

end; 

end; ——out 
invariant 
empty_if_size_zero:
is_empty = (size = 0); 
size_not_negative:
size >= 0; 

end ——class BINARY TREE 
Listing 15.1 A contract with a partial implementation for BINARY TREE. 

Look at the implementations of out and height, and observe how the recursive model of the tree lends itself to easy recursive solutions: 

1. What is the height of a binary tree?
For an empty tree it is 0, otherwise it is 1 plus the larger of the heights of the two subtrees `left.height.max(right,height)` integer objects inherit feature max from class COMPARABLE). 

2. What is the string representation of a binary tree?
For an empty tree it is the empty string, otherwise it is the string representation of the left subtree (left.out),
followed by the string representation of the root item (root_item.out),
followed by the string representation of the right subtree (right. out),
with a few delimiters thrown in. 

As an exercise, write the `is_equal` feature for `BINARY_TREE`.
When are two binary trees equal?
When they are both empty or when their roots track the same item and their left subtrees are equal and their right subtrees are equal.
(Note that this definition of equality checks the shape of the tree as well as its contents.) 

15.3.2 The BINARY_SEARCH_TREE Contract 
The primary purpose of a binary search tree is to look up items.
Thus, we provide a feature that takes an item and finds an equal item in the tree, item_ 
equal_to. (If we want to use the tree in a dictionary, we can just make it a tree of associations.)
If there are several items equal to its parameter, it results in the first one it finds. 

At this point, we can also add the insertion and deletion routines to the contract.
Routine insert takes an item to insert and puts it into a place that preserves the binary search tree ordering.
Routine delete takes an item equal to the one we want deleted.
If more than one item in the tree is equal to the parameter, delete deletes the first one it encounters. 

It is possible to provide a general implementation of item_equal_to at this point, using the deferred features `left`,`right`, and `root_item`.
It would be a straightforward coding of the binary search algorithm.
What is the item equal to equal_item in this tree?
For an empty tree, it is void;
if equal_item.is_equal (root_item),
then it is root_item;
otherwise it is the item_equal_to (equal_ 
item) from either the left subtree or the right subtree, depending on whether equal_item is “<” or “>” root_item. 

As we did with BINARY_TREE, we can spruce up deferred class BINARY_SEARCH_TREE with a couple of implemented routines.
In particular, we can easily provide the least and the greatest items in the tree
(one of which, it turns out, we will need in at least one implementation of delete). 

The resulting class is shown in Listing 15.2. 

```Eiffel
deferred class BINARY_SEARCH_TREE[ITEM—>COMPARABLE] inherit 
BINARY_TREE[ITEM]; 

feature ——Adding, removing, and finding items 
item_equal_to(equal_item: ITEM): ITEM is 
——An item in this tree which is_equal (equal_item); 
——Void if no such item exists. 

require 
not_void:
equal_item /= Void; 

local 
void_item: ITEM; 

do 
if is_empty then 
Result := void_item; 

elseif equal_item.is_equal (root_item) then 
Result := root_item; 

elseif equal_item < root_item then 
Result := left.item_equal_to (equal_item),


else 
Result := right.item_equal_to (equal_item); 

end; 

end; ——item_equal_to 

has (equal_item: ITEM): BOOLEAN is 
—~—Is there an item in this tree that is_equal (equal_item)? 

require 
not_void:
equal_item /= Void; 

do 
Result := item_equal_to(equal_item) /= Void; 

end; ——has 
insert (new_item: ITEM) is 
——Insert new_item into its proper place in this tree. 

require 
not_void:
new_item /= Void; 

deferred ensure 
size_after_insert:
size = old size + 1; 

has_after_insert:
has (new_item); 

end; ——insert 
delete (equal_item: ITEM) is 
——Remove an item that is_equal (equal_item),
if any, from this tree. 

require 
not_void:
equal_item /= Void; 

deferred ensure 
size_after_delete: (size = old size and then not old has (equal_item)) 

or else (size = old size — 1 and then old has (equal_item)); 

end; ——delete 
least: ITEM is 
——The least (leftmost) item in the tree. 

local 
void_item: ITEM; 

do 
if is_empty then 
Result := void_item; 

elseif left.is_empty then 
Result := root_item; 

else 
Result := left.least; 

end; 
end; ——least 
greatest: ITEM is 
——The greatest (rightmost) item in the tree. 

local 
void_item: ITEM; 

do 
if is_empty then 
Result := void_item; 

elseif right.is_empty then 
Result := root_item; 

else 
Result := right.greatest; 

end; 

end; ——greatest 
feature ——Sizing 
is_full: BOOLEAN is 
——Is there no room in this tree for another item? 

deferred end; ——is_full 
end ——class BINARY SEARCH TREE 
```
Listing 15.2 A contract with a partial implementation for BINARY_SEARCH_TREE. 

### 15.3.3 Tree Traversals 

Several of the operations that we have discussed do their work by systematically visiting every node in the tree.
Such operations are called “traversals of the tree.” We used traversals with linear object structures too, but there they were too boring to discuss: You just start at the left end and move right until you reach the right end.
Trees, on the other hand, are two-dimensional structures, so they require two-dimensional traversals. 

There are four common traversal schemes.
**Postorder** traversal is what we did in height: 

1. Traverse the left subtree postorder (e.g., get the left subtree’s height). 

2. Traverse the right subtree postorder (e.g., get the right subtree’s height). 

3. Visit the root (e.g., add it in to compute the height of this tree). 

#### Figure 15.2a illustrates the sequence in which a postorder traversal proceeds.
The diagrams in Figure 15.2 use a generic tree diagram for clarity;
we will get back to object structure diagrams in the next section.
The nodes are marked with circles, their'items not shown, and the children of a node are drawn below it. 


##### TODO

a. Postorder traverlsal: Visit the root *after* traversing both subtrees.

##### TODO

b. Preorder traversal: Visit the root *before* traversing both subtrees.

##### TODO

c. Innorder traversal: Visit the root in *between* traversals of the subtrees.

##### TODO

d. Breadth-first traversal: Visit the nodes of each layer left-to-right, starting with the root’s layer. 

#### Figure 15.2 Four methods of traversing a binary tree. 

In a postorder traversal, before visiting the root we must wait for the left subtree to get traversed and then for the right subtree to be traversed.
Thus the traversal dives straight for the bottom left node, and builds the result of the traversal from the bottom up.
This is why it is appropriate for height. 

The opposite of the postorder traversal is the preorder traversal, where 
the root is visited before either of the subtrees is traversed: 

1. Visit the root. 
2. Traverse the left subtree preorder. 
3. Traverse the right subtree preorder. 

A preorder traversal is illustrated in Figure 15.2b. 

The **inorder** traversal was used in out: 

1. Traverse the left subtree inorder (e.g., create the left subtree’s string repre
sentation). 

2. Visit the root (e.g., append the root item’s string representation). 

3. Traverse the right subtree inorder (e.g., append the right subtree’s string 
representation). 

An inorder traversal is illustrated in Figure 15.2c. 

In effect, an inorder traversal traverses the tree “left to right.” This means that an inorder traversal of a search tree will be visiting the items in sorted order (you will see that if you look at the result of out, ignoring the subtree delimiters). 

We have not needed to do a preorder traversal yet, but it is useful when the results of a traversal propagate top-down instead of bottom-up. (For example, 
it can be used to compute the depth of a node—its distance from the root.) 

As an exercise, let us write feature out_preorder.
It will be a simplified version of `out`:
the string representing the tree in preorder, with the parentheses and slashes omitted (the slashes would not be particularly useful anyway).
The feature, shown in Listing 15.3, is a very straightforward coding of the traversal algorithm—the only detail is that “visit” means “append root_item.out to the result.” 

All of the preceding algorithms traverse whole subtrees at once.
This behavior is called “depth-first traversing.” A breadth-first traversal, on the other hand, ignores the concept of subtrees and scans each layer of the tree left-to-right, as shown in Figure 15.2d. 

There is a nice algorithm [13, Section 5.3.2] that performs breadth-first traversals, and it serves as a testament to the usefulness of queues even when no multiprocess programming is involved.
The trick is to use the queue to remember which nodes need to be visited next.
We start by enqueuing the root of the tree.
At each step of the traversal we visit the node at the front of the queue, then dequeue it and enqueue its children. 

```Eiffel
out_preorder: STRING is 
——"<Preorder traversal>", with no delimiters. 

do 
if is_empty then 
Result 3=""; 

else 
Result := clone (root_item.out); 
Result.append_string(" "); 
Result.append_string (left.out_ preorder); 
Result.append_string(" "); 
Result.append_string (right.out_preorder); 

end; 

end; ——out_preorder
```
Listing 15.3 Feature out_preorder for class BINARY_TREE: an illustration of preorder traversals. 

In the example shown in Figure 15.2d, we start with the queue just having node 1 in it: <1<.
We visit and dequeue node 1 and enqueue nodes 2 and 3, so the queue becomes <2 3<.
We visit and dequeue node 2, and enqueue its children: <3 4 5<.
Visit and dequeue 3, enqueue its children: <4 5 6 7<.
Visit and dequeue 4, enqueue 4’s children: <5 6 7 8 9<.
And so on.
The algorithm stops when the queue is exhausted. 

The code for this algorithm is in Listing 15.4. 

```
out_breadth_first: STRING is 
——"<Breadth-first traversal>", with no delimiters. 

local 
to_do: QUEUE_LINKED|like Current]; 

subtree:
like Current; 

do 
Result := clone(""); 

if not is_empty then 
from 
'!to_do.make; 
to_do.enqueue (Current); 

until 
to_do.is_empty 
loop 
subtree := to_do.front; 
to_do.dequeue; 

Result.append_string (subtree.root_item.out); 
Result.append_string(" "); 

if not subtree.left.is_empty then 
to_do.enqueue (subtree. left); 

end; 

if not swbtree.right.is_empty then to_do.enqueue (subtree.right); 

end; 

end; 

end; 

end; ——out_breadth_first 
```
Listing 15.4 Using a QUEUE to implement a breadth-first traversal. 

## 15.4 How a BINARY _SEARCH_TREE Does What It Does 

By far the most straightforward implementation of a binary tree is the linked version, which has been our motivation.
That is the implementation we will do first.
Then we will do an implementation using an array. 

### 15.4.1 A Linked Implementation of BINARY_SEARCH_TREE 

Filling in the implementation gaps for BINARY_SEARCH_TREE_LINKED is easy.
Features left and right are just entities tracking smaller BINARY_ 
SEARCH_TREE_LINKED objects, and root_item is just an entity tracking an ITEM.
An empty tree is one where all three of these entities are void (see Listing 15.5). 

The inside view of a binary search tree thus represented is shown in Figure 
15.3. Note that each subtree is a tree in its own right.[^2]

[2]: Do not be alarmed if this structure looks “heavy.” Only the entities of each object (in this case, the references inside left, right, and root_node) occupy space for each and every tree node; the routines are only stored once for the whole class. 


How do we insert an item into this representation of a tree?
We need to put it into a spot where item_equal_to can find it.
Basically, we have to follow the path item_equal_to takes: 

```Eiffel
feature —— Accessing the components 
left:
like Current; 

——The left subtree. 

right:
like Current; 

——The right subtree. 

root_item: ITEM; 

——The item at the root. 

feature ——Creation and initialization 
make,wipe_out is 
——Make this an empty tree. 

local 
void_item: ITEM; 

do 
root_item := void_item; 
left := Void; 
right := Void; 

end; ——make,wipe_out
```
Listing 15.5 Representation details of class BINARY_SEARCH_TREE_LINKED. 

##### TODO

#### Figure 15.3 The inside view of a linked binary search tree. 

1. If new_item < root_item, then it belongs in the left subtree, so we just tell the left subtree to insert new_item into itself. 

2. If new_item >= root_item, then it belongs in the right subtree (or at the root, but the root is already tracking an item), so we just do right.insert (new_item). 

3. The recursion stops when we are trying to insert into an empty tree.
If that happens, there is no root_item to compare, but we know what needs to be done instead: The empty tree must become a leaf, with new_item tracked by the root, and both subtrees empty (as opposed to void). 

The resulting routine insert is in Listing 15.6. 

Deleting an item is trickier.
The delete routine is given an item equal to the one we want to delete, so first we have to search for it.
This is the easy, recurSive part: 

1. If equal_item < root_item, tell the left subtree to delete equal_item. 

2. If equal_item > root_item, tell the right subtree to do it. 

In the remaining case, equal_item.is_equal (root_item), we need to delete root_item.
The trick is to do it in such a way, that we still have a binary search tree at the end—we cannot just void out root_item. 

```Eiffel
insert (new_item: ITEM) is 
——Insert new_item into its proper place in this tree. 

do 
if is_empty then 
——This tree is no longer empty... 
root_item := new_item; 

——... but its subtrees are. 
"eft.make; 
'right.make; 

elseif new_item < root_item then 
left.insert (new_item); 

else 
right.insert (new_item); 

end; 

end; —-insert
```

##### TODO

#### Figure 15.4 Deleting the root item of a leaf results in an empty subtree. 

In fact, there are three distinct cases to handle (well, four, but two of them are almost the same).
The first case is the easiest:
when the tree has no subtrees. 

If we are deleting the root node of a leaf, then we can simply convert this tree into an empty tree (the inverse of what we did in insert),
by setting left, 
right, and root_item to Void, as shown in Figure 15.4. 

The next easiest case is when this tree has one empty and one nonempty subtree.
Here we want to just move the whole nonempty subtree up one level, 
overwriting the current root (Figure 15.5). 

This leaves the most difficult case:
removing the root item of a tree with two nonempty subtrees.
We cannot just promote one of the subtrees, because that would result in a tree with three subtrees (the subtree that wasn’t promoted plus the left and right subtrees of the promoted one would want to be tracked by the same node).
If it is not a binary tree, it is not a binary search tree. 

Nor can we just void root_item, because then we would be unable to search past that node.
If it is not a search tree, it is not a binary search tree.
But we are on the right track. 

The way out of the dilemma is to replace root_item not with Void, but with 
another item from the tree.
But which one? 

Recall that the inorder traversal of a binary search tree always visits the items in sorted order (Section 15.3.3),
and that we get the inorder traversal by reading the tree’s items left-to-right.
If we delete an item, the result would also be a binary search tree,
so its inorder traversal must be sorted the same way—  it will just skip the item that we deleted. 


##### TODO

#### Figure 15.5 To delete the root item of a tree with one empty subtree, the non-empty subtree is promoted up one level. 


Thus, the item that must take the place of root_item must be one of its neighbors in the inorder traversal:
either the rightmost item of the left subtree (obtained using the request left.greatest),
also known as the inorder predecessor of root_item, or the leftmost item of the right subtree (the “inorder successor,” right.least).
Let us pick the inorder successor (the choice will become clear in a moment). 

If we do “root_item := right.least”, we get a result that is quite close to the tree that we want.
The only problem is that the inorder successor is now in two places in this tree:
at the root and at the leftmost position of the right subtree. 
This is easily solved by requesting right.delete (root_item).
The complete operation is illustrated in Figure 15.6. 

How do we know that it will delete that item and not just an equal one? 
After all, delete deletes the first equal item it finds, and we specifically need to delete the leftmost item in the subtree.
Well, since we split our tree with “<” items on the left of the root and “>=” items on the right,
it is impossible to have a tree whose root item is equal to its leftmost item and is not the leftmost item itself:
If they were two distinct but equal items, then the leftmost item would have to go into the root’s right subtree,
and then it couldn’t be the leftmost item, could it? 

##### TODO
#### Figure 15.6 To delete the root item of a tree with two nonempty subtrees, make the root track the inorder successor of the deleted item, then tell the right subtree to delete the inorder successor. 

Note that if we had decided to use the inorder predecessor (left.greatest) 
instead of the inorder successor, we would not be able to delete it from the left subtree this easily, since then we could be deleting an equal item that is higher in the tree.
So the inorder successor choice goes with the “<, >=” sorting scheme to which we had agreed.
If our tree used the “<=, >” sorting scheme, 
we would want to promote the inorder predecessor instead. 
The coding of this algorithm is left as an exercise. 

### 15.4.2 Using an ARRAY to Implement a BINARY_SEARCH_TREE 

Linked object structures are traversed by following object references;
arraybased object structures are traversed by manipulating array indices.
For an arraybased tree, this means using the index of the root item to find the root items of the subtrees. 

The easiest way to lay out a tree to fit the shape of an array is to use one of the traversals (Figure 15.3.3).
Which of the four will give us the easiest way to compute a child’s index from a parent’s index?
A bit of head-scratching over Figure 15.2 yields the answer:
the breadth-first traversal. 

If we use the relative position of a node within the breadth-first traversal as the array index, then it is very easy to find the children given the parent’s index: If the parent is in position p, then its left child is in position 2p, and its right child is at index 2p + 1.
The mapping of tree nodes to array indices is illustrated in Figure 15.7. 

So, what exactly, is the representation of a tree?
It is the array of items, 
plus the index of the tree’s root.
The inside view of a BINARY_SEARCH_TREE_ 
ARRAY object is shown in Figure 15.8. 

The implementation of root_item is obvious: The result is merely items.item (root_index).
But how do we implement left and right?
It is not enough to just return root_index*2 and root_index*2+1;
those are integers, 
but left and right are trees! 

What we need to do in left and right is to build tree objects for the result. 
But we do not want to copy item references for a subtree from one array to another, for two reasons. 

The first is that it would destroy our performance, making each left and right request O(capacity) in time.
If we cannot do them in O(1) time, we cannot get O(log N) performance out of our tree. 

##### TODO
#### Figure 15.7 Binary tree nodes are mapped onto the array in breadth-first order. 



The second, even more important, reason is that we want the tree and its subtrees (and their subtrees, etc.) to be a nested object structure instead of a group of independent ones.
Otherwise, our recursive algorithms will not work at all.


##### TODO
#### Figure 15.8 The inside view of a BINARY SEARCH_TREE_ARRAY object. 

For example, when we insert a new item into a tree, we delegate the insertion to the left subtree or the right subtree, depending on how it compares with the root item.
When it gets inserted into that subtree, it is also inserted into the main tree.
A tree is not conceptually independent from its subtrees, it must reflect all the changes in them. 

With the linked tree, this was easily accomplished:
left and right simply resulted in the same references to the subtree objects that the tree itself used. 
In effect, the user was provided with shortcuts into the middle of the tree. 

With the array-based implementation, to nest the trees, we must make the tree objects share the array.
The tree objects will share the array tracked by their respective items entities, and will be distinguished by the root_index value only. 

Figure 15.9 illustrates objects that are results of left and right features. 

Listing 15.7 shows a way to perform this operation. A creation procedure, make_subtree, is made available only to other BINARY_SEARCH_TREE_ARRAY objects.
When a new object is told to use that routine to initialize itself, 
it is told which object is its supertree, and whether it is the left subtree of that tree (if not, it is the right subtree, obviously).
It then makes its items track the supertree’s item, and computes its root_index based on the supertree’s root_index. 
Features left and right then simply create their results using make_subtree. 

#### TODO

##### Figure 15.9 Subtrees of a BINARY_SEARCH_TREE_ARRAY share its internal array and use’ root_index to identify their beginning within it. 

```Eiffel
class BINARY_SEARCH_TREE_ARRAY|ITEM —> COMPARABLE] inherit 
BINARY_SEARCH_TREE|ITEM | 

redefine 
left, right, root_item, make, wipe_out, insert, delete, is_empty, is_full 
end; 

creation make, make_capacity, make_subtree 
feature {BINARY_SEARCH_TREE_ARRAY} 

items: ARRAY[ITEM}]; 
root_index: INTEGER; 

make_subtree (supertree:
like Current;
is_left_subtree: BOOLEAN) is 
——Make this tree the left subtree of supertree if is_left_subtree is true, 
——and its right subtree otherwise. 

require 
array_starts_at_1:
supertree.items.lower = 1; 

do 
——Share the array with the supertree. 
items := supertree.items; 

if is_left_subtree then 
root_index := supertree.root_index * 2; 

else 
root_index := supertree.root_index * 2 + 1; 

end; 

end; ——make_subtree 
feature ——Accessing the components 
left:
like Current is 
——The left subtree. 

do 
!!Result.make_subtree (Current, true); 

end; ——left 
right:
like Current is 
——The right subtree. 

do 
''Result.make_subtree (Current, false); 

end; —-right 
```
Listing 15.7 A portion of class BINARY _SEARCH_TREE_ARRAY, showing how left and right create new subtree objects. 

Most of the other operations are analogous to those in BINARY_SEARCH_TREE_LINKED, but two areas warrant additional discussion. 

The first is the treatment of is_full.
In the array-based implementations of other structures, we used the size of the internal array to determine if it was full.
We never automatically resized the array, because resizing is an expensive operation, so we left the decision to do it to the user.
Unfortunately, we cannot do that in BINARY_SEARCH_TREE_ARRAY. 

The problem is this.
We define “full” to mean “no more insertions are possible.” With lists, stacks, and queues, the full state happens when all positions of the array are occupied (or perhaps one empty position exists in the case of queues).
But with binary search trees, we are always inserting into the appropriate empty subtree, wherever it may be within the array.
We may exceed the boundary of the array without filling up all the slots.
For example, suppose the array capacity is 8 and we insert into the tree only four items in sorted order: 
"aalst" (into position 1),
"bindle" (position 3),
"dattuck" (position 7),
and "duddo" (position 15—out of bounds). 

Since we have no way of providing a meaningful `is_full`, we have to make its result always false, and resize the array automatically when necessary. 
Listing 15.8 shows the routines most affected by this decision. 

The second area of interest is the deletion algorithm.
The one we used in the linked implementation took advantage of the situation where the tree whose root item is being deleted had only one nonempty subtree.
In that case, 
we would effectively slide the nonempty tree up one level. 

In the linked implementation, promoting a whole subtree up one level is cheap: We merely reassign three object references.
In the array-based implementation, it is expensive: We actually have to copy item references to other indices within the array. 

Instead of doing that, we move the inorder successor up to the root if the right tree is not empty, whether the left tree is empty or not (thus combining two cases from the algorithm for the linked version),
and move the inorder predecessor up if the right tree is empty but the left tree is not.
As we discussed in Section 15.4.1, we cannot just use delete to remove the inorder predecessor from the left subtree (there could be an equal item higher in the tree that will get deleted instead).
This problem is easily solved, however, by starting the deletion at the predecessor node itself. 

Listing 15.9 shows the code for delete and the new private routine needed 
to find the predecessor’s subtree, called “greatest_subtree.” [^3]

[3]: I am not too crazy about this name. Suggestions for a better one are gladly accepted at Jacob@ToolCASE.com. 


```Eiffel
feature —— Adding, removing, and finding items 
insert (new_item: ITEM) is 
——Insert new_item into its proper place in this tree. 

do 
if is_empty then 
—~—This is where we insert it.
Resize if necessary. 

if root_index > items.count then 
items.resize (1, root_index); 

end; 

items.put (new_item, root_index); 

elseif new_item < root_item then 
left.insert (new_item); 

else 
right.insert (new_item); 

end; 

end; ——insert 
feature ——Sizing 
is_empty: BOOLEAN is 
——Is this tree empty? 

do 
Result := root_index > items.count 
or else items.item (root_index) = Void; 

end; ——is_empty 
is_full: BOOLEAN is false; 

——Cannot predict jumping out of the array, 
——so will have to resize as necessary. 
```
Listing 15.8 Features of class BINARY SEARCH_TREE_ARRAY that deal with the array boundary. 

The function greatest_subtree provides a shortcut for the deletion of the inorder predecessor from the left subtree.
This brings up an interesting question: Do we want to use this shortcut for deleting the inorder successor from the right subtree as well?
We did not do that because the request right.delete (right.least) used the routines already in the contract (in fact, least was inherited from BINARY_SEARCH_TREE).
Would it be better to provide least_subtree and greatest_subtree in the contract instead of least and greatest?
After all, 
the job of least can be accomplished with least_suwbtree.root_item, and then we could conveniently use the deletion shortcuts in both the linked and the arraybased implementations of BINARY SEARCH_TREE.
What do you think? 

```Eiffel
feature {BINARY SEARCH_TREE_ARRAY}-——Adding, removing ——and finding items 
greatest_subtree:
like Current is 
——Like greatest, but the result is not just the rightmost item, 
——but the subtree at the root of which it resides. 

require 
not_empty:
not is_empty; 

do 
if right.is_empty then Result := Current; 

else 
Result := right.greatest_subtree; 

end; 

end; ——greatest_subtree 
feature —— Adding, removing, and finding items 
delete (equal_item: ITEM) is 
——Remove an item that is_equal (equal_item) from this tree. 

local 
void_item: ITEM; 
predecessor_subtree:
like Current; 

do 
if is_empty then 
——Nothing. 

elseif equal_item < root_item then 
left.delete (equal_item); 

elseif root_item < equal_item then 
right.delete (equal_item); 

else 
——Found it.
Deleting. 

if left.is_empty and then right.is_empty then 
——This is a leaf.
Easy. 
items.put (void_item, root_index); 

elseif not right.is_empty then 
——Adopt the inorder successor item and ——remove it from the right subtree. 
items.put (right. least, root_index); 
right.delete (root_item); 
else 
—~Find the subtree for which the inorder predecessor is root, 
——adopt it in this root and delete it from that subtree. 
——(Can’t just remove the greatest item from the left subtree, 
—~since a subtree’s root item may be equal to its greatest item, 
——and the wrong item would get deleted.) 
predecessor_subtree := left.greatest_subtree; 
items.put (left.greatest_subtree.root_item, root_index); 

predecessor_subtree.delete (predecessor_subtree.root_item); 

end; 

end; 

end; ——delete
```
Listing 15.9 Routines for deleting an item from a BINARY_SEARCH_TREE_ARRAY. 

### 15.4.3 Trade-Offs Between the Two Implementations 

The two implementations have the same time complexities
(this time you get to determine the complexities; see the exercises)
when no array resizing is needed. 
The trade-offs lie entirely in space management—and space consumption comparison is not as straightforward as it was with the linear object structures. 

With the linked version it is easy.
For each item, we have a node that stores three object references (to the root item, and to the left and right subtrees).
In addition, we have one such node for each empty subtree. 

The array-based version is the convoluted one.
For each node, the array stores only one object reference, that to the item itself.
So if the array is more than 3 full, it is utilizing space more efficiently.
But those full positions may not be consecutive within the array. 

A binary search tree tends to grow near its bottom, by adding items into the empty trees.
Each time we go down a level, we double the index, thus skipping many array positions.
If the array is relatively small, it is not hard to force a resizing, which can slow down insert considerably.
The only general way to avoid it is to keep the array relatively large, but then there will be many unused positions in it. 

There are other places where the array version has more overhead.
For instance, every time /eft or right is requested, a new object with two attributes (the reference to the array and the integer for root_index) is created, at least temporarily.
Another place where the linked implementation is more efficient is the single-subtree case of delete: It is faster to slide a subtree up a level in the linked version than to move and remove the inorder successor or predecessor in the array-based one. 

But it is the unpredictable space utilization within the array that makes BINARY_SEARCH_TREE_ARRAY unattractive in practice.
In fact, most object libraries do not bother to provide it.
However, there are cases where its internal representation is very G propos:
when the tree is filled not arbitrarily, but in the breadth-first order.
Then all of the occupied positions are arranged sequentially at the left side of the array, and resizing is only necessary when there are more items in the tree than positions in the array (allowing us again to have a meaningful is_/full routine). 

This situation does not arise with binary search trees (unless the user arranges the insertions very, very carefully),
but in Chapter 16 we will study an object structure that takes advantage of the array representation so well that it is the linked version of it that is rarely used. 

## 15.5 Caveat: Aliasing

The recursive model of trees is simple and elegant, but it has one danger zone: 
When several objects (trees and subtrees) share parts of an object structure, 
changes in one of them can screw up the others (this is known as the “aliasing” problem).
For example, consider the following code: 

```
'tree.make; 
tree.insert ("rigolet"); 
tree.insert ("duddo" ); 
tree.insert ("aalst"); 
subtree := tree.left; 
```

After it is performed, tree is "(((/aalst\) /duddo\) /rigolet\)" and subtree is "((/aalst\) /duddo\) ".
If next we do 
tree.wipe_out; 

what will be the value of subtree?
What should its value be? 

Well, in an ideal world, the object tracking information stored in the entity subtree would be automatically invalidated at this point (but that cannot be done in Eiffel).
We made left and right result in trees so that we could recursively use the same operations on subtrees as on the main tree, not so that our users could set up entities to track the subtrees.
After the main tree changes, 
references to what used to be its subtrees should be discarded. 

This limitation is not enforceable by preconditions, and requires programming discipline on behalf of the users.
The best we can do is document it in the contract as comments for left and right. 

```Eiffel
left:
like Current is 
——The left subtree. 
——WARNING: 
——1.
The result may become stale if the parent tree changes. 
——2.
Modifications must not be made directly to the result, 
—— 
require 
except as part of a recursive modification of the parent tree. 

not_empty:
not is_empty; 

deferred end; ——left
```
Listing 15.10 An aliasing problem warning in class BINARY_TREE. The same warning applies to right. 

So what does happen if the user ignores our warning and tries to use the left subtree after the parent tree has been wiped out?
The fastest implementations of wipe_out for the linked and array-based versions will yield different results.
In the linked version, the subtree would still exist and have the same value, but it would become disconnected from the parent tree.
In the arraybased version, the subtree would become empty. 

The two implementations could be made to yield a consistent result, but that would significantly slow down wipe_out for the main tree in at least one of them.
Consistent handling of “stale” object references is just not worth sacrificing the speed of the legitimate use of wipe_out. 

Users must also avoid bypassing the main tree to work on subtrees.
If operations are performed directly on a subtree, the integrity of the parent tree cannot be guaranteed.
For example, suppose we used the tree we built in the above example to do this: 

```
subtree.insert ("spreakley"); 
```

The result would be that tree is no longer a binary search tree, since "spreakley" is now in the left subtree of "rigolet". 

The bottom line is that the results of left and right are to be used only in recursive or read-only operations on the main tree.
An example of the warning in the contract is given in Listing 15.10. 

## 15.6 Using a Binary Search Tree in a Dictionary

Listing 15.11 shows class DICTIONARY_BST, which uses a binary search tree to do its work.
Its routines simply put together associations that the binary search tree requires.
The BST does the rest. 

```Eiffel
class DICTIONARY_BST[KEY —> COMPARABLE, VALUE] inherit 
DICTIONARY (KEY, VALUE] 

creation make 
feature {DICTIONARY BST} 

associations: 

BINARY_SEARCH_TREE_LINKED[ASSOCIATION[KEY, VALUE]], 

——The binary search tree of associations. 

feature ——Creation and initialization 
make is 
——Create a new, empty dictionary. 

do 
'!associations.make; 

end; ——make 
feature ——Adding, removing, and checking associations 
value (key: KEY): VALUE is 
——The value associated with key in this dictionary. 
——Void if there is no such association. 

local 
pattern: ASSOCIATION[KEY, VALUE]; 
match: ASSOCIATION|KEY, VALUE]; 

do 
'\pattern.make; 
pattern.set_key (key); 

match := associations.item_equal_to (pattern); 

if match /= Void then 
Result := match.value; 
end; ——else leave Result void. 

end; ——value 
put (new_value: VALUE;
key: KEY) is 
——Insert an association of key and new_value into this dictionary. 
——If the dictionary already contains an association for key, replace it. 

local 
pattern: ASSOCIATION[KEY, VALUE]; 
match: ASSOCIATION|KEY, VALUE}; 

do 
'\pattern.make; 
pattern.set_key (key); 

match := associations.item_equal_to (pattern); 

if match = Void then 
'!match.make; 
match.set_key (key); 
match.set_value (new_value); 

associations.insert (match); 

else 
match.set_value (new_value); 

end; 
end; ——put 
delete (key: KEY) is 
——Delete the association for key from this dictionary. 

local 
pattern: ASSOCIATION [KEY, VALUE); 

do 
'\pattern.make; 
pattern.set_key (key); 

associations.delete (pattern); 

end; ——delete 
wipe_out is 
——Make this dictionary empty. 

do 
associations.wipe_out; 

end; ——wipe_out 
feature ——Sizing 
size: INTEGER is 
——The number of associations currently in this dictionary. 

do 
Result := associations.size; 

end; ——size 
is_empty: BOOLEAN is 
——Is this dictionary empty? 

do 
Result := associations.is_empty; 

end; ——is_empty 
is_full: BOOLEAN is 
——Is there no room in this dictionary for one more association? 

do 
Result := associations.is_full; 

end; ——is_full 

feature ——Comparisons and copying 
copy (other:
like Current) is 
——Copy other onto Current. 

do 
associations := clone (other.associations); 

end; ——copy 
is_equal (other:
like Current): BOOLEAN is 
——Do this dictionary and other associate the same values ——with the same keys? 

do 
Result := associations.out.is_equal (other.associations.out); 

end; ——is_equal 
feature ——Simple input and output 
out: STRING is 
——"< (<key,>.out,<value,>.out) ... (<key,>.out,<value,>.out) >". 

do 
Result := clone("< "); 
Result.append_string (associations.out); 
Result.append_string(" >"); 

end; ——out 
invariant 
have_list:
associations /= Void; 

end ——class DICTIONARY_BST
```
Listing 15.11 Class DICTIONARY _BST, which uses a binary search tree to keep track of its associations. 

# Summary 

A binary search tree is a two-dimensional object structure that directly supports binary searching.
It is a binary tree in which each subtree’s root item serves as the separator between the left subtree, which tracks items that are less than the separator, and the right subtree, which tracks the rest. 

Binary trees can be implemented as linked or array-based structures. 
The array-based implementation follows the breadth-first traversal, which will prove very useful in the following chapter. 

# Exercises 
1. Write feature size for class BINARY_TREE.
What is its time complexity if 
left and right are both O(1)? (Draw the execution chart.) 

2. Write feature is_equal for class BINARY_TREE. 

3. Write features out_inorder and out_postorder for class BINARY_TREE. 

4. Using pencil, paper, and the insert algorithm of class BINARY_SEARCH_TREE_LINKED, insert the following sequence of STRING objects into a tree that is initially empty: 

    1. "funary" "bindle "aa1st",  “dattuck", "rigolet™, "duddo", "harbottle", "knaptoft", "Scramoge", "spreakley". 
    2. "aalst“"bindle*,“daituek", "duddo",hunmary 4) "“harborttie™, "knaptoft", "rigolet", "scramoge", "spreakley". 

What is the time complexity of item_equal_to on the tree created in part (a)?
What is its time complexity on the tree created in part (b)? 

5. Using the deletion algorithm described in Section 15.4.1, delete the following strings from the tree you drew in part (a) of the previous exercise. Do them in sequence (first part (a),
then part (b), etc.). 

a."aalst" 
b. "duddo" 
c. "harbottle" 
d. "filunary" 

6. Show that the time complexity of insert and delete in both BINARY_SEARCH_TREE_LINKED and BINARY_SEARCH_TREE_ARRAY is O(log N). (In the case of the array-based version of delete, show it for the cases where resizing is not necessary. ) 

7. Write feature wipe_out for BINARY_SEARCH_TREE_ARRAY so that it works in O(N) time (and not O(capacity)).
Which traversal did you use? 

8. Write a faster is_equal implementation for BINARY SEARCH_TREE_ARRAY. 
9. Complete class BINARY_SEARCH_TREE_LINKED. 
10. Complete class BINARY SEARCH_TREE_ARRAY. 
11. A general traversal feature would perform an arbitrary operation at each node.
In Eiffel, it is impossible to pass an arbitrary routine to a feature, 
since routines do not exist outside objects.
Suggest an alternative way to write a general binary tree traversal routine. 
#### TODO this is no longor true with Agents

12. Suggest a redefinition of out_breadth_first for BINARY SEARCH_TREE_ARRAY. Does it improve the time complexity of the routine? the space complexity? 
13. What would happen if to_do in owt_breadth_first was not a queue but a stack?
