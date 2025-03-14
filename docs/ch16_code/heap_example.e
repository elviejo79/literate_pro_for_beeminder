deferred class HEAP_EXAMPLE [ITEM -> COMPARABLE]

inherit
	BINARY_TREE_EXAMPLE [ITEM]
	redefine
		is_equal
	end
feature -- Adding, removing, and finding items
	insert (new_item: ITEM)
			-- Insert new_item into this heap.
		require
			not_void: new_item /= Void
			not_full: not is_full
		deferred
		ensure
			size_after_insert: size = old size + 1
		end -- insert

	delete
			-- Delete the root item.
		require
			not_empty: not is_empty
		deferred
		ensure
			size_after_delete: size = old size - 1
		end -- delete
feature -- Sizing
	is_full: BOOLEAN
			-- Is there no room in this heap for another item?
		deferred
		end -- is_full

end -- class HEAP
