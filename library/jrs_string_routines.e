note

	description:

		"Useful string features"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2010, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_STRING_ROUTINES


inherit

	ANY

	KL_IMPORTED_ANY_ROUTINES
		export
			{NONE} all
		end

	KL_IMPORTED_STRING_ROUTINES
		export
			{NONE} all
		end


feature -- Environment variables

	is_env_character (c: CHARACTER): BOOLEAN
			-- return True if c can be used in an environment variable
			-- used by our expansion routine.
		do
			Result :=
				(c >= 'A' and c <= 'Z') or else
				(c >= 'a' and c <= 'z') or else
				(c >= '0' and c <= '9') or else
				(c = '_')
		end

	env (a_name: STRING): STRING
			-- Value of environment variable `a_name'
		require
			valid_name: a_name /= Void and then not a_name.is_empty
		local
			e: STDC_ENV_VAR
		do
			create e.make (a_name)
			Result := e.value
		ensure
			not_void: Result /= Void
		end

	expand_env_vars (s: STRING): STRING
			-- `s' with environment variables in the form of ${NAME} or
			-- $(NAME) or %NAME% expanded
		require
			s_not_void: s /= Void
		local
			i, j: INTEGER
			start_name, stop_name: INTEGER
			c: CHARACTER
			env_name: STRING
		do
			Result := STRING_.new_empty_string (s, s.count * 2)
			from
				i := 1
			until
				i > s.count
			loop
				c := s.item (i)
				inspect c
				when '~' then
					if (i = 1) and then (s.count > 1) and then
						not s.item (i+1).is_digit then
						Result.append_string (home_directory)
					else
						Result.append_character (c)
					end
				when '\' then
					Result.append_character ('/')
				when '$' then
					if (i < s.count) then
						inspect s.item (i+1)
						when '{' then
							start_name := i+2
							j := s.index_of ('}', start_name)
							stop_name := j-1
							i := j
						when '(' then
							start_name := i+2
							j := s.index_of (')', start_name)
							stop_name := j-1
							i := j
						else
							-- Leave, could be replacement like $s
							Result.append_character (c)
							start_name := 0
							stop_name := 0
						end
						if start_name <= stop_name - 1 then
							env_name := s.substring (start_name, stop_name)
							Result.append_string (env (env_name))
						end
					else
						-- if last character is a $, do not consider it a
						-- special character
						Result.append_character (c)
					end
				when '%%' then
					start_name := i+1
					j := s.index_of ('%%', start_name)
					stop_name := j-1
					i := j
					env_name := s.substring (start_name, stop_name)
					Result.append_string (env (env_name))
				else
					Result.append_character (c)
				end
				i := i + 1
			variant
				s.count - i + 1
			end
		end

	home_directory: STRING
			-- Home directory, according to environment variable "HOME"
		once
			Result := env ("HOME")
		ensure
			home_directory_not_void: Result /= Void
		end


