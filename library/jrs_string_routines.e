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

	valid_format (s: STRING; a_parameters: TUPLE): BOOLEAN
		do
			-- no checks done yet
			Result := true
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
			-- `a_parameters'; if `an_escape_strings' then any string
			-- replacements are escaped.
		require
			parameters_valid: valid_format (s, a_parameters)
		local
			convert_to_utf8: BOOLEAN
			i: INTEGER
			parameter: INTEGER
			my_s: detachable STRING
			my_b: BOOLEAN
			a: detachable ANY
			c: INTEGER
		do
			if s /= Void then
				convert_to_utf8 := ANY_.same_types (s, once "")
				if convert_to_utf8 then
					create {UC_STRING} Result.make_from_string (s)
				else
					Result := s.twin
				end
				from
					i := 1
					parameter := 1
				until
					i >= Result.count
				loop
					if Result.item (i) = '$' then
						inspect Result.item (i + 1)
						when 's' then
							c := Result.count
							my_s ?= a_parameters.reference_item (parameter)
							if my_s = Void then
								a := a_parameters.reference_item (parameter)
								if a = Void then
									Result.replace_substring (once "", i, i + 1)
								else
									Result.replace_substring (a_parameters.reference_item (parameter).out, i, i + 1)
								end
							else
								if an_escape_strings then
									my_s := STRING_.as_string (my_s)
									my_s.replace_substring_all (once "'", once "''")
								end
								Result.replace_substring (my_s, i, i + 1)
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
						else
							-- ignore
						end
					end
					i := i + 1
				variant
					Result.count - i + 1
				end
				if convert_to_utf8 then
					Result := STRING_.as_string (Result)
				end
			end
		ensure
			only_void_if: (s = Void) = (Result = Void)
		end


feature -- String manipulation

	split (s: STRING; on: CHARACTER): DS_LIST [STRING]
			-- `s' split into elements divided by `on' if `s' is not Void;
			-- If `on' does not appear in `s', an array with one element
			-- containing `s' will be returned;
			-- if `s' is Void an empty array will be returned
		local
			p, start: INTEGER
			tmp_string: STRING
		do
			create {DS_LINKED_LIST [STRING]} Result.make
			if s /= Void and then not s.is_empty then
				from
					start := 1
					p := s.index_of (on, start)
				until
					p = 0
				loop
					tmp_string := s.substring (start, p-1)
					Result.put_last (tmp_string)
					start := p + 1
					p := s.index_of (on, start)
				variant
					(s.count + 1) - start
				end

				-- Last element or entire string
				if start <= s.count then
					tmp_string := s.substring (start, s.count)
					Result.put_last (tmp_string)
				end
			end
		ensure
			result_not_void: Result /= Void
			empty_on_void: s = Void implies Result.is_empty
		end

	trim (s: STRING): STRING
			-- `s' with leading and trailing white space removed
		do
			if s /= Void then
				Result := s.twin
				Result.left_adjust
				Result.right_adjust
			end
		ensure
			void_if_void: (s = Void) = (Result = Void)
		end


feature -- Regular expressions

	is_valid_regex (a_regex: STRING): BOOLEAN
			-- Is `a_regex' a valid regular expression?
		local
			rx: RX_PCRE_REGULAR_EXPRESSION
		do
			if a_regex /= Void and then not a_regex.is_empty then
				create rx.make
				rx.compile (a_regex)
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


end
