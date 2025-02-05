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
