# 13 Faster Sorting

The three sorting algorithms we discussed in Chapter 12
(insertion sort, bubble sort, and selection sort) have the time complexity of O(N2)
-acceptable for short object structures, but bogging down considerably as the structures grow longer.
There are also three commonly used sorts that have a much lower complexity.
We will study two of them 
(merge sort and quick sort) in this chapter,
but we have to postpone the third (heap sort) until Chapter 16.
We will conclude this chapter with a discussion on how to pick the best sorting algorithms for given
circumstances.

## 13.1 Merge Sort 

Suppose you had two lists that were already sorted.
How would you merge them into one sorted list?
Easy: Pick the lesser of the leftmost items of the two lists,
then pick the lesser of the leftmost unpicked items of the two lists,
and so on.
Using the LIST contract,
we can do it as shown in Listing 13.1.

Fine, but what does that have to do with sorting?
Well, suppose we had a list whose left half-list was sorted and whose right half-list was sorted.
Then we can use the same algorithm to merge the two sorted half-lists into the sorted full list.
Of course, we cannot tell our users that our sort routine only works for
lists in which the left half is already sorted and the right half is already sorted.

So how do we get a list with a sorted left half-list and a sorted right halflist?
Well, suppose we had half-lists where the left quarter-lists were sorted
and the right quarter-lists were sorted.
Then we could merge the respective sorted quarter-lists into sorted half-lists.
And we get those by merging sorted eighth-lists, and so on.
In other words, we can use the same algorithm to sort

```
merged_list (list1, list2: LIST): LIST is
require
    lists_sorted: list1.is_sorted and then list2.is_sorted;
do
    -- As long as both lists are not off-right,
    -- keep appending the lesser of the two lists' items to the right end of Result.
    from
        !!Result.make;
        list1.move_off_left;
        list1.move_right;
        list2.move_off_left;
        list2.move_right;
    until
        list1.is_off_right or list2.is_off_right
    loop
        if list1.item < list2.item then
            Result.insert_on_right(list1.item);
            list1.move_right;
        else
            Result.insert_on_right(list2.item);
            list2.move_right;
        end;
        Result.move_right;
    end;

    -- Get the rest of list1, if any.
    from
    until
        list1.is_off_right
    loop
        Result.insert_on_right(list1.item);
        list1.move_right;
        Result.move_right;
    end;

    -- Get the rest of list2, if any.
    from
    until
        list2.is_off_right
    loop
        Result.insert_on_right(list2.item);
        list2.move_right;
        Result.move_right;
    end;
ensure
    result_sorted: Result.is_sorted;
end; -- merged_list
```
#### Listing 13.1 An algorithm for building a sorted list out of two sorted lists.

the smaller sublists.
When do we stop?
When we get a sublist that is empty or that only has one item in it-a list like that is already sorted.
In pseudocode 
(that’s computerese for “just an outline of the algorithm,
don’t even try compiling it”),
the `merge_sort` feature looks like this:

```
merge_sort(<range within this list>) is
    -- Sort this range of this list.
do
    if <length of the range> > 1 then
        <find the middle of the range>;
        merge_sort(<left half of the range>);
        merge_sort(<right half of the range>);
        merge(<left half of the range>, <right half of the range>);
    end;
end; -- merge_sort
```

This is called a recursive algorithm.
An algorithm is a script for performing a task;
any algorithm that breaks its task into smaller tasks and uses the
same script to perform at least one of them is recursive.
In order for a recursive algorithm to bring its task to completion
(“to terminate” in computer science slang),
two things must be true about it:

1. Every time the script is recursively invoked,
it must be given a smaller problem to solve.
2. It must include at least one way to solve sufficiently small problems without recursively invoking the script.

The merge sort algorithm gets smaller problems every time:
The range it gets is half as long as before.
It also has a way to sort ranges that are short enough without using recursion:
Ranges that are empty or only have one item in it are already sorted,
so the algorithm does nothing-which certainly does not involve invoking the script again.

### 13.1.1 The Array Version

The merge sort algorithm is easy to use with the array implementation of lists.
A sublist is simply denoted with the range of array indices that it overlays.
To find the middle of the sublist,
we simply find the mean index of the range:

$$
<middle index> = \lfloor \frac{<leftmost index> + <rightmost index>}{2} \rfloor
$$


If the range contains an even number of positions,
the exact middle falls between two indices (position “x.5”),
so we just truncate the “.5” and call the index immediately to the left of the exact middle “the middle index.” The Eiffel operator for integer division, 
which truncates the fractional part, is “//”
(and the remainder operator is “\\”).

First, let us do the hidden routine merge.
The algorithm wants two sublists,
so the simple thing to do is pass it the boundary indices of those ranges as four parameters.
However, since we know that in merge sort we are always
merging adjacent sublists,
it’s enough to pass three parameters
—`first_left`, `first_right`, and `last_right`—
knowing that the last index in the left subrange is `first_right — 1`.

The routine, shown in Listing 13.2,
creates a spare array to keep the object references in sorted order.
After the merging is done, those references are copied back into items.


```Eiffel
merge (first_left, first_right, last_right: INTEGER)
    -- Merge the sorted regions [first_left, ..., first_right-1] and
    -- [first_right, ..., last_right] into one sorted region [first_left, ..., last_right].
local
    merged: like items;  -- Temporary array to track merged items.
    left_index, right_index, merged_index: INTEGER;
do
    !!merged.make(first_left, last_right);
    
    -- Merge them while they are both unempty.
    from
        left_index := first_left;
        right_index := first_right;
        merged_index := first_left;
    invariant
        -- merged.item(first_left), ..., merged.item(merged_index-1)
        -- are sorted.
    variant
        last_right - merged_index
    until
        left_index >= first_right or right_index > last_right
    loop
        if items.item(left_index) < items.item(right_index) then
            merged.put(items.item(left_index), merged_index);
            left_index := left_index + 1;
        else
            merged.put(items.item(right_index), merged_index);
            right_index := right_index + 1;
        end;
        merged_index := merged_index + 1;
    end;
    
    -- Copy whatever remains in the left subrange.
    from
        -- Everything is ready.
    invariant
        -- merged.item(first_left), ..., merged.item(merged_index-1)
        -- are sorted.
    variant
        first_right - left_index - 1
    until
        left_index >= first_right
    loop
        merged.put(items.item(left_index), merged_index);
        left_index := left_index + 1;
        merged_index := merged_index + 1;
    end;
    
    -- Copy whatever remains in the right subrange.
    from
        -- Everything is ready.
    invariant
        -- merged.item(first_left), ..., merged.item(merged_index-1)
        -- are sorted.
    variant
        last_right - right_index
    until
        right_index > last_right
    loop
        merged.put(items.item(right_index), merged_index);
        right_index := right_index + 1;
        merged_index := merged_index + 1;
    end;
    
    -- Copy the merged references back.
    from
        merged_index := first_left;
    invariant
        -- merged.item(first_left), ..., merged.item(merged_index-1)
        -- are sorted.
    variant
        last_right - merged_index
    until
        merged_index > last_right
    loop
        items.put(merged.item(merged_index), merged_index);
        merged_index := merged_index + 1;
    end;
end; -- merge
```
Listing 13.2 Hidden routine merge of class MERGESORTABLE_LIST_


