note

	description:

		"Useful date/time related features"

	library: "John Resig Shell library"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2015, Berend de Boer"
	license: "MIT License (see LICENSE)"


class

	JRS_DATE_TIME_ROUTINES


feature -- Status

	is_dateTime (s: STRING): BOOLEAN
			-- Is `s' a dateTime?
			-- Should be of format "[-]yyyy-mm-ddThh:mm:ss(.sss)?[zzzzzz]" as per
			-- http://www.w3.org/TR/xmlschema-2/#dateTime
			-- TODO: timezone support
		local
			year,
			month,
			day: INTEGER
			hour,
			minute,
			second: INTEGER
			calendar: KL_GREGORIAN_CALENDAR
			tz_hour: INTEGER
		do
			if s /= Void then
				create calendar
				xmlschema_dateTime_format.match (s)
				Result := xmlschema_dateTime_format.has_matched
				if Result then
					year := xmlschema_dateTime_format.captured_substring (1).to_integer
					month := xmlschema_dateTime_format.captured_substring (2).to_integer
					day := xmlschema_dateTime_format.captured_substring (3).to_integer
					hour := xmlschema_dateTime_format.captured_substring (4).to_integer
					minute := xmlschema_dateTime_format.captured_substring (5).to_integer
					second := xmlschema_dateTime_format.captured_substring (6).to_integer
					if xmlschema_dateTime_format.match_count > 10 then
						tz_hour := xmlschema_dateTime_format.captured_substring (9).to_integer
					end
					Result :=
						month >= calendar.January and then month <= calendar.December and then
						day >= 1 and then day <= calendar.days_in_month (month, year) and then
						hour >= 0 and then hour <= 23 and then
						minute >= 0 and then minute <= 59 and then
						second >= 0 and then second <= 59 and then
						tz_hour >= -14 and then tz_hour <= 14
				end
			end
		end


feature -- Conversion

	as_date_time (s: STRING): DT_DATE_TIME
			-- `s' in XML Schema format as date per current time zone;
			-- Example `s': 2015-12-08T20:51:06
		require
			is_dateTime: is_dateTime (s)
		local
			ms: INTEGER
			t: STRING
			tz: STRING
			tz_seconds: INTEGER
		do
			xmlschema_dateTime_format.match (s)
			if xmlschema_dateTime_format.match_count > 8 then
				t := xmlschema_dateTime_format.captured_substring (8)
				if not t.is_empty then
					ms := t.to_integer
				end
			end
			create Result.make_precise (xmlschema_dateTime_format.captured_substring (1).to_integer, xmlschema_dateTime_format.captured_substring (2).to_integer, xmlschema_dateTime_format.captured_substring (3).to_integer, xmlschema_dateTime_format.captured_substring (4).to_integer, xmlschema_dateTime_format.captured_substring (5).to_integer, xmlschema_dateTime_format.captured_substring (6).to_integer, ms)
			if xmlschema_dateTime_format.match_count > 9 then
				tz := xmlschema_dateTime_format.captured_substring (9)
				if tz.count = 1 then
					tz_seconds := 0
				else
					tz_seconds := xmlschema_dateTime_format.captured_substring (10).to_integer * 3600 + xmlschema_dateTime_format.captured_substring (11).to_integer * 60
				end
				Result.add_seconds (tz_seconds)
			end
		ensure
			not_void: Result /= Void
		end


feature {NONE} -- Date internals

	date_format: STRING = "(-?[0-9]{4})-([0-1][0-9])-([0-3][0-9])"
	time_format: STRING = "([0-2][0-9]):([0-5][0-9]):([0-5][0-9])(\.([0-9]{1,3})[0-9]*)?"
	optional_time_zone_format: STRING = "(Z|([+\-][0-1][0-9]):([0-5][0-9]))?"

	xmlschema_dateTime_format: RX_PCRE_REGULAR_EXPRESSION
		once
			create Result.make
			Result.compile (once "^" + date_format + once "T" + time_format + optional_time_zone_format + once "$")
		ensure
			compiled: Result.is_compiled
		end


end
