note

	description:

		"State for record feature"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2012, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_RECORD_STATE


feature -- Access

	field_separator: CHARACTER
		do
			Result := internal_field_separator.item
		end


feature -- Change

	set_field_separator (c: CHARACTER)
			-- Change the field separator
			-- TODO: changing this does not seem to work
		do
			internal_field_separator.set_item (c)
		ensure
			field_separator_set: field_separator = c
		end


feature {NONE} -- Implementation

	internal_field_separator: attached CHARACTER_REF
			-- WARNING: once does not work (anymore?)
		once
			create Result
			Result.set_item (',')
		ensure
			not_void: Result /= Void
		end

end