The next thing to do is write the recursive merge_sort routine (also hidden).
Shown in Listing 13.3, it is a straightforward translation of the algorithm.
What little remains to be written of class MERGESORTABLE_LIST_ARRAY
is left up to you.

```
merge_sort(leftmost, rightmost: INTEGER) is
    -- Merge-sort the region [leftmost, ..., rightmost].
local
    middle: INTEGER;
do
    if leftmost < rightmost then
        middle := (leftmost + rightmost) // 2;
        -- Sort the two halves of this range.
        merge_sort(leftmost, middle);
        merge_sort(middle + 1, rightmost);
        -- Merge the two sorted halves of this range.
        merge(leftmost, middle + 1, rightmost);
    end;
end;
-- merge_sort
```
Listing 13.3 Hidden routine merge_sort of class MERGESORTABLE_LIST_ARRAY.

### 13.1.2 Performance Analysis of the Array Version

Before attempting the linked list version of the merge sort algorithm,
let us analyze the time complexity of what we have so far.
Unlike the algorithms in Chapter 12,
this time we do not have a sequence of passes or sweeps to record.
What do we have? We have levels of recursion.

At the first level of recursion,
the middle is found,
which is a simple division by two,
which is $O(1)$,
and requires no marker.
Then the algorithm has to wait for merge_sort of the left half-list to terminate.
We don't know yet how many markers that is going to take,
so let us just draw a blank box under the left half of the list;
we will fill it in later.
Then we have to wait for merge_sort
of the right half-list to terminate—another blank box.
Now we merge the two half-lists,
an action that touches every item
(as its reference is copied into the merged array and later as it is copied back).
So we place one marker under each array position,
resulting in Figure 13.1a.

Let us now fill in the two level 2 boxes.
Every merge_sort of a half-list has to find the middle,
then wait for merge_sort of the left quarter-list (a blank box),
then wait for merge_sort of the right quarter-list (another blank box),
then merge the quarter-lists (N/2 items).
This gets us Figure 13.1b.

Filling in the level 3 boxes,
in each level 2 box we find the middle,
wait for two level 4 blank boxes, then merge N/4 items 
(Figure 13.1c).

