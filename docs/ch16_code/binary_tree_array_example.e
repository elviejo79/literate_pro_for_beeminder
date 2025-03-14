deferred class BINARY_TREE_ARRAY_EXAMPLE[ITEM -> {COMPARABLE, ANY} create make end] inherit
    BINARY_TREE_EXAMPLE[ITEM]

feature {BINARY_TREE_ARRAY_EXAMPLE}
    items: ARRAY[ITEM]
    root_index: INTEGER

feature {BINARY_TREE_ARRAY_EXAMPLE} -- Creation and initialization
    -- This is really a creation routine, but it is illegal to declare
    -- it as such in a deferred class. Fully implemented subclasses
    -- need to declare "creation make_subtree," and implement left
    -- and right that use it as a creation routine.
    make_subtree (the_items: like items; the_root_index: like root_index)
        -- Make this tree share the array the_items and start at the_root_index.
    do
        items := the_items
        root_index := the_root_index
    end -- make_subtree

feature -- Accessing the components
    root_item: ITEM
        -- The item at the root.
    do
        Result := items.item(root_index)
    end -- root_item

    is_empty: BOOLEAN
        -- Is this tree empty?
    do
        Result := root_index > items.count or else items.item(root_index) = Void
    end -- is_empty

    is_full: BOOLEAN
        -- Cannot predict jumping out of the array,
        -- so will have to resize as necessary.
    do
        Result := False
    end -- is_full

    wipe_out
        -- Make this tree empty.
    local
        void_item: ITEM
        subtree: like Current
    do
    	create void_item.make

        subtree := left
        if not subtree.is_empty then
            subtree.wipe_out
        end

        subtree := right
        if not subtree.is_empty then
            subtree.wipe_out
        end

        items.put(void_item, root_index)
    end -- wipe_out

feature -- Cloning and comparing
    copy (other: like Current)
        -- Copy other onto this tree.
    do
        if root_index = 1 then
            -- Chances are that we were called from clone, which had aliased
            -- our items to other.items. Remake that array, just in case.
            -- items.make_empty(1, other.items.count)
        	items.make_empty
        end

        if not is_empty then
            wipe_out
        end

        if not other.is_empty then
            -- Track the same item at the root.
            items.put(other.root_item, root_index)

            -- Clone other's subtrees.
            left.copy(other.left)
            right.copy(other.right)
        end
    end -- copy

invariant
    have_array: items /= Void
    empty_if_no_item: is_empty = (root_item = Void)
    root_index_positive: root_index > 0

end -- class BINARY_TREE_ARRAY
