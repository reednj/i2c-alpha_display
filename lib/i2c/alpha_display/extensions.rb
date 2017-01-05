class Time
	def to_alpha
		strftime '%H.%M'
	end
end

class Fixnum
	def to_alpha
		return to_s if self < 1000
		return self.to_f.to_alpha
	end
end

class Float
	def to_alpha(len = 4)
		v = self.to_f
		
		prefixes = ['', 'k', 'M', 'G', 'T']
		pref_index = 0

		if v.round.to_s.length > len
			while v.abs > 1000
				v = v / 1000
				pref_index += 1
			end

			if v < 0 && v.abs >= 100
				v = v / 1000
				pref_index += 1
			end
		end

		pref = prefixes[pref_index]
		digits = len - pref.length
		decimals =  digits - v.abs.to_i.to_s.length - (v < 0 ? 1 : 0)
		return ("%.#{decimals}f" % v) + pref
	end

	def to_ts
		TimeSpan.new self
	end
end