![](https://img.plantuml.biz/plantuml/svg/nLGn3i8m3Dpp2kyeGHGUq7mWAxD53KHg4vHOJ7byarQ20GP0eRtXP3kHJdUot4R6m9rbH93IUHdfXW7PUYVW1HkPKPFUQ2I0NQ4cqxwqXsdsDIcbScKWhUIZEbRI-5TMHxGCPnzAdPvo0uKBGVI1mMmRi4n3V3n-_6yH7tmb1yZGqvtwlBHPzwIrhacB-FXfiURypHoyQCbrqn4H8m00)

[source](https://editor.plantuml.com/uml/nLGn3i8m3Dpp2kyeGHGUq7mWAxD53KHg4vHOJ7byarQ20GP0eRtXP3kHJdUot4R6m9rbH93IUHdfXW7PUYVW1HkPKPFUQ2I0NQ4cqxwqXsdsDIcbScKWhUIZEbRI-5TMHxGCPnzAdPvo0uKBGVI1mMmRi4n3V3n-_6yH7tmb1yZGqvtwlBHPzwIrhacB-FXfiURypHoyQCbrqn4H8m00)

a. Execution trae of the first level of recursion.

![](https://img.plantuml.biz/plantuml/svg/SoWkIImgISaiIKnKq7NbKi00shf0G4q2Ynqr2Wg68C88I1Y3k2PWCP89FJqz8CjFeMQ0_45rC41sq2oioXCpInJIyeiK855Md5zKek2dRwAGMPAQMqoX65tyKPAHcgUGMAAGargMcWDCho2t93iwEYeevAOMfQV2N6K4SnK2mDGf450w4Fum1DaBSXur2RhuWwmC0Wb_FqZ0SpcavgM0opyk0000)

[source](https://editor.plantuml.com/uml/SoWkIImgISaiIKnKq7NbKi00shf0G4q2Ynqr2Wg68C88I1Y3k2PWCP89FJqz8CjFeMQ0_45rC41sq2oioXCpInJIyeiK855Md5zKek2dRwAGMPAQMqoX65tyKPAHcgUGMAAGargMcWDCho2t93iwEYeevAOMfQV2N6K4SnK2mDGf450w4Fum1DaBSXur2RhuWwmC0Wb_FqZ0SpcavgM0opyk0000)

b. Execution trace of the first two level of recursion.

![](https://img.plantuml.biz/plantuml/svg/nLJB2eD03Bpx5NClMhGUUdGFlVeFIqrRmGViXlQo7zzT9LXeeIYYEGoJ4CXCzb5OreQhchL6V8dm5OVOnvhmOuO3qW2PXrD8yw4s6v8ayQo4syd7wh6bZvUk6RVUUEfiRnZbyVp987G1syG7FwY3PZJqf2RS8xYhKafKvAYPMZklDkL1ynu-iZ0NevYMp9r4PpRfaf0-_6dTmqSgvx4cRE9ZqKCVzr-EYuyAwghXZutU)

[source](https://editor.plantuml.com/uml/nLJB2eD03Bpx5NClMhGUUdGFlVeFIqrRmGViXlQo7zzT9LXeeIYYEGoJ4CXCzb5OreQhchL6V8dm5OVOnvhmOuO3qW2PXrD8yw4s6v8ayQo4syd7wh6bZvUk6RVUUEfiRnZbyVp987G1syG7FwY3PZJqf2RS8xYhKafKvAYPMZklDkL1ynu-iZ0NevYMp9r4PpRfaf0-_6dTmqSgvx4cRE9ZqKCVzr-EYuyAwghXZutU)

c. Execution trace of the first three level of recursion.

Figure 13.1 The execution chart for the MERGESORTABLE_LIST_ARRAY’s `merge_sort` routine.

We keep doing that until all the boxes get to be only 1 item wide (or empty),
where there is no waiting involved.

Tallying up the markers,
we see that at every level we have a total of $N$ markers.
How many levels are there?
At every level, the range length is cut in half.
We start with $N$ items,
so how many times can $N$ be divided by two,
before we get to ranges of size 1?
We are looking for x such that 

$$\left(\frac{1}{2}\right)^x N = 1$$

That is easy enough to solve:

$$\begin{align}
N &= 2^x \\
\log_2 N &= x
\end{align}$$

So the tally diagram looks like Figure 13.2.
The markers form a rectangle $O(N)$ across and $O(\log_2 N)$ high,
for a total time complexity of $O(N log_2 N)$.

![](https://img.plantuml.biz/plantuml/svg/SoWkIImgISaiIKnKq7NbKi00shf0G4q2Ynqr2Wg68C88I1Y3k2PWCP89FJqz8CjFeMQ0_45rG0z_w480n3y-gMMfEGev-Ud0K0I6QBAZeoCr2QWVw18_CBkm1MAD0iWvr6GDWCUm-GlieEByeX85FtqJXSoIrDnYqiGGV8Y_84bXOFoL0qwCHaWXdPjQb9uASxSHmfsOyOfVwS365yHVXWf3F8FfGW2E0fq0g0CNCCG2dFwX8j3cud98pKi1LuK0)

[source](https://editor.plantuml.com/uml/SoWkIImgISaiIKnKq7NbKi00shf0G4q2Ynqr2Wg68C88I1Y3k2PWCP89FJqz8CjFeMQ0_45rG0z_w480n3y-gMMfEGev-Ud0K0I6QBAZeoCr2QWVw18_CBkm1MAD0iWvr6GDWCUm-GlieEByeX85FtqJXSoIrDnYqiGGV8Y_84bXOFoL0qwCHaWXdPjQb9uASxSHmfsOyOfVwS365yHVXWf3F8FfGW2E0fq0g0CNCCG2dFwX8j3cud98pKi1LuK0)

#### Figure 13.2 Tallying up execution markers.

How does that compare with the performance of the algorithms in Chapter 12?
All of those were $O(N^2)$ routines.
If a list had a million items,
it would take on the order of a trillion (a million million) steps to sort them with an $O(N^2)$ algorithm.
With an $O(N \log_2 N)$ algorithm,
it would take on the order of ... 
now,
put away that calculator,
a computer scientist should be able to do base-2
logarithms in his or her head.
It’s easy
—all you need to remember is that 1K (1024) is exactly $2^10$.
So a million is about 1M, which is $1K X 1K$, which is $2^20$.
Thus, $\log_2 1M = 20$.

So, to merge sort a million items would only take about 20 million steps—
much better than the 1,000,000 million steps that,
say, bubble sort would take.

While we are on the subject of logarithms,
let us take a simplifying step.
Instead of writing “$O(\log_2 N)$,” 
we can simply write “$O(\log N)$.”
There are two reasons for it:

1. As computer scientists,
we deal with powers of 2 more than with powers of
10 or e, so we usually talk about base-2 logarithms,
not base-10 or natural (base-e) logarithms.

2. With the big O notation,
it does not matter what the base of the logarithm is,
since it only changes a constant ($\log_a  x = k \log_b x$ for any $a$ and $b$),
and constants are discarded.

### 13.1.3 The Singly Linked Version

Merge sorting a linked list is similar to merge sorting an array-based list,
but there are a few details to consider.

The first detail is delimiting the range.
In the array-based version,
we used the index of the leftmost item and the index of the rightmost item.
The list analog to that is using references to the leftmost and the rightmost nodes.
If we sort the range by moving the nodes around,
we are likely to lose track of the range because the leftmost and rightmost nodes may move.
So instead we identify the range by the node just left of the leftmost node
(we need it anyway to avoid insertions on left)
and the length of the range
(i.e., the number of nodes to the right of the left-of-leftmost node that form the range).

The second detail is finding the middle of the range.
Since the items are not numbered,
we cannot just compute the average of the leftmost and rightmost positions.
Instead, we have to move right, counting off to half of the range’s length.

The code that does that is given in Listing 13.4.
It should be studied as an example of how many engineering decisions might still be needed after the
basic algorithm is understood.
While you are studying it,
draw the execution trace chart for it and convince yourself that this implementation’s time complexity is also $O(N log N)$.

```Eiffel
feature {NONE}
    merge_sort (left_of_first: like off_left; sublist_length: INTEGER) is
        -- Merge sort the region of sublist_length
        -- to the right of the node tracked by left_of_first.
    local
        left_length: INTEGER;
            -- Length of the left half of the range.
        last_left: like off_left;
            -- Last node of the left half-range.
        counter: INTEGER;
    do
        if sublist_length > 1 then
            -- Identify and sort the left half of the sublist.
            left_length := sublist_length // 2;
            merge_sort (left_of_first, left_length);
            
            -- Identify and sort the right half of the sublist.
            from
                last_left := left_of_first;
                counter := 0;
            variant
                left_length - counter - 1
            until
                counter = left_length
            loop
                last_left := last_left.right;
                counter := counter + 1;
            end;
            
            merge_sort (last_left, sublist_length - left_length);
            
            -- Merge the two halves.
            merge (left_of_first, last_left, sublist_length - left_length);
        end;
    end; -- merge_sort

    merge (left_of_first_left, last_left: like off_left; right_length: INTEGER) is
        -- Merge the sorted regions [left_of_first_left.right, ..., last_left]
        -- and right_length items to the right of last_left into one sorted region.
    local
        last_merged: like off_left;
            -- Tracks last merged node.
        next_left: like off_left;
            -- Next nodes to compare.
        next_right: like off_left;
        right_counter: INTEGER;
    do
        -- Merge them while they are both unempty.
        from
            last_merged := left_of_first_left;
            next_left := left_of_first_left.right;
            next_right := last_left.right;
            right_counter := 1;
        invariant
            -- left_of_first_left.right.item, ..., last_merged.item are sorted.
        -- variant
            -- Sum of unmerged segments of the two subranges
        until
            next_left = last_left.right or right_counter > right_length
        loop
            if next_left.item < next_right.item then
                last_merged.set_right (next_left);
                last_merged := next_left;
                next_left := next_left.right;
            else
                last_merged.set_right (next_right);
                last_merged := next_right;
                next_right := next_right.right;
                right_counter := right_counter + 1;
            end;
        end;

        -- Attach whatever remains to the merged sublist
        -- and attach the rest of the list to its end.
        if next_left = last_left.right then
            last_merged.set_right (next_right);
            -- The rest of the list is already attached to the end of the right sublist.
        else
            last_merged.set_right (next_left);
            -- next_right is now one step beyond the right half-range.
            last_left.set_right (next_right);
        end;
    end; -- merge
```
Listing 13.4 Sorting routines for class MERGESORTABLE_LIST_SINGLY_



13.2 Quick Sort

Another commonly used recursive sorting algorithm is quick sort.
The basic algorithm is this:

```
quick_sort (<range within this list>) is
    -- Sort this range of this list.
do
    if <length of the range> > 1 then
        <pick a "pivot" item p from within the range>
        <put all items <= p into the left subrange>;
        <put all items >= p into the right subrange>;
        
        quick_sort (<the left subrange>);
        quick_sort (<the right subrange>);
    end;
end; -- quick_sort
```

If the picking of p and the partitioning of the range into the “<=” and “>=” subranges can be done in the time proportional to the length of the subrange,
then we can get an execution trace very similar to that of merge sort (Figure 13.2).
Assuming that p was picked so that the range is split down the middle
(in other words, p is the median object of the range),
we get the picture in Figure 13.3a.
Unfortunately, if we always pick the worst p
—either the least or the greatest object in the range—
we wind up with Figure 13.3b, which is $O(N)$.

![](https://img.plantuml.biz/plantuml/svg/SoWkIImgISaiIKnKi57GrStBrorEBKWiIYp9pC-3yZCIK_BBYxaKC82sBX1Gay1YHus2WY68C08InY2k2LYCP49FJm_8ybEeeOi_w669BWGW0YqdjImr1nXQGEycEpewKfE0HGOz_8LX5yHVHk1e1Ba6qmsOYOPOTGFfBoHtO74kDZyGBvQJdqwln0wt4slkXJcEMYpSWKZR2FC19q98i0xn3AOB0JXAMmAW3kn_OW5E_r0H04jRXzIy570T1W00)

[source](https://editor.plantuml.com/uml/SoWkIImgISaiIKnKi57GrStBrorEBKWiIYp9pC-3yZCIK_BBYxaKC82sBX1Gay1YHus2WY68C08InY2k2LYCP49FJm_8ybEeeOi_w669BWGW0YqdjImr1nXQGEycEpewKfE0HGOz_8LX5yHVHk1e1Ba6qmsOYOPOTGFfBoHtO74kDZyGBvQJdqwln0wt4slkXJcEMYpSWKZR2FC19q98i0xn3AOB0JXAMmAW3kn_OW5E_r0H04jRXzIy570T1W00)



a. Best case: the median is always picked as the pivot.

`![](https://img.plantuml.biz/plantuml/svg/tTSn3eCW5CRntLEm6qXgUm2vGEz0AaCJqw4bdJnyKL9DAoh82_dY6rxKXVpykrY_Z7gQvcwKOWMRJSdjK2xF6HrZftvLTftxsylmB7e98UpLbNLP73aEuMwcbzRgjsxjsxBScvIISdrZv73DpdAkwg0kwbxZDt-SNYC9mKNJwvU4u4hkvI4Xk7RsMjB0kE9xRPCGN56z0aa8hj1UCIG4Lq2lQ1A2QxtNFXA2Qx5N0Wd1vUkLIa9m_VKY8I6ufbvqfAmkxgOiQlreXd_a3m00)

[source](https://editor.plantuml.com/uml/tTSn3eCW5CRntLEm6qXgUm2vGEz0AaCJqw4bdJnyKL9DAoh82_dY6rxKXVpykrY_Z7gQvcwKOWMRJSdjK2xF6HrZftvLTftxsylmB7e98UpLbNLP73aEuMwcbzRgjsxjsxBScvIISdrZv73DpdAkwg0kwbxZDt-SNYC9mKNJwvU4u4hkvI4Xk7RsMjB0kE9xRPCGN56z0aa8hj1UCIG4Lq2lQ1A2QxtNFXA2Qx5N0Wd1vUkLIa9m_VKY8I6ufbvqfAmkxgOiQlreXd_a3m00)


b. Worst case: the least item is always picked as the pivot.
(Picking the great est one is just as bad.)

#### Figure 13.3 Execution charts for the quick sort algorithm.

Merge sort is always $O(N \log N)$,
while quick sort tends to be $O(N \log N)$ but can get as bad as $O(N^2)$.
The obvious question is 
“Why not just stick to merge sort?”
The answer is practical:
When quick sort does perform in $O(N \log N)$
(as it usually does),
it can work faster than merge sort.
They have the same time complexity,
but quick sort can be written to have a significantly smaller constant.

Much research has gone into finding the quickest version of quick sort.
It has concentrated on two questions:

1. How can one quickly pick a good pivot item?
2. How can one quickly partition a range around a pivot?

The answers that we will use,
at least for the array implementation,
are the ones discussed by Robert Sedgewick [9] and Mark Allen Weiss [11],
with a slight modification.

### 13.2.1 The Array Version

Ideally, the pivot would be the median item,
but finding the exact median takes too much time.
A compromise that has proven to work well in practice is to compare the leftmost,
the middle, and the rightmost items, and pick the median of just those three.

The partitioning of the range is rather straightforward:

1. Scan the range from left to right until an item that is “>=” than the pivot is found.

2. Scan the range from right to left until an item that is “<=” than the pivot is found.
3. Swap those two items.
4. Repeat until the left-to-right scan meets the right-to-left scan.
5. Where the scans meet is where the partition needs to be. Swap the boundary item with the pivot.

To find the median of the leftmost,
middle, and rightmost items,
we need to write an intricate if statement that checks for the various combinations of the comparisons between each pair of the three items.
While we are doing all that work,
we may as well do some sorting:
Instead of just comparing those three items,
we can sort them among themselves.
Routine `sort_3` in Listing 13.5 serves that purpose

```Eiffel
sort_3 (position1, position2, position3: INTEGER) is
    -- Sort the items tracked by position1,
    -- position2, and position3 of items.
do
    if items.item (position1) > items.item (position2) then
        swap (position1, position2);
    end;
    
    if items.item (position1) > items.item (position3) then
        swap (position1, position3);
    end;
    
    if items.item (position2) > items.item (position3) then
        swap (position2, position3);
    end;
ensure
    sorted: items.item (position1) <= items.item (position2)
        and then items.item (position2) <= items.item (position3);
end; -- sort_3
```
#### Listing 13.5 A routine to sort three items for class QUICKSORTABLE_LIST_ARRAY.


(using a short routine swap, which exchanges items tracked by two positions of the internal array items).
Let us now study routine quick_sort itself (Listing 13.6).
This routine provides two ways out of the recursion:
1. If the range is empty or is of length 1,
then it is already sorted, so nothing is done.
2. If the range is of length 2 or 3,
then a simple call to sort_3 is used to sort it.

```Eiffel
quick_sort (leftmost, rightmost: INTEGER) is
    -- Quick sort the region [leftmost, ..., rightmost].
local
    middle: INTEGER;
    left_index, right_index: INTEGER;
    pivot: ITEM;
do
    if leftmost + 3 < rightmost then
        middle := (leftmost + rightmost) // 2;
        -- Presort the leftmost, the middle, and the rightmost items.
        sort_3 (leftmost, middle, rightmost);

        -- Items in positions leftmost and rightmost are now in correct
        -- partitions. Swap the rightmost item still to be partitioned
        -- (in position rightmost-1) with the pivot, and partition items in positions
        -- leftmost+1 through rightmost-2.
        pivot := items.item (middle);
        swap (middle, rightmost - 1);
        from
            left_index := leftmost;  -- Set up for pre-incrementing loops.
            right_index := rightmost - 1;
        invariant
            -- items.item (leftmost), ..., items.item (left_index) <= pivot
            -- items.item (right_index), ..., items.item (rightmost) >= pivot
        variant
            right_index - left_index
        until
            left_index > right_index
        loop
            -- The inner loops must pre-increment, otherwise when pivot,
            -- items.item (left_index) and items.item (right_index)
            -- are all equal, the outer loop becomes infinite.

            from
                left_index := left_index + 1;
            until
                items.item (left_index) >= pivot
            loop
                left_index := left_index + 1;
            end;

            from
                right_index := right_index - 1;
            until
                items.item (right_index) <= pivot
            loop
                right_index := right_index - 1;
            end;

            if left_index <= right_index then
                swap (left_index, right_index);
            end;
        end;

        -- Place the pivot between the two partitions.
        swap (left_index, rightmost - 1);
        quick_sort (leftmost, left_index - 1);
        quick_sort (left_index + 1, rightmost);
    elseif leftmost < rightmost then
        -- Range length is either 2 or 3. Just use sort_3 on it.
        sort_3 (leftmost, leftmost + 1, rightmost);
    end;
end; -- quick_sort
```
#### Listing 13.6 Routine quick_sort for class QUICKSORTABLE_LIST_ARRAY.

If the range length is greater than 3,
then it is partitioned as we discussed earlier and the two subranges are recursively sorted.
The portion of the if statement that performs the partitioning and the recursive calls
(the first in Listing 13.6) is thus the most complicated one.
It is illustrated in Figure 13.4.

First, we find the middle of the range and use sort_3 to sort the middle,
leftmost, and rightmost items in the range,
and use the new middle item as the pivot (Figure 13.4a).
After that is done,
we know that the item in the leftmost position is “<=” the pivot
(which is now in the middle position),
and the item in the rightmost position is “>=” the pivot.
In other words, they are already in the correct partitions.
The rest of the partitioning process only needs to work on the range `[leftmost +1, ..., rightmost—1]`.

The next thing we do is get the pivot out of the way for the time being,
by swapping it with the rightmost item still to be partitioned
—the one tracked by local entities of quick_sort position `rightmost—1` (Figure 13.4b).

![](https://img.plantuml.biz/plantuml/svg/VPB1JiCm38RlUGghHwHDAr1WrQZs2cCFK7cjrqLDavAu28JsxiGjQX67-P0uN_BRZfDzOFGyT4P5wx5giI5u7tJLbi5vXjtkZIf6snWg2lXM2g9rs0DwNsgcBaG8lvR2Qm5UDyuGp_1UOAWyTgwXcJu8hP5vgDePFWf4JCEYpiPpGrsx6Jq9kiIgJuxPB26VXP_rOD5_pV1bpDvxmjRGWhU2JzhMV_JfHc1hiJVkF5Lm7KSbzqsCgz00MTQiAII00Gv7kNodwnW6H9mfC7JcCWQcpqJ8Hab3BlzGhpySHr_1rCBeNPKw7FDyMj-jLiNIOQMiOu947cJCAqwPgcc2zPXWlLu4UNvpCxkft4WfqVPaQ_aNFm00)

[source](https://editor.plantuml.com/uml/VPB1JiCm38RlUGghHwHDAr1WrQZs2cCFK7cjrqLDavAu28JsxiGjQX67-P0uN_BRZfDzOFGyT4P5wx5giI5u7tJLbi5vXjtkZIf6snWg2lXM2g9rs0DwNsgcBaG8lvR2Qm5UDyuGp_1UOAWyTgwXcJu8hP5vgDePFWf4JCEYpiPpGrsx6Jq9kiIgJuxPB26VXP_rOD5_pV1bpDvxmjRGWhU2JzhMV_JfHc1hiJVkF5Lm7KSbzqsCgz00MTQiAII00Gv7kNodwnW6H9mfC7JcCWQcpqJ8Hab3BlzGhpySHr_1rCBeNPKw7FDyMj-jLiNIOQMiOu947cJCAqwPgcc2zPXWlLu4UNvpCxkft4WfqVPaQ_aNFm00)

a. The middle is located. It will be sorted with the leftmost and rightmost items in the range.


![](https://img.plantuml.biz/plantuml/svg/TP9BRi8m48RtFiKeoqeWGajR8eYu0kK0Q4Y6OCMnKtlIXohkNazI9QLI_uLbV_CUUHSOFNUDKL4j5ZLM1A-TBkfZS9vXitcXWj5MXl8SlfI2g0PRGE-Fcga94SAFKjZcK7PbwKQq51GAZushQAJtlICoTqKzmWU1Y6dW4Qq4rHPRuyuJVHHwYMsV7BEPiZu9F-lEelySuNFVGEi9QqCJNWi-QLl-YayN0hskdA6XshK_bSoR65UW0RAiMLD800Fi3p9yeykO1IHsfS3GcOynBtqaGXPA4bx-e5Q_EOvt1SCAu-sgrFwGPSFxRZRBfmttXY74tHYoRAMKTKoGX7Ti-vxiKjabpFkYy_cjxp-6jHIFsf4jvITy0m00)

[source](https://editor.plantuml.com/uml/TP9BRi8m48RtFiKeoqeWGajR8eYu0kK0Q4Y6OCMnKtlIXohkNazI9QLI_uLbV_CUUHSOFNUDKL4j5ZLM1A-TBkfZS9vXitcXWj5MXl8SlfI2g0PRGE-Fcga94SAFKjZcK7PbwKQq51GAZushQAJtlICoTqKzmWU1Y6dW4Qq4rHPRuyuJVHHwYMsV7BEPiZu9F-lEelySuNFVGEi9QqCJNWi-QLl-YayN0hskdA6XshK_bSoR65UW0RAiMLD800Fi3p9yeykO1IHsfS3GcOynBtqaGXPA4bx-e5Q_EOvt1SCAu-sgrFwGPSFxRZRBfmttXY74tHYoRAMKTKoGX7Ti-vxiKjabpFkYy_cjxp-6jHIFsf4jvITy0m00)

b. The median of the leftmost, middle, and rightmost items is now the pivot.
The unpartitioned section has narrowed by one on each side,
since the leftmost and rightmost items are where they belong. 
The pivot will be swapped with the rightmost unpartitioned item to get it out of the way.

![](https://img.plantuml.biz/plantuml/svg/RP9TJiCm3CVVSmfhZqYTs62mLQFQ5SOEK7cjrqLDavAw28HsT-8KsWtXXoR-kVxxGzbrZ9xxngXWBHOrLWHllIxgl7EUORjzfOBHLeQo3BwKWc0Dje3UvvgfwGA47rl0ImPbNvPkH4j1NU6nSHMDz27-YCnzKO_mKI3YekCHhGJL5blZJXDz4deERHyTivbKduMVT6_HVuvm7HjeFM5jQC8RmKTjowlynRr0hojdQAXsYLybyywCAz00MTQigPi1Th0_oF2DBeCAIEvAWQ4Jvq6NFcP2xfK8dl-WLhyx3dS5mmh3xQBK_f2cWt-N9DcquHWOKjnD84qtIbd75BeBPHDsIImM5eusTXYxOPT7h6uycCTZVYst_9MB8T6Jb4bk62Ke25OttdzoQvags8viAK_i6m00)

[source](https://editor.plantuml.com/uml/RP9TJiCm3CVVSmfhZqYTs62mLQFQ5SOEK7cjrqLDavAw28HsT-8KsWtXXoR-kVxxGzbrZ9xxngXWBHOrLWHllIxgl7EUORjzfOBHLeQo3BwKWc0Dje3UvvgfwGA47rl0ImPbNvPkH4j1NU6nSHMDz27-YCnzKO_mKI3YekCHhGJL5blZJXDz4deERHyTivbKduMVT6_HVuvm7HjeFM5jQC8RmKTjowlynRr0hojdQAXsYLybyywCAz00MTQigPi1Th0_oF2DBeCAIEvAWQ4Jvq6NFcP2xfK8dl-WLhyx3dS5mmh3xQBK_f2cWt-N9DcquHWOKjnD84qtIbd75BeBPHDsIImM5eusTXYxOPT7h6uycCTZVYst_9MB8T6Jb4bk62Ke25OttdzoQvags8viAK_i6m00)

c. With the pivot out of the way, scan left-to-right and then right-to-left for out-of-place items.

![](https://img.plantuml.biz/plantuml/svg/VP9BRi8m48RtFiKeoqeWeAMKY4PSWNA0Q4Y6OCMnKtlIXohkNazI9RIB_Wjx_8tdPNaV63rtZL5HBHOrLWIldIxgF3ZFiDkzKC5eAqDP1bzAGLI3BQ3tkMPgGeJmeoKyPr1sPUb6j18K2e-DgsYaz_r5PEwAUeGF0X6NWKUq5bHRR8qxJ_HHw2MsVNBCPigw4NxMdKN_ESAdle7M4zQ69hmLVDAsl8bVBWHwNJb3GxLhlogPDp6kG0DaMREca006E1nb-4QNCGj8x5g1eJFdCIzz948MIX9U_g1MlpcEjeBX2QDrLUfmJDFXV3URPTCBzuuXnFrofEbMAUkO80dlsFOzYP6lrB31l2y-dz_6_ElSI2DHUxAb_8fl)

[source](https://editor.plantuml.com/uml/VP9BRi8m48RtFiKeoqeWeAMKY4PSWNA0Q4Y6OCMnKtlIXohkNazI9RIB_Wjx_8tdPNaV63rtZL5HBHOrLWIldIxgF3ZFiDkzKC5eAqDP1bzAGLI3BQ3tkMPgGeJmeoKyPr1sPUb6j18K2e-DgsYaz_r5PEwAUeGF0X6NWKUq5bHRR8qxJ_HHw2MsVNBCPigw4NxMdKN_ESAdle7M4zQ69hmLVDAsl8bVBWHwNJb3GxLhlogPDp6kG0DaMREca006E1nb-4QNCGj8x5g1eJFdCIzz948MIX9U_g1MlpcEjeBX2QDrLUfmJDFXV3URPTCBzuuXnFrofEbMAUkO80dlsFOzYP6lrB31l2y-dz_6_ElSI2DHUxAb_8fl)

d. An item >=pivot was found to the left of an item <=pivot. They will be swapped.

![](https://img.plantuml.biz/plantuml/svg/XPBTRi8m38NlynHMBoU11WmO5Qju1SO3LAOD9MgQTAcx7qsy--9qQYdQX2zA_CK-nuxODOIEsaeB7pLc9HOItbgLbMbZ7S5s-oepGbDecIJmBGJugB06T2vL9Al6G_YD6RmaaBTvRdiqPzHa3YjRo9ukGY4IjLdPmoU6YBE6UhHaL1gijJqDTCNqxCS-MY8zgAwPdrHhq7try3aCK3k9fPO3tZ0-AfDVzSyU6JfLM2qxjqlu2jutqZP33TAG8YMR2B21_O6NhrJkLO1xbmAqF57gTULdnEHHiE3v1jNgtP8_2-YUq9ykGkmFSTpb3vD9ChnmkEXQxEWYZZT264iIeYP3qpa1sJ14cB3p9fio4QCCfY6TNikjxvUiHewXoXk6kk0OzlVzWOXHzfVS_7x9uFY1TV3WGxeGtGzCMM5wiyV_Tnj-QXyxQNB-t_y0)

[source](https://editor.plantuml.com/uml/XPBTRi8m38NlynHMBoU11WmO5Qju1SO3LAOD9MgQTAcx7qsy--9qQYdQX2zA_CK-nuxODOIEsaeB7pLc9HOItbgLbMbZ7S5s-oepGbDecIJmBGJugB06T2vL9Al6G_YD6RmaaBTvRdiqPzHa3YjRo9ukGY4IjLdPmoU6YBE6UhHaL1gijJqDTCNqxCS-MY8zgAwPdrHhq7try3aCK3k9fPO3tZ0-AfDVzSyU6JfLM2qxjqlu2jutqZP33TAG8YMR2B21_O6NhrJkLO1xbmAqF57gTULdnEHHiE3v1jNgtP8_2-YUq9ykGkmFSTpb3vD9ChnmkEXQxEWYZZT264iIeYP3qpa1sJ14cB3p9fio4QCCfY6TNikjxvUiHewXoXk6kk0OzlVzWOXHzfVS_7x9uFY1TV3WGxeGtGzCMM5wiyV_Tnj-QXyxQNB-t_y0)

e. In an attempt to find two more items out of place, the scans cross.
Where the left-to-right scan stopped is the leftmost item of the `>= pivot` subrange.
It will be swapped with the pivot.


![](https://img.plantuml.biz/plantuml/svg/TPBTJiCm38NlynHMBv4shS1-gBPghp3s09NNPbtKD2c9Yq1exqwSGZkGveie-PnpR4VPUq97VQj5Y0xB1ci9Rxqgcy9RHx3TligIqDHQvZby2G4XMkm0dIiKoTO723-HmYw7ggygEw97HhvqsDfQZlGfNaIYlcn6-CmGCVKqeYMZnc2dxNcYAwQNqFR94kd9TStyh7g3xdE4czX0voGsMaxuXV59cUf6douOEbLRBOTgrxWAdZVHjaGDqf0Y9Nq2wE5mvE5RLGKNOErIW9PdAeAl_4YOB0GRNlwXJhrR2di1mnE6tLM8mp7BXlF3R9PFBnmJWyJ-IMJPMWXZIK82sztW6XlJL7I25vZ7wlDRJNeti_fr6uhbEuXkDRlLTpIRkvbq8NYg47jfAlvYtm00)

[source](https://editor.plantuml.com/uml/TPBTJiCm38NlynHMBv4shS1-gBPghp3s09NNPbtKD2c9Yq1exqwSGZkGveie-PnpR4VPUq97VQj5Y0xB1ci9Rxqgcy9RHx3TligIqDHQvZby2G4XMkm0dIiKoTO723-HmYw7ggygEw97HhvqsDfQZlGfNaIYlcn6-CmGCVKqeYMZnc2dxNcYAwQNqFR94kd9TStyh7g3xdE4czX0voGsMaxuXV59cUf6douOEbLRBOTgrxWAdZVHjaGDqf0Y9Nq2wE5mvE5RLGKNOErIW9PdAeAl_4YOB0GRNlwXJhrR2di1mnE6tLM8mp7BXlF3R9PFBnmJWyJ-IMJPMWXZIK82sztW6XlJL7I25vZ7wlDRJNeti_fr6uhbEuXkDRlLTpIRkvbq8NYg47jfAlvYtm00)

f. The range has been partitioned.

#### Figure 13.4 Quick sort partitioning process.


Then we loop from left to right looking for an item that belongs in the right partition,
and right to left looking for an item that belongs in the left one,
and swap them (Figure 13.4c—d).
The looping stops when the left-to-right loop and the right-to-left one cross
—at the boundary  between the two partitions (Figure 13.4e).

The tricky part of this nested loop is making sure that the inner loops always advance by at least one step.
It would have been more straightforward to start the outer loop with `left_index` at `leftmost+1` and `right_index at rightmost—2`,
and leave the **from** parts of the inner loops empty.
But suppose we were to hit a situation where `items.item(left_index).is_equal(pivot)` and 
`items.item(right_index).is_equal(pivot )`
—both inner loops would exit immediately without changing `left_index` or `right_index`,
and the outer loop would become infinite!

After the outer loop terminates,
we place the pivot item at the boundary by swapping it with the leftmost item in the right subrange,
which is exactly at position left_index,
where the left-to-right loop failed its until condition and terminated (Figure 13.4f).
Now all that remains is to recursively quick sort the left subrange
`(([leftmost, ...,left_index—1])` and the righ `([left_index+1,...,rightmost))`.

### 13.2.2 So What Makes It Quick?

$O(N log N)$ is the best time complexity that a general-purpose object sorting algorithm can have,
but the big $O$ notation says nothing about the discarded constant.
Quick sort’s advantage is that it can be best tweaked to increase the speed of the partitioning and thus decrease that constant.
This tweaking requires more precise analysis techniques than we use in this book,
backed up by measured experiments.

A common optimization in quick sort is to avoid it altogether when the length of the range is small.
As we saw back in Figure 6.9,
the constants involved in algorithms of different big $O$ complexities may make a difference up to a certain $N$,
but for large enough $N$ the lower big $O$ complexity algorithm will win.
The flip side of that coin is that for small enough $N$,
an $O(N^2)$ algorithm may work faster than an $O(N \log N)$ algorithm.
That is what tends to happen with quick sort and insertion sort,
so when the range gets to be small enough,
`insertion_sort` is called instead of `quick_sort`.
The exact break-even range length depends on exactly how both algorithms are coded,
and how a specific compiler optimizes that code.
According to Robert Sedgewick [9,p.124],
lengths of 5 to 25 tend to be good switchover points.

#### 13.2.3 The Singly Linked Version ...

... is left as an exercise to you.
The basic algorithm is the same,
but you will need a different partitioning method,
since moving right-to-left is the kiss of death in singly linked lists.

## 13.3 Space Complexity

Time complexity tells us how much time an algorithm needs as a function of $N$.
But there is another consideration:
How much space does it use (also in terms of $N$)?
Let us clarify one thing:
We only care about maximum additional memory needed to perform the algorithm,
just as with time complexity we only cared about the time the algorithm added to the whole program’s execution.
The space occupied by the object structure itself does not count.
To count space usage, we need to take into account these details:

1. Every time a routine is called,
a constant amount of space is used.
A fixed amount of space is needed for:
    a. The return address 
        (so that execution can resume in the right place ‘within the calling routine);
    b. The passed parameters (if any); and
    c. The local entities.

All this space is freed up when the routine exits.
This is a *big* distinction from time complexity measurement:
Space can be returned,
but once time is used up, it is gone.

2. Every time an object is created
(with the !! operator),
enough space to hold all of its attributes is consumed.
That space is restored when the object is garbage-collected.

3. Objects can be instructed to grab more space.
Operations `make` and `resize` in `ARRAY`,
`make_capacity` and `resize` in `LIST_ARRAY`,
`insert_on_left` and `insert_on_right` in `LIST_LINKED`,
`push` in `STACK_LINKED`,
and `enqueue` in `QUEUE_LINKED`
—all of these pick up space.

4. Objects can be instructed to let go of space.
(They cannot actually deallocate it:
only the garbage collector can do that.)
The routines listed in the previous item have counterparts that release space.

Thus, there are four possible reasons for a routine to have a space complexity other than $O(1)$:

1. It repeatedly creates objects and puts them into an object structure
(so that they do not become disconnected from the root object and garbagecollected).
2. It creates an object structure of an initial size proportional to $N$
(for example, an ARRAY object of length `length` or `length // 2`).
3. It forces an object structure to grow.
4. It is recursive.
Item 1 in the previous list starts with the words “every time a routine is called,”
and routines are called many times during recursion.

Looking over the insertion sort, bubble sort, and selection sort algorithms,
it should be clear that none of the preceding four reasons holds,
so those three algorithms have a space complexity of $O(1)$.

Let us skip merge sort for the moment and look at quick sort.
It is recursive, so space is added at each level of the recursion.
It does not create objects or utilize object structures,
so reasons 1—3 do not hold,
therefore the amount of space added at each level of the recursion is constant.
The maximum number of levels we can encounter with luckily chosen pivots is $O(\log N)$,
times $O(1)$ space used at each level,
which gives us a space complexity of $O(\log N)$.
With unluckily chosen pivots, we get a worst case space complexity of $O(N)$.

Both of our implementations of merge sort are also recursive.
The singly linked one avoids reasons 1—3 too,
and its recursion consistently goes down $O(\log N)$ levels,
so we get consistent $O(\log N)$ space complexity.
Our array-based implementation of merge sort is more interesting.
At level 1 of the recursion, we merge $N$ items using an additional array of $N$,
after two sets of $\frac{1}{2} N$ items are sorted.
That additional array is allocated inside routine `merge`,
which `merge_sort` calls after both recursive `merge_sort` calls return.
Thus, by the time the array of size $N$ is created,
both arrays of size $\frac{1}{2} N$ have been released to the garbage collector.
Those arrays do not accumulate during the recursion.

At the deepest level of recursion,
the parameters and local entities accumulate $O(\log N)$ of space,
but at the time the array is very short, only-2 items.
At the shallowest level of recursion,
the array is $O(N)$ in length,
but there is only $O(1)$ local entities and parameters accumulated.
Since the $O(\log N)$ consumption and the $O(N)$ consumption cannot occur at the same time,
we just take the maximum of the two: $O(N)$.

## 13.4 Choosing the Best Sorting Algorithm for a Given Use

There is no single “best” sorting algorithm
—if there was, we would not bother discussing five of them,
and there are others from which to choose.

In general, for large $N$ and objects about which we know nothing,
an $O(N log N)$ algorithm should be picked over $O(N^2)$ algorithms.
Quick sort tends to do quite well on large lists.
When it divides the list down to small lists,
it should use a lower cost routine, such as insertion sort,
to finish that part of the job.

Another interesting question is what happens if the items are already mostly
(or even completely) sorted before the sorting algorithm is invoked.

Consider, for instance, the array version of merge sort.
At each level of recursion, the merge involves moving the entire range into a temporary array and
then back.
It does not matter at all if the whole range is already sorted
(i.e., the rightmost item of the left subrange is “<=” than the leftmost item of the right subrange).

The singly linked version of merge sort is similar,
but it only goes through the left subrange and then attaches the right subrange in one step.

The quick sort version we studied will work very well on mostly sorted lists,
since the median of the leftmost, middle, 
and rightmost items will tend to be the median of the whole list;
it will be *the* median of the whole list if the list is fully sorted.
(There are versions of the algorithm that always simply take the leftmost item as the limit.
These versions will display the miserable $O(N^2)$ time and space complexity if the range is already sorted.)

Insertion sort, in its right-to-left scanning form,
does wonderfully on fully sorted lists.
The inner loop always quits right away,
so the whole sort is done in $O(N)$ time.
Suppose that only one item is out of place.
Let us say that the least item is all the way at the right end of the list,
while the rest of the list is sorted.
Then the outer loop zips through the whole list in $O(N)$ time,
and then finally hits the out-of-place item.
The last time through the outer loop,
the inner loop will have something to do:
Move the least item all the way to the left,
another $O(N)$ operation.
Thus, the whole thing was done in $O(N)$ time.

Suppose, on the other hand,
that the greatest item was all the way at the left end of the list,
while the rest of the list was sorted.
As far as the outer loop is concerned,
that greatest item is the initial sorted section.
The item in position 2 then has to be inserted into the sorted region—but it only has one step left to move.
Then the item in position 3 has to be inserted,
but it also only has one step left to move,
and so on.
When all is said and done,
the array is sorted in $O(N)$ time.

These, of course, are extreme cases of “mostly sorted.”
But the fewer items out of place,
the closer to O(N) insertion sort gets.

Selection sort ends up with its predictable $O(N^2)$ time complexity no matter how sorted it is,
because the inner loop always has to go all the way to the right end.

Bubble sort, though, can be easily made to recognize sorted lists:
If no swap was performed during an inner loop,
then the whole list must be sorted.
It is easy to add an if statement that detects that situation and signals the outer loop to bail out.
If your application frequently deals with mostly sorted lists,
this may be a good solution;
otherwise adding the if would just slow down your sort for no good reason.
So for short lists that may or may not be mostly sorted,
you may want to stick to insertion sort.

# Summary
The two sorting algorithms discussed in this chapter have the average performance of $O(N \log N)$.
Merge sort is $O(N \log N)$ in the worst case as well,
but quick sort’s worst case behavior is $O(N^2)$.

Merge sort works by recursively sorting two halves of the list,
and then merging them into one sorted list.

Quick sort works by partitioning the list into two parts
—with items less than or equal to a selected pivot item in the left part,
and those greater than or equal to the pivot in the right—
and then sorting the two parts recursively.

# Exercises

1. Complete class MERGESORTABLE_LIST_ARRAY.

2. In Listing 13.3,
a new array is created every time so that merged object references can be copied into it and then back into items.
Since Eiffel guarantees that everything new is initialized
(in case of object references, to Void),
making an array is an $O(N)$ operation.
Modify class MERGESORTABLE_LIST_ARRAY so that the spare array is created only once during the entire run of sort.

3. Complete class MERGESORTABLE_LIST_SINGLY_LINKED.

4. Draw the execution chart for the merge_sort routine in class MERGESORTABLE_LIST_SINGLY_LINKED
and show that its time complexity is $O(N \log N)$.

5. Routine `merge` in Listing 13.4 rearranges the node chain within the list.
Another way of sorting the list is by leaving the node sequence unchanged,
but moving their item references around.
Write a version of MERGESORTABLE_LIST_SINGLY_LINKED that works that way.

6. Complete class QUICKSORTABLE_LIST_ARRAY.

7. Acommon speedup for quick sort is to call insertion sort for subranges that are small enough.
    a. Add this optimization to class QUICKSORTABLE_LIST_ARRAY.
        Consider ranges of length 20 to be small enough.
        (You will need to modify SORTABLE_LIST_TESTER to use a longer list.)

    b. Modify the LIST_ARRAY class hierarchy so that the insertion sort code 
        is not duplicated between INSERTIONSORTABLE_LIST_ ARRAY and QUICKSORTABLE_LIST_ARRAY.
8. Devise a quick sort partitioning algorithm that works on singly linked lists in $O(N)$ time.
Implement it in class QUICKSORTABLE_LIST_SINGLY_LINKED.
