note
	description: "Summary description for {MY_LIST_ARRAY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class MY_LIST_ARRAY [ITEM]

inherit
	MY_LIST [ITEM]
create
	make,
	make_capacity

feature {LIST_ARRAY}
	--Visible only to similar lists
	items: ARRAY [ITEM]; --The array tracking the items.

	cursor: INTEGER; --Index within items of the item under the cursor.

	make_capacity (initial_capacity: INTEGER)

		require
			initial_capacity >= 0;

		do
			capacity := initial_capacity;

			create items.make (1, initial_capacity);
				--First item is always at index 1.
			length := 0;
				--Start out empty.
			cursor := 0;
			--Start out off-left.
		end;

	resize (new_capacity: INTEGER)
			--Resizes the list to new_capacity. Could be very expensive.
		require
			new_capacity >= 0;

		do
			capacity := new_capacity;

			items.resize (1, new_capacity); --First item is always at index 1.
				--May have to truncate this list to fit the new array.
			if cursor > capacity + 1 then
				cursor := capacity + 1;
			end;

			if length > capacity then
				length := capacity;
			end;

		end;

feature --Sizing
	capacity: INTEGER; --Current capacity.
	length: INTEGER; --The number of items currently in this list.
	is_empty: BOOLEAN --Is this list empty?
		do
			Result := length = 0;
		end;

	is_full: BOOLEAN -- Is there is no room in this list for one more item?
		do
			Result := length = capacity;
		end;

feature -- Moving through the list
	move_left --Move the cursor one step to the left.
		do
			cursor := cursor - 1;

		end;

	move_right --Move the cursor one step to the right.
		do
			cursor := cursor + 1;

		end;

	move_off_left --Move the cursor to the off-left position.
		do
			cursor := 0;

		end;

	move_off_right --Move the cursor to the off-right position.
		do
			cursor := length + 1;
		end;

	is_off_left: BOOLEAN --Is the cursor off-left?
		do
			Result := cursor = 0;
		end;

	is_off_right: BOOLEAN --Is the cursor off-right?
		do
			Result := cursor = length + 1;
		end;

invariant
	capacity_not_negative:

		0 <= capacity;

	length_in_range:
		length <= capacity;
	cursor_in_range:
		0 <= cursor and cursor <= length + 1;
	good_array:
		items /= Void and then
		items.count = capacity and items.lower = 1;

end