feature -- String formatting

	valid_format (s: STRING; a_parameters: detachable TUPLE): BOOLEAN
		local
			format_string_count: INTEGER
		do
			if s /= Void then
				-- no checks done yet
				format_string_check.match (s)
				if format_string_check.has_matched then
					from
					until
						not format_string_check.has_matched
					loop
						if format_string_check.captured_substring (1).item (1) /= '$' then
							format_string_count := format_string_count + 1
						end
						format_string_check.next_match
					end
					if a_parameters /= Void then
						Result := a_parameters.count = format_string_count
					else
						Result := format_string_count = 0
					end
				else
					Result := True -- No match means no format strings or non recognised/handled
				end
				format_string_check.wipe_out
			else
				Result := True
			end
		ensure
			void_is_ok: s = Void and then (a_parameters = Void or else a_parameters.count = 0) implies Result
		end

	format (s: STRING; a_parameters: TUPLE): STRING
			-- `s' with replacement indicators replaced by values from
			-- `a_parameters'
		require
			parameters_valid: valid_format (s, a_parameters)
		do
			Result := do_format (s, a_parameters, false)
		ensure
			only_void_if: (s = Void) = (Result = Void)
		end

	format_sql (s: STRING; a_parameters: TUPLE): STRING
			-- `s' with replacement indicators replaced by values from
			-- `a_parameters'; in case the replacement indicator is $s,
			-- any single quote in the replacement value is escaped.
		require
			parameters_valid: valid_format (s, a_parameters)
		do
			Result := do_format (s, a_parameters, true)
		ensure
			only_void_if: (s = Void) = (Result = Void)
		end

	do_format (s: STRING; a_parameters: TUPLE; an_escape_strings: BOOLEAN): STRING
			-- `s' with replacement indicators replaced by values from
			-- `a_parameters';
			-- if `an_escape_strings' then any string replacements are
			-- escaped in an attempt to make them safe to be used for
			-- dynamically generated sql.
		require
			parameters_valid: valid_format (s, a_parameters)
		local
			-- convert_to_utf8: BOOLEAN
			i: INTEGER
			parameter: INTEGER
			my_ss: STRING
			my_b: BOOLEAN
			a: detachable ANY
			c: INTEGER
		do
			if a_parameters = Void or else a_parameters.count = 0 then
				Result := s
			elseif s /= Void then
				-- I used to have this, but not sure this is useful or
				-- safe as we have to assume utf8 in STRING. That's
				-- perhaps limiting. Much better to have charset=utf8 in
				-- odbc.ini and not assume any charset if we can avoid that.
				-- convert_to_utf8 := ANY_.same_types (s, once "")
				-- if convert_to_utf8 then
				-- 	create {UC_STRING} Result.make_from_utf8 (s)
				-- else
				-- 	Result := s.twin
				-- end
				Result := s.twin
				from
					i := 1
					parameter := 1
				until
					i >= Result.count
				loop
					if Result.item (i) = '$' then
						inspect Result.item (i + 1)
						when 's', 't' then
							c := Result.count
							if attached {STRING} a_parameters.reference_item (parameter) as my_s then
								if an_escape_strings and then Result.item (i + 1) /= 't' then
									my_ss := aliased_quote_sql_string (my_s)
								else
									my_ss := my_s
								end
								Result.replace_substring (my_ss, i, i + 1)
							else
								a := a_parameters.reference_item (parameter)
								if a = Void then
									Result.replace_substring (once "", i, i + 1)
								else
									Result.replace_substring (a_parameters.reference_item (parameter).out, i, i + 1)
								end
							end
							i := i + (Result.count - c + 1)
							parameter := parameter + 1
						when 'i' then
							if a_parameters.is_integer_32_item (parameter)  then
								c := Result.count
								Result.replace_substring (a_parameters.integer_item (parameter).out, i, i + 1)
								i := i + (Result.count - c + 1)
							else
								Result.replace_substring (once "0", i, i + 1)
								i := i + 1
							end
							parameter := parameter + 1
						when 'b' then
							c := Result.count
							if a_parameters.is_boolean_item (parameter) then
								my_b := a_parameters.boolean_item (parameter)
								Result.replace_substring (my_b.out.as_lower, i, i + 1)
								i := i + (Result.count - c + 1)
							else
								Result.replace_substring (once "", i, i + 1)
							end
							parameter := parameter + 1
						when '$' then
							-- Skip quoted format character
							i := i + 1
						else
							-- ignore all else
						end
					end
					i := i + 1
				variant
					Result.count - i + 1
				end
				-- if convert_to_utf8 then
				-- 	Result := STRING_.as_string (Result)
				-- end
			end
		ensure
			only_void_if: (s = Void) = (Result = Void)
		end


feature -- String manipulation

	split (s: READABLE_STRING_GENERAL; on: CHARACTER): DS_LIST [READABLE_STRING_GENERAL]
			-- `s' split into elements divided by `on' if `s' is not Void;
			-- If `on' does not appear in `s', an array with one element
			-- containing `s' will be returned;
			-- The behaviour differs slightly if `on' is white space or
			-- not: if it is white space, consecutive occurences of `on'
			-- are counted as one, and beginning and ending white space
			-- is removed, before splitting.
			-- if `s' is Void an empty array will be returned
		local
			p, start: INTEGER
			t: like s
			tmp_string: like s
			white_space: BOOLEAN
		do
			create {DS_LINKED_LIST [READABLE_STRING_GENERAL]} Result.make
			if s /= Void and then not s.is_empty then
				white_space := is_white_space (on)
				if white_space then
					t := trim (s)
				else
					t := s
				end
				from
					start := 1
					p := t.index_of_code (on.natural_32_code, start)
				until
					p = 0
				loop
					tmp_string := t.substring (start, p-1)
					Result.put_last (tmp_string)
					start := p + 1
					if white_space then
						from
						until
							t.code (start) /= on.natural_32_code
						loop
							start:= start +1
						end
					end
					p := t.index_of_code (on.natural_32_code, start)
				variant
					(t.count + 1) - start
				end

				-- Last element or entire string
				if start <= t.count then
					tmp_string := t.substring (start, s.count)
					Result.put_last (tmp_string)
				end
			end
		ensure
			result_not_void: Result /= Void
			empty_on_void: s = Void implies Result.is_empty
		end

	trim (s: READABLE_STRING_GENERAL): STRING
			-- `s' with leading and trailing white space removed
		do
			if s /= Void then
				create Result.make_from_string (s.as_string_8)
				Result.left_adjust
				Result.right_adjust
			end
		ensure
			void_if_void: (s = Void) = (Result = Void)
		end


feature -- Regular expressions

	is_valid_regex (a_regex: READABLE_STRING_GENERAL): BOOLEAN
			-- Is `a_regex' a valid regular expression?
		local
			rx: RX_PCRE_REGULAR_EXPRESSION
		do
			if a_regex /= Void and then not a_regex.is_empty then
				create rx.make
				rx.compile (a_regex.out)
				Result := rx.is_compiled
			end
		end

	preg_replace (s, re, replacement: STRING): STRING
		require
			s_not_empty: s /= Void and then not s.is_empty
			valid_regular_expression: is_valid_regex (re)
			replacement_not_empty: replacement /= Void and then not replacement.is_empty
		local
			rx: RX_PCRE_REGULAR_EXPRESSION
			t: STRING
		do
			Result := s
			create rx.make
			rx.compile (re)
			rx.match (s)
			if rx.has_matched then
				t := STRING_.new_empty_string (s, replacement.count)
				t.append_string (replacement)
				Result := rx.replace (t)
			end
		end

	aliased_quote_sql_string (s: STRING): STRING
			-- Quote any quotable characters in `s' so it is safe for
			-- inserting into dynamically created SQL
		require
			s_not_void: s /= Void
		do
			Result := s.twin
			Result.replace_substring_all (once "'", once "''")
			Result.replace_substring_all (once "\", once "\\")
		end

	quote_format_strings (s: attached STRING): STRING
			-- If `s' has any '$' characters, quote them
		require
			s_not_void: s /= Void
		local
			i: INTEGER
		do
			Result := s
			from
				i := 1
			until
				i > Result.count
			loop
				if Result.item (i) = '$' then
					if Result = s then
						Result := s.twin
					end
					Result.insert_character ('$', i + 1)
					i := i + 2
				else
					i := i + 1
				end
			variant
				Result.count - i + 1
			end
		ensure
			not_void: Result /= Void
			parameters_valid: valid_format (Result, Void)
		end


feature {NONE} -- Implementation

	is_white_space (c: CHARACTER): BOOLEAN
		do
			Result := c = ' '
		end

	format_string_check: RX_PCRE_REGULAR_EXPRESSION
			-- Regular expressions to validate format strings
		once
			create Result.make
			Result.compile ("\$([stib\$])")
		ensure
			not_void: Result /= Void
			compiled: Result.is_compiled
		end


end
