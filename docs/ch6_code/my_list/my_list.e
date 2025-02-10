note
	description: "Summary description for {MY_LIST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class MY_LIST [ITEM]

inherit
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
			off_left: is_off_left;
		end;

feature -- Moving through the list
	move_left is
			--Move the cursor one step to the left.
		require
			not_off_left: not is_off_left;
		deferred
		ensure
			not_off_right: not is_off_right; --The cursor is one step to the left of where it was.
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
			off_left: is_off_left;
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
	insert_on_left (new_item: ITEM)is
--Insert new_item to the left of the cursor.
		require
			not_full: not is_full;
			not_off_left: not is_off_left;
		deferred
		ensure
			one_more_item: length = old length + 1;
---The cursor is on the same item as it was before.
		end;
--insert_on_left
	insert_on_right (new_item: ITEM)is
--Insert new_item to the right of the cursor.
		require
			not_full:
				not is_full;
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
	wipe_out is
--Make this list empty and off-left.
		deferred
		ensure
			empty:
				is_empty;

			off_left: is_off_left;
		end;
--wipe_out
	replace
			(new_item: ITEM)is
--Replaces the item under the cursor with new_item.
		require
			not_off_left: not is_off_left;
			not_off_right: not is_off_right;

		deferred
		ensure
			item_replaced: item = new_item;
			length_unchanged: length = old length;
		end;
---replace
	item: ITEM is
--The item under the cursor.
		deferred
		end;
--item
feature ---Sizing
	is_empty: BOOLEAN is
--Is this list empty?
		deferred
		end;
--is_empty
	is_full: BOOLEAN is
--Is there no room in this list for one more item?
		deferred
		end;
--is_full
	length:
			INTEGER is
--The number of items currently in this list.
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
--Is this list s cursor the same distance

--from off-left as other s cursor?
		deferred
		end;
--cursor_matches
	copy
			(other:
			like Current)is
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
--"< <1st item>.out ... <last item>.out >".
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
